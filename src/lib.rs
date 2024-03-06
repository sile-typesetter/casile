#![doc = include_str!("../README.md")]
#![allow(clippy::trivial_regex)]

#[macro_use]
extern crate lazy_static;
extern crate num_cpus;

use crate::config::CONF;

use console::style;
use git2::{Oid, Repository, Signature};
use i18n::LocalText;
use indicatif::{HumanDuration, MultiProgress, ProgressBar, ProgressFinish, ProgressStyle};
use regex::Regex;
use std::ffi::OsStr;
use std::sync::MutexGuard;
use std::{error, fmt, path, result, str, time::Duration};

pub mod cli;
pub mod config;
pub mod i18n;

// Subcommands
pub mod make;
pub mod run;
pub mod setup;
pub mod status;

// Import stuff set by autoconf/automake at build time
pub static CONFIGURE_PREFIX: &str = env!["CONFIGURE_PREFIX"];
pub static CONFIGURE_BINDIR: &str = env!["CONFIGURE_BINDIR"];
pub static CONFIGURE_DATADIR: &str = env!["CONFIGURE_DATADIR"];

/// If all else fails, use this BCP-47 locale
pub static DEFAULT_LOCALE: &str = "en-US";

lazy_static! {
    /// CaSILE version number as detected by `git describe --tags` at build time
    pub static ref VERSION: &'static str =
        option_env!("VERGEN_GIT_DESCRIBE").unwrap_or_else(|| env!("CARGO_PKG_VERSION"));
}

pub type Result<T> = result::Result<T, Box<dyn error::Error>>;

/// A type for our internal whoops
#[derive(Debug)]
pub struct Error {
    details: String,
}

impl Error {
    pub fn new(key: &str) -> Error {
        Error {
            details: LocalText::new(key).fmt(),
        }
    }
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.details)
    }
}

impl error::Error for Error {
    fn description(&self) -> &str {
        &self.details
    }
}

#[derive(Debug)]
pub struct HeaderBar(ProgressBar);

impl HeaderBar {
    pub fn new(key: &str) -> HeaderBar {
        let msg = style(LocalText::new(key).fmt()).yellow().bright().to_string();
        let prefix = style("⟳").yellow().to_string();
        let bar = ProgressBar::new_spinner()
            .with_style(ProgressStyle::with_template("{prefix} {msg}").unwrap())
            .with_prefix(prefix)
            .with_message(msg);
        HeaderBar(bar)
    }
    pub fn pass(&self, key: &str) {
        let msg = style(LocalText::new(key).fmt())
            .green()
            .bright()
            .to_string();
        let prefix = style("✔").green().to_string();
        self.set_prefix(prefix);
        self.finish_with_message(msg);
    }
    pub fn fail(&self, key: &str) {
        let msg = style(LocalText::new(key).fmt()).red().bright().to_string();
        let prefix = style("✗").red().to_string();
        self.set_prefix(prefix);
        self.finish_with_message(msg);
    }
}

impl std::ops::Deref for HeaderBar {
    type Target = ProgressBar;
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

/// A holder for subcommand level status with the group and top level header
#[derive(Debug)]
pub struct SubcommandStatus {
    pub progress: MultiProgress,
    pub header: HeaderBar,
}

impl SubcommandStatus {
    pub fn new(key: &str) -> SubcommandStatus {
        let progress = MultiProgress::new();
        let header = HeaderBar::new(key);
        let header = HeaderBar(progress.add(header.0));
        SubcommandStatus { progress, header }
    }
}

#[derive(Debug)]
pub struct SetupCheck(ProgressBar);

impl SetupCheck {
    pub fn start(progress: MutexGuard<MultiProgress>, key: &str) -> SetupCheck {
        let msg = LocalText::new(key).fmt();
        let bar = if CONF.get_bool("debug").unwrap() || CONF.get_bool("verbose").unwrap() {
            let no = style(LocalText::new("setup-false").fmt()).red().to_string();
            ProgressBar::new_spinner()
                .with_style(ProgressStyle::with_template("{msg}").unwrap())
                .with_finish(ProgressFinish::AbandonWithMessage(
                    format!("{msg} {no}").into(),
                ))
        } else {
            ProgressBar::hidden()
        };
        let bar = bar.with_message(msg);
        SetupCheck(progress.add(bar))
    }
    pub fn pass(&self) {
        let msg = self.0.message();
        let yes = style(LocalText::new("setup-true").fmt())
            .green()
            .to_string();
        self.finish_with_message(format!("{msg} {yes}"))
    }
}

impl std::ops::Deref for SetupCheck {
    type Target = ProgressBar;
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

/// Get repository object
pub fn get_repo() -> Result<Repository> {
    let path = CONF.get_string("path")?;
    Ok(Repository::discover(path)?)
}

pub fn commit(repo: Repository, oid: Oid, msg: &str) -> result::Result<Oid, git2::Error> {
    let prefix = "[casile]";
    let commiter = repo.signature()?;
    let author = Signature::now("CaSILE", commiter.email().unwrap())?;
    let parent = repo.head()?.peel_to_commit()?;
    let tree = repo.find_tree(oid)?;
    let parents = [&parent];
    repo.commit(
        Some("HEAD"),
        &author,
        &commiter,
        &[prefix, msg].join(" "),
        &tree,
        &parents,
    )
}

pub fn locale_to_language(lang: String) -> String {
    let re = Regex::new(r"[-_\.].*$").unwrap();
    let locale_frag = lang.as_str().to_lowercase();
    let lang = re.replace(&locale_frag, "");
    match &lang[..] {
        "c" => String::from("en"),
        _ => String::from(lang),
    }
}

/// Output welcome header at start of run before moving on to actual commands
pub fn show_welcome() {
    let msg = LocalText::new("welcome").arg("version", *VERSION).fmt();
    let msg = style(msg).cyan().bright().to_string();
    let prefix = style("⛫").cyan().to_string();
    ProgressBar::new_spinner()
        .with_style(ProgressStyle::with_template("{prefix} {msg}").unwrap())
        .with_prefix(prefix)
        .finish_with_message(msg);
}

/// Output welcome header at start of run before moving on to actual commands
pub fn show_farewell(elapsed: Duration) {
    let time = HumanDuration(elapsed);
    let msg = LocalText::new("farewell").arg("duration", time).fmt();
    let msg = style(msg).cyan().bright().to_string();
    let prefix = style("⛫").cyan().to_string();
    ProgressBar::new_spinner()
        .with_style(ProgressStyle::with_template("{prefix} {msg}").unwrap())
        .with_prefix(prefix)
        .finish_with_message(msg);
}

#[cfg(unix)]
pub fn bytes2path(b: &[u8]) -> &path::Path {
    use std::os::unix::prelude::*;
    path::Path::new(OsStr::from_bytes(b))
}
#[cfg(windows)]
pub fn bytes2path(b: &[u8]) -> &path::Path {
    use std::str;
    path::Path::new(str::from_utf8(b).unwrap())
}
