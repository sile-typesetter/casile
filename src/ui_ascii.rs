use crate::i18n::LocalText;
use crate::ui::*;

use indicatif::HumanDuration;
use std::time::Instant;

#[derive(Debug)]
pub struct AsciiInterface {
    messages: UserInterfaceMessages,
    started: Instant,
}

impl Default for AsciiInterface {
    fn default() -> Self {
        let started = Instant::now();
        let messages = UserInterfaceMessages::new();
        Self { messages, started }
    }
}

impl UserInterface for AsciiInterface {
    fn welcome(&self) {
        let welcome = &self.messages.welcome;
        println!("{welcome}");
    }
    fn farewell(&self) {
        let time = HumanDuration(self.started.elapsed());
        let farewell = LocalText::new("farewell").arg("duration", time).fmt();
        println!("{farewell}");
    }
    fn new_subcommand(&self, key: &str) -> Box<dyn SubcommandStatus> {
        Box::new(AsciiSubcommandStatus::new(key))
    }
    fn new_check(&self, key: &str) -> Box<dyn SetupCheck> {
        Box::new(AsciiSetupCheck::new(self, key))
    }
    fn new_target(&self, target: String) -> Box<dyn MakeTargetStatus> {
        Box::new(AsciiMakeTargetStatus::new(target))
    }
}

#[derive(Debug, Default)]
pub struct AsciiSubcommandStatus {}

impl AsciiSubcommandStatus {
    fn new(_key: &str) -> Self {
        Self {}
    }
}

impl SubcommandStatus for AsciiSubcommandStatus {
    fn end(&self, _status: bool) {}
    fn dump(&self, _backlog: &[String]) {}
}

#[derive(Debug, Default)]
pub struct AsciiSetupCheck {}

impl AsciiSetupCheck {
    fn new(_ui: &AsciiInterface, _key: &str) -> Self {
        Self {}
    }
}

impl SetupCheck for AsciiSetupCheck {
    fn pass(&self) {}
}

#[derive(Debug, Default)]
pub struct AsciiMakeTargetStatus {
    target: String,
}

impl AsciiMakeTargetStatus {
    fn new(target: String) -> Self {
        let msg = LocalText::new("make-report-start")
            .arg("target", &target)
            .fmt();
        println!("{msg}");
        Self { target }
    }
}

impl MakeTargetStatus for AsciiMakeTargetStatus {
    fn stdout(&self, line: &str) {
        println!("{}: {line}", &self.target);
    }
    fn stderr(&self, line: &str) {
        eprintln!("{}: {line}", &self.target);
    }
    fn pass(&self) {
        let msg = LocalText::new("make-report-pass")
            .arg("target", &self.target)
            .fmt();
        println!("{msg}");
    }
    fn fail(&self) {
        let msg = LocalText::new("make-report-fail")
            .arg("target", &self.target)
            .fmt();
        eprintln!("{msg}");
    }
}
