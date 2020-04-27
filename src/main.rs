use elsa::FrozenMap;
use fluent::{FluentBundle, FluentResource};
use fluent_fallback::Localization;
use fluent_langneg::{accepted_languages, negotiate_languages, NegotiationStrategy};
use git2::Repository;
use regex::Regex;
use std::env;
use std::fs;
use std::io;
use std::io::prelude::*;
use std::io::{Error, ErrorKind};
use std::iter;
use std::path;
use std::str;
use std::vec;
use structopt::clap::AppSettings;
use structopt::StructOpt;
use unic_langid::LanguageIdentifier;

/// The command line interface to the CaSILE toolkit, a book publishing
/// workflow employing SILE and other wizardry
#[derive(StructOpt)]
#[structopt(version = env!("VERGEN_SEMVER"))]
#[structopt(setting = AppSettings::InferSubcommands)]
struct Cli {
    /// Activate debug mode
    #[structopt(short, long, env = "DEBUG")]
    debug: bool,

    /// Set language
    #[structopt(short, long, env = "LANG")]
    language: String,

    /// Outputs verbose feedback where possible
    #[structopt(short, long)]
    verbose: bool,

    #[structopt(subcommand)]
    subcommand: Subcommand,
}

#[derive(StructOpt)]
enum Subcommand {
    /// Executes a make target
    Make {
        /// Target as defined in CaSILE makefile
        target: Vec<String>,
    },

    /// Configure a book repository
    Setup {
        /// Path to project repository
        #[structopt(parse(from_os_str), default_value = "./")]
        path: path::PathBuf,
    },

    /// Pass through other commands to shell
    #[structopt(external_subcommand)]
    Other(Vec<String>),
}

static L10N_RESOURCES: &[&str] = &["cli.ftl"];

fn main() -> io::Result<()> {
    let args = Cli::from_args();

    if args.debug {
        println!("User requested debug mode")
    }

    if args.verbose {
        println!("User requested verbose output")
    }

    let available = get_available_locales().expect("Could not find valid BCP47 resource files.");
    let re = Regex::new(r"\..*$").unwrap();
    let input = re.replace(&args.language, "");
    let requested = accepted_languages::parse(&input);
    let default: LanguageIdentifier = "en-US".parse().unwrap();
    let resolved_locales = negotiate_languages(
        &requested,
        &available,
        Some(&default),
        NegotiationStrategy::Filtering,
    );

    let resources: FrozenMap<String, Box<FluentResource>> = FrozenMap::new();
    let mut res_path_scheme = env::current_dir().expect("Failed to retireve current dir.");
    res_path_scheme.push("resources");
    res_path_scheme.push("{locale}");
    res_path_scheme.push("{res_id}");
    let res_path_scheme = res_path_scheme.to_str().unwrap();
    let generate_messages = |res_ids: &[String]| {
        let mut locales = resolved_locales.iter();
        let res_mgr = &resources;
        let res_ids = res_ids.to_vec();

        iter::from_fn(move || {
            locales.next().map(|locale| {
                let mut bundle = FluentBundle::new(vec![locale.clone()]);
                let res_path = res_path_scheme.replace("{locale}", &locale.to_string());

                for res_id in &res_ids {
                    let path = res_path.replace("{res_id}", res_id);
                    let res = res_mgr.get(&path).unwrap_or_else(|| {
                        let source = read_file(&path).unwrap();
                        let res = FluentResource::try_new(source).unwrap();
                        res_mgr.insert(path.to_string(), Box::new(res))
                    });
                    bundle.add_resource(res).unwrap();
                }
                bundle
            })
        })
    };
    let loc = Localization::new(
        L10N_RESOURCES.iter().map(|s| s.to_string()).collect(),
        generate_messages,
    );

    let value = loc.format_value("debug-shell", None);
    println!("Message is: {}", value);

    match args.subcommand {
        Subcommand::Make { target } => make(target),
        Subcommand::Setup { path } => setup(path),
        _a => shell(),
    }
}

fn make(_target: vec::Vec<String>) -> io::Result<()> {
    println!("Make make make sense or I’ll make you make makefiles.");
    Ok(())
}

fn setup(path: path::PathBuf) -> io::Result<()> {
    let metadata = fs::metadata(&path)?;
    match metadata.is_dir() {
        true => match Repository::open(path) {
            Ok(_repo) => Ok(println!(
                "Run setup, “They said you were this great colossus!”"
            )),
            Err(_error) => Err(Error::new(ErrorKind::InvalidInput, "Not a git repo!")),
        },
        false => Err(Error::new(ErrorKind::InvalidInput, "Not a dir, Frank!")),
    }
}

fn shell() -> io::Result<()> {
    println!("Ship all this off to the shell, maybe they can handle it.");
    Ok(())
}

// https://github.com/projectfluent/fluent-rs/blob/c9e45651/fluent-fallback/examples/simple-fallback.rs#L38
fn read_file(path: &str) -> Result<String, io::Error> {
    let mut f = fs::File::open(path)?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}

// TODO: Move to build.rs?
// https://github.com/projectfluent/fluent-rs/blob/c9e45651/fluent-resmgr/examples/simple-resmgr.rs#L35
fn get_available_locales() -> Result<Vec<LanguageIdentifier>, io::Error> {
    let mut locales = vec![];
    let res_dir = fs::read_dir("./resources/")?;
    for entry in res_dir {
        if let Ok(entry) = entry {
            let path = entry.path();
            if path.is_dir() {
                if let Some(name) = path.file_name() {
                    if let Some(name) = name.to_str() {
                        let langid: LanguageIdentifier =
                            name.parse().expect("Could not parse BCP47 language tag.");
                        locales.push(langid);
                    }
                }
            }
        }
    }
    return Ok(locales);
}
