use fluent_langneg::{accepted_languages, negotiate_languages, NegotiationStrategy};
use fluent_resmgr::resource_manager::ResourceManager;
use git2::Repository;
use regex::Regex;
use std::fs;
use std::io;
use std::io::{Error, ErrorKind};
use std::path;
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
    println!("Lang ended up {:?}", resolved_locales[0]);
    let resources: vec::Vec<String> = vec!["cli.ftl".into()];
    let mgr = ResourceManager::new("./resources/{locale}/{res_id}".into());
    let bundle = mgr.get_bundle(
        resolved_locales.into_iter().map(|s| s.to_owned()).collect(),
        resources,
    );

    let mut errors = vec![];
    let msg = bundle.get_message("debug-shell").expect("Message exists");
    let pattern = msg.value.expect("Message has a value");
    let value = bundle.format_pattern(&pattern, None, &mut errors);
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
