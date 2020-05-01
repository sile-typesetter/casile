use casile::i18n;
use clap::{AppSettings, Clap};
use std::{env, error, path, str};

/// The command line interface to the CaSILE toolkit, a book publishing
/// workflow employing SILE and other wizardry
#[derive(Clap, Debug)]
// #[clap(about = "bob is a turtle")]
#[clap(version = env!("VERGEN_SEMVER"))]
#[clap(setting = AppSettings::InferSubcommands)]
#[clap(setting = AppSettings::AllowExternalSubcommands)]
struct Cli {
    /// Activate debug mode
    #[clap(short, long)]
    debug: bool,

    /// Set language
    #[clap(short, long, required = false, env = "LANG")]
    language: String,

    /// Outputs verbose feedback where possible
    #[clap(short, long)]
    verbose: bool,

    #[clap(subcommand)]
    subcommand: Subcommand,
}

#[derive(Clap, Debug)]
enum Subcommand {
    /// Executes a make target
    Make {
        /// Target as defined in CaSILE makefile
        target: Vec<String>,
    },

    /// Configure a book repository
    Setup {
        /// Path to project repository
        #[clap(parse(from_os_str), default_value = "./")]
        path: path::PathBuf,
        // /// Output Bash, Fish, Zsh, PowerShell, or Elvish shell completion rules
        // #[clap(long)]
        // // completions: clap::Shell,
        // completions: Option<String>,
    },

    /// Pass through other commands to shell
    #[clap(external_subcommand)]
    Other(Vec<String>),
}

fn main() -> Result<(), Box<dyn error::Error>> {
    let args = Cli::parse();
    let config = casile::Config {
        verbose: args.verbose,
        debug: args.debug,
        locale: i18n::Locale::negotiate(args.language),
    };
    match args.subcommand {
        Subcommand::Make { target } => casile::make::run(&config, target),
        Subcommand::Setup { path } => casile::setup::run(&config, path),
        // Subcommand::Setup { path, completions } => match completions {
        //     None => casile::setup::run(&config, path),
        //     Some(_shell) => {
        //         Cli::clap_completions::generate_to(env!("CARGO_PKG_NAME"), "Zsh", &mut io::stdout());
        //         Ok(())
        //     }
        // },
        Subcommand::Other(input) => casile::shell::run(&config, input),
    }
}
