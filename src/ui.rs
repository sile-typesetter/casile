use console::user_attended;
use std::str;
use std::sync::RwLock;

use crate::ui_indicatif::IndicatifInterface;

static ERROR_UI_WRITE: &str = "Unable to gain write lock on ui status wrapper";

lazy_static! {
    #[derive(Debug)]
    pub static ref CASILEUI: RwLock<Box<dyn UserInterface>> = RwLock::new(UISwitcher::new());
}

#[derive(Debug, Default)]
pub struct UISwitcher {}

impl UISwitcher {
    pub fn new() -> Box<dyn UserInterface> {
        if user_attended() {
            Box::<IndicatifInterface>::default()
        } else {
            Box::<IndicatifInterface>::default()
        }
    }
}

pub trait UserInterface: Send + Sync {
    fn welcome(&self);
    fn farewell(&self);
    fn new_subcommand(&self, key: &str, good_key: &str, bad_key: &str)
        -> Box<dyn SubcommandStatus>;
    fn new_check(&self, key: &str) -> Box<dyn SetupCheck>;
    fn new_target(&self, target: String) -> Box<dyn MakeTargetStatus>;
}

impl UserInterface for CASILEUI {
    fn welcome(&self) {
        self.write().expect(ERROR_UI_WRITE).welcome()
    }
    fn farewell(&self) {
        self.write().expect(ERROR_UI_WRITE).farewell()
    }
    fn new_subcommand(
        &self,
        key: &str,
        good_key: &str,
        bad_key: &str,
    ) -> Box<dyn SubcommandStatus> {
        self.write()
            .expect(ERROR_UI_WRITE)
            .new_subcommand(key, good_key, bad_key)
    }
    fn new_check(&self, key: &str) -> Box<dyn SetupCheck> {
        self.write().expect(ERROR_UI_WRITE).new_check(key)
    }
    fn new_target(&self, target: String) -> Box<dyn MakeTargetStatus> {
        self.write().expect(ERROR_UI_WRITE).new_target(target)
    }
}

pub trait SubcommandStatus: Send + Sync {
    fn end(&self, status: bool);
    fn dump(&self, backlog: &[String]);
}

pub trait SetupCheck: Send + Sync {
    fn pass(&self);
}

pub trait MakeTargetStatus: Send + Sync {
    fn stdout(&self, line: &str);
    fn stderr(&self, line: &str);
    fn pass(&self);
    fn fail(&self);
}
