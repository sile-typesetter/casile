use crate::i18n::LocalText;
use crate::ui_indicatif::IndicatifInterface;

use console::user_attended;
use std::str;
use std::sync::RwLock;

static ERROR_UI_WRITE: &str = "Unable to gain write lock on ui status wrapper";

lazy_static! {
    #[derive(Debug)]
    pub static ref CASILEUI: RwLock<Box<dyn UserInterface>> = RwLock::new(UISwitcher::pick());
}

#[derive(Debug, Default)]
pub struct UISwitcher {}

impl UISwitcher {
    pub fn pick() -> Box<dyn UserInterface> {
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
    fn new_subcommand(&self, key: &str) -> Box<dyn SubcommandStatus>;
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
    fn new_subcommand(&self, key: &str) -> Box<dyn SubcommandStatus> {
        self.write().expect(ERROR_UI_WRITE).new_subcommand(key)
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

#[derive(Debug)]
pub struct SubcommandHeaderMessages {
    pub msg: String,
    pub good_msg: String,
    pub bad_msg: String,
}

impl SubcommandHeaderMessages {
    pub fn new(key: &str) -> Self {
        let msg = LocalText::new(key).fmt().to_string();
        let good_key = format!("{key}-good");
        let good_msg = LocalText::new(good_key.as_str()).fmt();
        let bad_key = format!("{key}-bad");
        let bad_msg = LocalText::new(bad_key.as_str()).fmt();
        Self {
            msg,
            good_msg,
            bad_msg,
        }
    }
}
