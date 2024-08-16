// use clap::FromArgMatches as _;
use clap::{Args, Subcommand};
use std::{ffi::OsString, path};

// FTL: help-description
/// The command line interface to the CaSILE toolkit,
/// a publishing workflow employing SILE and other wizardry.
#[derive(Args, Debug)]
#[clap(author)]
pub struct Cli {
    // FTL: help-flag-debug
    /// Enable extra debug output from tooling
    #[clap(short, long)]
    pub debug: bool,

    // FTL: help-flag-language
    /// Set language
    #[clap(short, long)]
    pub language: Option<String>,

    // FTL: help-flag-passthrough
    /// Eschew all UI output and just pass the subprocess output through
    #[clap(short, long)]
    pub passthrough: bool,

    // FTL: help-flag-project
    /// Set project root path
    #[clap(short = 'P', long, default_value = "./")]
    pub project: path::PathBuf,

    // FTL: help-flag-quiet
    /// Discard all non-error output messages
    #[clap(short, long)]
    pub quiet: bool,

    // FTL: help-flag-verbose
    /// Enable extra verbose output from tooling
    #[clap(short, long)]
    pub verbose: bool,

    #[clap(subcommand)]
    pub subcommand: Commands,
}

#[derive(Subcommand, Debug)]
pub enum Commands {
    // FTL: help-subcommand-make
    /// Build specified target(s) with ‘make’
    Make {
        // FTL: help-subcommand-make-target
        /// Target(s) as defined by CaSILE in project rules
        target: Vec<String>,
    },

    // FTL: help-subcommand-run
    /// Run helper script inside CaSILE environment
    Run {
        // FTL: help-subcommand-run-name
        /// Run script name as supplied by CaSILE, toolkit, or project
        name: String,

        // FTL: help-subcommand-run-arguments
        /// Arguments to pass to script being run
        arguments: Vec<OsString>,
    },

    // FTL: help-subcommand-setup
    /// Configure a publishing project repository
    Setup {},

    // FTL: help-subcommand-status
    /// Show status information about setup, configuration, and build state
    Status {},
}
