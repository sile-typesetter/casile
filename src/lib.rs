#[macro_use]
extern crate lazy_static;

use crate::config::CONFIG;
use colored::Colorize;
use i18n::LocalText;

pub mod cli;
pub mod config;
pub mod i18n;

// Subcommands
pub mod make;
pub mod setup;
pub mod shell;
pub mod status;

// Import stuff set by autoconf/automake at build time
pub static CONFIGURE_PREFIX: &'static str = env!["CONFIGURE_PREFIX"];
pub static CONFIGURE_BINDIR: &'static str = env!["CONFIGURE_BINDIR"];
pub static CONFIGURE_DATADIR: &'static str = env!["CONFIGURE_DATADIR"];

/// If all else fails, use this BCP-47 locale
pub static DEFAULT_LOCALE: &'static str = "en-US";

/// CaSILE version number as detected by `git describe --tags` at build time
pub static VERSION: &'static str = env!("VERGEN_SEMVER_LIGHTWEIGHT");

/// Output welcome header at start of run before moving on to actual commands
pub fn show_welcome() {
    let welcome = LocalText::new("welcome").arg("version", VERSION);
    eprintln!("{} {}", "┏━".cyan(), welcome.fmt().cyan());
}

/// Output header before starting work on a subcommand
pub fn header(key: &str) {
    let text = LocalText::new(key);
    eprintln!("{} {}", "┣━".cyan(), text.fmt().yellow());
}
