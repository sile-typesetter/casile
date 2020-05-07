use clap::{AppSettings, Clap};
use std::path;

/// The command line interface to the CaSILE toolkit, a book publishing
/// workflow employing SILE and other wizardry
#[derive(Clap, Debug)]
#[clap(bin_name = "casile")]
#[clap(setting = AppSettings::InferSubcommands)]
pub struct Cli {
    /// Activate debug mode
    #[clap(short, long)]
    pub debug: bool,

    /// Set language
    #[clap(short, long, env = "LANG")]
    pub language: Option<String>,

    /// Outputs verbose feedback where possible
    #[clap(short, long)]
    pub verbose: bool,

    #[clap(subcommand)]
    pub subcommand: Subcommand,
}

#[derive(Clap, Debug)]
pub enum Subcommand {
    /// Executes a make target
    Make {
        /// Target as defined in CaSILE makefile
        target: Vec<String>,
    },

    /// Configure a book repository
    Setup {
        /// Path to project repository
        #[clap(default_value = "./")]
        path: path::PathBuf,
    },

    /// Pass any command through to the system shell
    Shell {
        #[clap(default_value = "bash")]
        command: Vec<String>,
    },
}
