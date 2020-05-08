use crate::cli::Cli;
use std::{error, sync};

lazy_static! {
    pub static ref CONFIG: sync::RwLock<config::Config> =
        sync::RwLock::new(config::Config::default());
}

impl CONFIG {
    pub fn from_args(&self, args: &Cli) -> Result<(), Box<dyn error::Error>> {
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
    pub fn init(args: &Cli) -> Settings {
        Settings {
            verbose: args.verbose,
            debug: args.debug,
        }
    }
}
