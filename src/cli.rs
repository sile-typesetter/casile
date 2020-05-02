use clap::{AppSettings, Clap};
use std::{env, path};

/// The command line interface to the CaSILE toolkit, a book publishing
/// workflow employing SILE and other wizardry
#[derive(Clap, Debug)]
// #[clap(about = "bob is a turtle")]
#[clap(version = env!("VERGEN_SEMVER"))]
#[clap(setting = AppSettings::InferSubcommands)]
#[clap(setting = AppSettings::AllowExternalSubcommands)]
pub struct Cli {
    /// Activate debug mode
    #[clap(short, long)]
    pub debug: bool,

    /// Set language
    #[clap(short, long, required = false, env = "LANG")]
    pub language: String,

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
