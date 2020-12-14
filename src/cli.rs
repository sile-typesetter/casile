use clap::{AppSettings, Clap};
use std::path;

// FTL: help-flags-debug
/// The command line interface to the CaSILE toolkit, a book publishing
/// workflow employing SILE and other wizardry
#[derive(Clap, Debug)]
#[clap(bin_name = "casile")]
#[clap(setting = AppSettings::InferSubcommands)]
pub struct Cli {
    // FTL: help-flags-debug
    /// Activate debug mode
    #[clap(short, long)]
    pub debug: bool,

    // FTL: help-flags-language
    /// Set language
    #[clap(short, long, env = "LANG")]
    pub language: Option<String>,

    // FTL: help-flags-verbose
    /// Outputs verbose feedback where possible
    #[clap(short, long)]
    pub verbose: bool,

    #[clap(subcommand)]
    pub subcommand: Subcommand,
}

#[derive(Clap, Debug)]
pub enum Subcommand {
    // FTL: help-subcommand-make
    /// Executes a make target
    Make {
        /// Target as defined in CaSILE or project rules
        target: Vec<String>,
    },

    // FTL: help-subcommand-setup
    /// Configure a project repository
    Setup {
        /// Path to project repository
        #[clap(default_value = "./")]
        path: path::PathBuf,
    },

    // FTL: help-subcommand-status
    /// Dump what we know about the repo
    Status {},
}
