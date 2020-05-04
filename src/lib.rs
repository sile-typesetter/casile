pub mod cli;
pub mod i18n;
pub mod make;
pub mod setup;
pub mod shell;
use fluent::{FluentArgs, FluentValue};

pub static DEFAULT_LOCALE: &'static str = "en-US";

#[derive(Debug)]
pub struct Config {
    pub version: String,
    pub verbose: bool,
    pub debug: bool,
    pub locale: i18n::Locale,
}

pub fn header(config: &crate::Config, key: &str) {
    let mut args = FluentArgs::new();
    args.insert("version", FluentValue::from(config.version.as_str()));
    println!("==> {} \n", config.locale.translate("welcome", Some(&args)));
    println!("--> {} \n", config.locale.translate(key, None));
}
