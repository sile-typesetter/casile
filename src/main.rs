use casile::i18n;
use std::{env, fs, io, path, str, vec};
use structopt::{clap, StructOpt};
use unic_langid::LanguageIdentifier;

/// The command line interface to the CaSILE toolkit, a book publishing
/// workflow employing SILE and other wizardry
#[derive(StructOpt)]
#[structopt(version = env!("VERGEN_SEMVER"))]
#[structopt(setting = clap::AppSettings::InferSubcommands)]
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
    Cli::clap().gen_completions(env!("CARGO_PKG_NAME"), clap::Shell::Bash, "target");
    Cli::clap().gen_completions(env!("CARGO_PKG_NAME"), clap::Shell::Fish, "target");
    Cli::clap().gen_completions(env!("CARGO_PKG_NAME"), clap::Shell::Zsh, "target");

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
        Subcommand::Make { target } => casile::make::run(config, target),
        Subcommand::Setup { path } => casile::setup::run(config, path),
        _a => casile::shell::run(config),
    }
}
