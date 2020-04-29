use casile::i18n;
use git2::Repository;
use std::env;
use std::fs;
use std::io;
use std::io::{Error, ErrorKind};
use std::path;
use std::str;
use std::vec;
use structopt::clap::AppSettings;
use structopt::clap::Shell;
use structopt::StructOpt;
use unic_langid::LanguageIdentifier;

fn main() -> io::Result<()> {
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

    Cli::clap().gen_completions(env!("CARGO_PKG_NAME"), Shell::Bash, "target");
    Cli::clap().gen_completions(env!("CARGO_PKG_NAME"), Shell::Fish, "target");
    Cli::clap().gen_completions(env!("CARGO_PKG_NAME"), Shell::Zsh, "target");

    let a = Cli::from_args();

    let config = casile::Config {
        verbose: a.verbose,
        debug: a.debug,
    };

    println!("First pass {:?}", a.language);
    println!("CONF pass {:?}", config);

    let args = Cli::from_args();

    i18n::init(args.language);

    if args.debug {
        println!("User requested debug mode")
    }

    if args.verbose {
        println!("User requested verbose output")
    }

    match args.subcommand {
        Subcommand::Make { target } => make(config, target),
        Subcommand::Setup { path } => setup(config, path),
        _a => shell(config),
    }
}

fn make(config: casile::Config, _target: vec::Vec<String>) -> io::Result<()> {
    let a = i18n::get_str("debug-shell");
    println!("Translation: {}", a);
    println!("Make make make sense or I’ll make you make makefiles.");
    Ok(())
}

fn setup(config: casile::Config, path: path::PathBuf) -> io::Result<()> {
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

fn shell(config: casile::Config) -> io::Result<()> {
    println!("Ship all this off to the shell, maybe they can handle it.");
    Ok(())
}
