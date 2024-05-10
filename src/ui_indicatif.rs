use crate::i18n::LocalText;

use crate::config::CONF;
use crate::ui::*;

use console::style;
use indicatif::{HumanDuration, MultiProgress, ProgressBar, ProgressFinish, ProgressStyle};
use std::time::Instant;

#[derive(Debug)]
pub struct IndicatifInterface {
    progress: MultiProgress,
    messages: UserInterfaceMessages,
    started: Instant,
}

impl std::ops::Deref for IndicatifInterface {
    type Target = MultiProgress;
    fn deref(&self) -> &Self::Target {
        &self.progress
    }
}

impl Default for IndicatifInterface {
    fn default() -> Self {
        let progress = MultiProgress::new();
        progress.set_move_cursor(true);
        let started = Instant::now();
        let messages = UserInterfaceMessages::new();
        Self {
            progress,
            messages,
            started,
        }
    }
}

impl IndicatifInterface {
    pub fn bar(&self) -> ProgressBar {
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
}

impl UserInterface for IndicatifInterface {
    fn welcome(&self) {
        let msg = &self.messages.welcome;
        self.show(msg.to_string());
    }
    fn farewell(&self) {
        let time = HumanDuration(self.started.elapsed());
        let msg = LocalText::new("farewell").arg("duration", time).fmt();
        self.show(msg);
    }
    fn new_subcommand(&self, key: &str) -> Box<dyn SubcommandStatus> {
        Box::new(IndicatifSubcommandStatus::new(self, key))
    }
    fn new_check(&self, key: &str) -> Box<dyn SetupCheck> {
        Box::new(IndicatifSetupCheck::new(self, key))
    }
    fn new_target(&self, target: String) -> Box<dyn MakeTargetStatus> {
        Box::new(IndicatifMakeTargetStatus::new(self, target))
    }
}

#[derive(Debug)]
pub struct IndicatifSubcommandStatus {
    progress: MultiProgress,
    bar: ProgressBar,
    messages: SubcommandHeaderMessages,
}

impl std::ops::Deref for IndicatifSubcommandStatus {
    type Target = ProgressBar;
    fn deref(&self) -> &Self::Target {
        &self.bar
    }
}

impl IndicatifSubcommandStatus {
    pub fn new(ui: &IndicatifInterface, key: &str) -> Self {
        let messages = SubcommandHeaderMessages::new(key);
        let prefix = style("⟳").yellow().to_string();
        let bar = ProgressBar::new_spinner()
            .with_style(ProgressStyle::with_template("{prefix} {msg}").unwrap())
            .with_prefix(prefix);
        let bar = ui.add(bar);
        let msg = style(messages.msg.to_owned()).yellow().bright().to_string();
        bar.set_message(msg);
        Self {
            progress: ui.progress.clone(),
            bar,
            messages,
        }
    }
    pub fn pass(&self) {
        let prefix = style("✔").green().to_string();
        self.set_prefix(prefix);
        let msg = style(self.messages.good_msg.to_owned())
            .green()
            .bright()
            .to_string();
        self.finish_with_message(msg);
    }
    pub fn fail(&self) {
        let prefix = style("✗").red().to_string();
        self.set_prefix(prefix);
        let msg = style(self.messages.bad_msg.to_owned())
            .red()
            .bright()
            .to_string();
        self.finish_with_message(msg);
    }
}

impl SubcommandStatus for IndicatifSubcommandStatus {
    fn end(&self, status: bool) {
        (status).then(|| self.pass()).unwrap_or_else(|| self.fail());
    }
    fn dump(&self, backlog: &[String]) {
        let bar =
            ProgressBar::new_spinner().with_style(ProgressStyle::with_template("{msg}").unwrap());
        let bar = self.progress.add(bar);
        let mut dump = String::new();
        let start = LocalText::new("make-backlog-start").fmt();
        let start = format!("{} {start}\n", style(style("┄┄┄┄┄┄").cyan()));
        dump.push_str(start.as_str());
        for line in backlog.iter() {
            dump.push_str(line.as_str());
            dump.push('\n');
        }
        let end = LocalText::new("make-backlog-end").fmt();
        let end = format!("{} {end}", style(style("┄┄┄┄┄").cyan()));
        dump.push_str(end.as_str());
        bar.set_message(dump);
        bar.finish();
    }
}

#[derive(Debug)]
pub struct IndicatifSetupCheck(ProgressBar);

impl std::ops::Deref for IndicatifSetupCheck {
    type Target = ProgressBar;
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl IndicatifSetupCheck {
    pub fn new(ui: &IndicatifInterface, key: &str) -> Self {
        let msg = LocalText::new(key).fmt();
        let bar = if CONF.get_bool("debug").unwrap() || CONF.get_bool("verbose").unwrap() {
            let no = style(LocalText::new("setup-false").fmt()).red().to_string();
            let bar = ProgressBar::new_spinner()
                .with_style(ProgressStyle::with_template("{msg}").unwrap())
                .with_finish(ProgressFinish::AbandonWithMessage(
                    format!("{msg} {no}").into(),
                ));
            ui.add(bar)
        } else {
            ProgressBar::hidden()
        };
        bar.set_message(msg);
        Self(bar)
    }
}

impl SetupCheck for IndicatifSetupCheck {
    fn pass(&self) {
        let msg = self.message();
        let yes = style(LocalText::new("setup-true").fmt())
            .green()
            .to_string();
        self.finish_with_message(format!("{msg} {yes}"))
    }
}

#[derive(Debug)]
pub struct IndicatifMakeTargetStatus {
    bar: ProgressBar,
    target: String,
}

impl std::ops::Deref for IndicatifMakeTargetStatus {
    type Target = ProgressBar;
    fn deref(&self) -> &Self::Target {
        &self.bar
    }
}

impl IndicatifMakeTargetStatus {
    pub fn new(ui: &IndicatifInterface, mut target: String) -> Self {
        // Withouth this, copying the string in the terminal as a word brings a U+2069 with it
        target.push(' ');
        let msg = style(
            LocalText::new("make-report-start")
                .arg("target", style(target.clone()).white().bold())
                .fmt(),
        )
        .yellow()
        .bright()
        .to_string();
        let pstyle = ProgressStyle::with_template("{spinner} {msg}")
            .unwrap()
            .tick_strings(&["↻", "✔"]);
        let bar = ProgressBar::new_spinner()
            .with_style(pstyle)
            .with_message(msg);
        let bar = ui.add(bar);
        bar.tick();
        Self { bar, target }
    }
}

impl MakeTargetStatus for IndicatifMakeTargetStatus {
    fn stdout(&self, line: &str) {
        let target = style(self.target.clone()).white().bold().to_string();
        let line = style(line).dim();
        self.println(format!("{target}: {line}"));
    }
    fn stderr(&self, line: &str) {
        let target = style(self.target.clone()).white().to_string();
        let line = style(line).dim();
        self.println(format!("{target}: {line}"));
    }
    fn pass(&self) {
        let target = self.target.clone();
        let allow_hide = !CONF.get_bool("debug").unwrap() && !CONF.get_bool("verbose").unwrap();
        if allow_hide && target.starts_with(".casile") {
            // UI.remove(&self.bar);
        } else {
            let msg = style(
                LocalText::new("make-report-pass")
                    .arg("target", style(target).white().bold())
                    .fmt(),
            )
            .green()
            .bright()
            .to_string();
            self.finish_with_message(msg);
        }
    }
    fn fail(&self) {
        let msg = style(
            LocalText::new("make-report-fail")
                .arg("target", style(self.target.clone()).white().bold())
                .fmt(),
        )
        .red()
        .bright()
        .to_string();
        self.finish_with_message(msg);
    }
}
