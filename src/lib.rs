use fluent::{FluentArgs, FluentValue};

pub mod cli;
pub mod i18n;
pub mod make;
pub mod setup;
pub mod shell;

pub static DEFAULT_LOCALE: &'static str = "en-US";

#[derive(Debug)]
pub struct Config {
    version: String,
    verbose: bool,
    debug: bool,
    locale: i18n::Locale,
}

impl Config {
    pub fn init(args: &cli::Cli, version: String) -> Config {
        Config {
            version,
            verbose: args.verbose,
            debug: args.debug,
            locale: i18n::Locale::negotiate(&args.language),
        }
    }
}

pub fn show_welcome(config: &crate::Config) {
    let mut args = FluentArgs::new();
    args.insert("version", FluentValue::from(config.version.as_str()));
    eprintln!("==> {} \n", config.locale.translate("welcome", Some(&args)));
}

pub fn header(config: &crate::Config, key: &str) {
    eprintln!("--> {} \n", config.locale.translate(key, None));
}
