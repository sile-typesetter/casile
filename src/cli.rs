use clap::{AppSettings, Clap};
use std::path;

// FTL: help-flags-debug
/// The command line interface to the CaSILE toolkit,
/// a book publishing workflow employing SILE and other wizardry.
#[derive(Clap, Debug)]
#[clap(bin_name = "casile")]
#[clap(setting = AppSettings::InferSubcommands)]
pub struct Cli {
    // FTL: help-flags-debug
    /// Enable extra debug output from tooling
    #[clap(short, long)]
    pub debug: bool,

    // FTL: help-flags-language
    /// Set language
    #[clap(short, long, env = "LANG")]
    pub language: Option<String>,

    // FTL: help-flags-path
    /// Set project root path
    #[clap(short, long, default_value = "./")]
    pub path: path::PathBuf,

    // FTL: help-flags-quiet
    /// Discard all non-error output messages
    #[clap(short, long)]
    pub quiet: bool,

    // FTL: help-flags-verbose
    /// Enable extra verbose output from tooling
    #[clap(short, long)]
    pub verbose: bool,

    #[clap(subcommand)]
    pub subcommand: Subcommand,
}

#[derive(Clap, Debug)]
pub enum Subcommand {
    // FTL: help-subcommand-make
    /// Build specified target(s) with ‘make’
    Make {
        // FTL: help-subcommand-make-target
        /// Target as defined in CaSILE or project rules
        target: Vec<String>,
    },

    // FTL: help-subcommand-setup
    /// Configure a publishing project repository
    Setup {},

    // FTL: help-subcommand-status
    /// Show status information about setup, configuration, and build state
    Status {},
}
