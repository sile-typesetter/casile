use crate::i18n::LocalText;

use crate::config::CONF;
use crate::VERSION;

use console::style;
use indicatif::{HumanDuration, MultiProgress, ProgressBar, ProgressFinish, ProgressStyle};
use std::sync::RwLock;
use std::str;
use std::time::{Duration, Instant};

static ERROR_TUI_WRITE: &str = "Unable to gain write lock on tui status wrapper";

lazy_static! {
    pub static ref TUI: RwLock<Progress> = RwLock::new(Progress::new());
}

impl TUI {
    pub fn add(&self, bar: ProgressBar) -> ProgressBar {
        let tui = self.write().expect(ERROR_TUI_WRITE);
        tui.add(bar)
    }
    pub fn remove(&self, bar: &ProgressBar) {
        let tui = self.write().expect(ERROR_TUI_WRITE);
        tui.remove(bar);
    }
}

#[derive(Debug)]
pub struct Progress(MultiProgress);

impl Progress {
    pub fn new() -> Progress {
        Progress (MultiProgress::new())
    }
}

impl std::ops::Deref for Progress {
    type Target = MultiProgress;
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

/// Top command level status handler
#[derive(Debug)]
pub struct CommandStatus {
    started: Instant,
}

impl CommandStatus {
    pub fn new () -> CommandStatus {
        let started = Instant::now();
        CommandStatus {
            started,
        }
    }
    pub fn bar (&self) -> ProgressBar {
        let prefix = style("⛫").cyan().to_string();
        let bar = ProgressBar::new_spinner()
            .with_style(ProgressStyle::with_template("{prefix} {msg}").unwrap())
            .with_prefix(prefix);
        bar
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

#[derive(Debug)]
pub struct SubcommandStatus {
    bar: ProgressBar,
    good_msg: String,
    bad_msg: String,
}

impl SubcommandStatus {
    pub fn new(key: &str, good_key: &str, bad_key: &str) -> SubcommandStatus {
        let msg = style(LocalText::new(key).fmt()).yellow().bright().to_string();
        let prefix = style("⟳").yellow().to_string();
        let bar = ProgressBar::new_spinner()
            .with_style(ProgressStyle::with_template("{prefix} {msg}").unwrap())
            .with_prefix(prefix)
            .with_message(msg);
        let bar = TUI.add(bar);
        let good_msg = style(LocalText::new(good_key).fmt())
            .green()
            .bright()
            .to_string();
        let bad_msg = style(LocalText::new(bad_key).fmt()).red().bright().to_string();
        SubcommandStatus{ bar, good_msg, bad_msg }
    }
    pub fn end(&self, status: bool) {
        (status).then(|| self.pass()).unwrap_or_else(|| self.fail());
    }
    pub fn pass(&self) {
        let prefix = style("✔").green().to_string();
        self.set_prefix(prefix);
        let msg = self.good_msg.to_owned();
        self.finish_with_message(msg);
    }
    pub fn fail(&self) {
        let prefix = style("✗").red().to_string();
        self.set_prefix(prefix);
        let msg = self.bad_msg.to_owned();
        self.finish_with_message(msg);
    }
}

impl std::ops::Deref for SubcommandStatus {
    type Target = ProgressBar;
    fn deref(&self) -> &Self::Target {
        &self.bar
    }
}

#[derive(Debug)]
pub struct MakeTargetStatus {
    bar: ProgressBar,
    target: String,
}

impl MakeTargetStatus {
    pub fn new(target: String) -> MakeTargetStatus {
        let msg = style(LocalText::new("make-report-start")
            .arg("target", style(target.clone()).white().bold())
            .fmt()).yellow().bright().to_string();
        let bar = ProgressBar::new_spinner()
            .with_style(ProgressStyle::with_template("{spinner} {msg}").unwrap());
        let bar = TUI.add(bar);
        bar.set_message(msg);
        bar.enable_steady_tick(Duration::new(0, 500_000_000));
        MakeTargetStatus {
            bar: bar,
            target,
        }
    }
    pub fn stdout(&self, line: &str) {
        let target = style(self.target.clone()).white().bold().to_string();
        let line = style(line).dim();
        self.println(format!("{target}: {line}"));
    }
    pub fn stderr(&self, line: &str) {
        let target = style(self.target.clone()).white().to_string();
        let line = style(line).dim();
        self.println(format!("{target}: {line}"));
    }
    pub fn pass(&self) {
        let target = self.target.clone();
        if target.starts_with(".casile") {
            self.bar.disable_steady_tick();
            TUI.remove(&self.bar);
        } else {
            let msg = style(LocalText::new("make-report-pass")
                            .arg("target", style(target).white().bold())
                            .fmt()).green().bright().to_string();
            self.finish_with_message(msg);
        }
    }
    pub fn fail(&self) {
        let msg = style(LocalText::new("make-report-fail")
            .arg("target", style(self.target.clone()).white().bold())
            .fmt()).red().bright().to_string();
        self.finish_with_message(msg);
    }
}

impl std::ops::Deref for MakeTargetStatus {
    type Target = ProgressBar;
    fn deref(&self) -> &Self::Target {
        &self.bar
    }
}

#[derive(Debug)]
pub struct SetupCheck(ProgressBar);

impl SetupCheck {
    pub fn start(key: &str) -> SetupCheck {
        let msg = LocalText::new(key).fmt();
        let bar = if CONF.get_bool("debug").unwrap() || CONF.get_bool("verbose").unwrap() {
            let no = style(LocalText::new("setup-false").fmt()).red().to_string();
            let bar = ProgressBar::new_spinner()
                .with_style(ProgressStyle::with_template("{msg}").unwrap())
                .with_finish(ProgressFinish::AbandonWithMessage(
                    format!("{msg} {no}").into(),
                ));
            TUI.add(bar)
        } else {
            ProgressBar::hidden()
        };
        bar.set_message(msg);
        SetupCheck(bar)
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
