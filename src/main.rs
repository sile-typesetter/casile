use fluent_langneg::{
    accepted_languages, convert_vec_str_to_langids_lossy, negotiate_languages, NegotiationStrategy,
};
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

    // TODO: scan i18n dir(s) at run time for available languages
    let available = convert_vec_str_to_langids_lossy(&["en_US", "tr_TR"]);

    let re = Regex::new(r"\..*$").unwrap();
    let input = re.replace(&args.language, "");
    let requested = accepted_languages::parse(&input);
    let default: LanguageIdentifier = "en-US".parse().unwrap();

    let language = negotiate_languages(
        &requested,
        &available,
        Some(&default),
        NegotiationStrategy::Filtering,
    );

    println!("Lang ended up {:?}", language[0]);

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
