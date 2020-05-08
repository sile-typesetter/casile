use crate::cli::Cli;
use config::{Config, Environment};
use std::{error, result, sync};

lazy_static! {
    pub static ref CONFIG: sync::RwLock<Config> = sync::RwLock::new(Config::default());
}

type Result<T> = result::Result<T, Box<dyn error::Error>>;

impl CONFIG {
    pub fn defaults(&self) -> Result<()> {
        self.write()
            .unwrap()
            .set_default("debug", false)?
            .set_default("verbose", false)?
            .set_default("language", crate::DEFAULT_LOCALE)?;
        Ok(())
    }

    pub fn from_env(&self) -> Result<()> {
        self.write()
            .unwrap()
            .merge(Environment::with_prefix("casile"))?;
        Ok(())
    }

    pub fn from_args(&self, args: &Cli) -> Result<()> {
        if args.debug {
            self.set_bool("debug", true)?;
        }
        if args.verbose {
            self.set_bool("verbose", true)?;
        }
        if let Some(language) = &args.language {
            self.set_str("language", &language)?;
        };
        Ok(())
    }

    pub fn set_bool(&self, key: &str, val: bool) -> Result<()> {
        self.write().unwrap().set(key, val)?;
        Ok(())
    }

    pub fn get_bool(&self, key: &str) -> Result<bool> {
        Ok(self.read().unwrap().get_bool(key)?)
    }

    pub fn set_str(&self, key: &str, val: &str) -> Result<()> {
        self.write().unwrap().set(key, val)?;
        Ok(())
    }

    pub fn get_string(&self, key: &str) -> Result<String> {
        Ok(self.read().unwrap().get_str(key)?)
    }
}
