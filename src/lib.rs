#[macro_use]
extern crate lazy_static;

use fluent::{FluentArgs, FluentValue};
use i18n::LocalText;
use std::{error, sync};

pub mod cli;
pub mod i18n;
pub mod make;
pub mod setup;
pub mod shell;

pub static DEFAULT_LOCALE: &'static str = "en-US";

lazy_static! {
    pub static ref CASILE: sync::RwLock<config::Config> =
        sync::RwLock::new(config::Config::default());
}

impl CASILE {
    pub fn from_args(&self, args: &cli::Cli) -> Result<(), Box<dyn error::Error>> {
        self.set_bool("debug", args.debug)?;
        self.set_bool("verbose", args.verbose)?;
        let language = match &args.language {
            Some(language) => language,
            None => crate::DEFAULT_LOCALE,
        };
        self.set_str("language", &language)?;
        Ok(())
    }

    pub fn set_bool(&self, key: &str, val: bool) -> Result<(), Box<dyn error::Error>> {
        self.write().unwrap().set(key, val)?;
        Ok(())
    }

    pub fn get_bool(&self, key: &str) -> Result<bool, Box<dyn error::Error>> {
        Ok(self.read().unwrap().get_bool(key)?)
    }

    pub fn set_str(&self, key: &str, val: &str) -> Result<(), Box<dyn error::Error>> {
        self.write().unwrap().set(key, val)?;
        Ok(())
    }

    pub fn get_string(&self, key: &str) -> Result<String, Box<dyn error::Error>> {
        Ok(self.read().unwrap().get_str(key)?)
    }
}

#[derive(Debug)]
pub struct Settings {
    pub verbose: bool,
    pub debug: bool,
}

impl Settings {
    pub fn init(args: &cli::Cli) -> Settings {
        Settings {
            verbose: args.verbose,
            debug: args.debug,
        }
    }
}

pub fn show_welcome() {
    let mut args = FluentArgs::new();
    let version = CASILE.get_string("version").unwrap();
    args.insert("version", FluentValue::from(version));
    let welcome = LocalText::new("welcome");
    eprintln!("==> {} \n", welcome.fmt(Some(&args)));
}

pub fn header(key: &str) {
    let text = LocalText::new(key);
    eprintln!("--> {} \n", text.fmt(None));
}
