use casile::i18n;
use std::{env, io, path, str};
use structopt::{clap, StructOpt};

/// The command line interface to the CaSILE toolkit, a book publishing
/// workflow employing SILE and other wizardry
#[derive(Debug)]
// #[structopt(about = "bob is a turtle")]
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

#[derive(Debug, StructOpt)]
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

    let clap = Cli::clap();
    // let clap = Cli::clap().about("what about bob");
    // println!("First pass {:?}", a.language);
    // println!("CLI structs {:?}", &clap);

    let args = Cli::from_clap(&clap.get_matches());

    let config = casile::Config {
        verbose: args.verbose,
        debug: args.debug,
        locale: i18n::Locale::negotiate(args.language),
    };

    // println!("{:#?}", config);

    match args.subcommand {
        Subcommand::Make { target } => casile::make::run(config, target),
        Subcommand::Setup { path } => casile::setup::run(config, path),
        Subcommand::Other(input) => casile::shell::run(config, input),
    }
}
