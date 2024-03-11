use crate::i18n::LocalText;

use crate::config::CONF;
use crate::VERSION;

use console::style;
use indicatif::{HumanDuration, MultiProgress, ProgressBar, ProgressFinish, ProgressStyle};
use std::sync::MutexGuard;
use std::str;
use std::time::Instant;

/// Top level command TUI handler
#[derive(Debug)]
pub struct CommandStatus {
    started: Instant,
}

impl CommandStatus {
    pub fn new () -> CommandStatus {
        let started = Instant::now();
        CommandStatus {
            started
        }
    }
    pub fn bar (&self) -> ProgressBar {
        let prefix = style("⛫").cyan().to_string();
        ProgressBar::new_spinner()
            .with_style(ProgressStyle::with_template("{prefix} {msg}").unwrap())
            .with_prefix(prefix)
    }
    pub fn show(&self, msg: String) {
        let bar = self.bar();
        let msg = style(msg).cyan().bright().to_string();
        bar.finish_with_message(msg);
    }
    pub fn welcome(&self) {
        let msg = LocalText::new("welcome").arg("version", *VERSION).fmt();
        self.show(msg);
    }
    pub fn farewell(&self) {
        let time = HumanDuration(self.started.elapsed());
        let msg = LocalText::new("farewell").arg("duration", time).fmt();
        self.show(msg);
    }
}

/// Subcommand level TUI handler
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
pub struct HeaderBar(pub ProgressBar);

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

