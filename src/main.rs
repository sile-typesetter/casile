use casile::i18n;
use std::{env, error, io, path, str};
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
    #[structopt(short, long)]
    debug: bool,

    /// Set language
    #[structopt(short, long, required = false, env = "LANG")]
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

        /// Output Bash, Fish, Zsh, PowerShell, or Elvish shell completion rules
        #[structopt(long)]
        completions: Option<clap::Shell>,
    },

    /// Pass through other commands to shell
    #[structopt(external_subcommand)]
    Other(Vec<String>),
}

fn main() -> Result<(), Box<dyn error::Error>> {
    let clap = Cli::clap();
    // let clap = Cli::clap().about("what about bob");
    // println!("First pass {:?}", a.language);

    let args = Cli::from_clap(&clap.get_matches());

    let config = casile::Config {
        verbose: args.verbose,
        debug: args.debug,
        locale: i18n::Locale::negotiate(args.language),
    };

    match args.subcommand {
        Subcommand::Make { target } => casile::make::run(&config, target),
        Subcommand::Setup { path, completions } => match completions {
            None => casile::setup::run(&config, path),
            Some(shell) => {
                Cli::clap().gen_completions_to(env!("CARGO_PKG_NAME"), shell, &mut io::stdout());
                Ok(())
            }
        },
        Subcommand::Other(input) => casile::shell::run(&config, input),
    }
}
