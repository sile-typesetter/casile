use crate::i18n::LocalText;
use crate::ui::*;
use crate::*;

use indicatif::HumanDuration;
use std::collections::HashMap;
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
    fn new_check(&self, key: &str) -> Box<dyn SetupCheck> {
        Box::new(AsciiSetupCheck::new(self, key))
    }
    fn new_subcommand(&self, key: &str) -> Box<dyn SubcommandStatus> {
        Box::new(AsciiSubcommandStatus::new(key))
    }
}

#[derive(Default)]
pub struct AsciiSubcommandStatus {
    jobs: HashMap<MakeTarget, Box<dyn JobStatus>>,
}

impl AsciiSubcommandStatus {
    fn new(_key: &str) -> Self {
        Self {
            jobs: HashMap::new(),
        }
    }
}

impl SubcommandStatus for AsciiSubcommandStatus {
    fn end(&self, _status: bool) {}
    fn error(&mut self, msg: String) {
        eprintln!("{msg}");
    }
    fn new_target(&mut self, target: MakeTarget) {
        let target_status = Box::new(AsciiJobStatus::new(target.clone()));
        self.jobs.insert(target, target_status);
    }
    fn get_target(&self, target: MakeTarget) -> Option<&Box<dyn JobStatus>> {
        self.jobs.get(&target)
    }
}

#[derive(Debug, Default)]
pub struct AsciiSetupCheck {
    message: String,
}

impl AsciiSetupCheck {
    fn new(_ui: &AsciiInterface, key: &str) -> Self {
        let message = LocalText::new(key).fmt();
        Self { message }
    }
}

impl SetupCheck for AsciiSetupCheck {
    fn pass(&self) {
        let msg = &self.message;
        let yes = LocalText::new("setup-true").fmt();
        println!("{msg} {yes}");
    }
    fn fail(&self) {
        let msg = &self.message;
        let no = LocalText::new("setup-false").fmt();
        eprintln!("{msg} {no}");
    }
}

#[derive(Debug, Default)]
pub struct AsciiJobStatus {
    target: MakeTarget,
    log: JobBacklog,
}

impl AsciiJobStatus {
    fn new(target: MakeTarget) -> Self {
        let msg = LocalText::new("make-report-start")
            .arg("target", target.clone())
            .fmt();
        println!("{msg}");
        Self {
            target,
            log: JobBacklog::default(),
        }
    }
}

impl JobStatus for AsciiJobStatus {
    fn push(&self, line: JobBacklogLine) {
        self.log.push(line);
    }
    fn must_dump(&self) -> bool {
        self.target.starts_with("debug")
    }
    fn dump(&self) {
        let lines = self.log.lines.read().unwrap();
        let start = LocalText::new("make-backlog-start")
            .arg("target", self.target.clone())
            .fmt();
        println!("----- {start}");
        for line in lines.iter() {
            match line.stream {
                JobBacklogStream::StdOut => println!("{}", line.line),
                JobBacklogStream::StdErr => eprintln!("{}", line.line),
            }
        }
        let end = LocalText::new("make-backlog-end").fmt();
        println!("----- {end}");
    }
    fn pass_msg(&self) {
        let msg = LocalText::new("make-report-pass")
            .arg("target", &self.target)
            .fmt();
        println!("{msg}")
    }
    fn fail_msg(&self, code: u32) {
        let msg = LocalText::new("make-report-fail")
            .arg("target", &self.target)
            .arg("code", code)
            .fmt();
        eprintln!("{msg}")
    }
}
