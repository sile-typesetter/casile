pub mod cli;
pub mod i18n;
pub mod make;
pub mod setup;
pub mod shell;

pub static DEFAULT_LOCALE: &'static str = "en-US";

#[derive(Debug)]
pub struct Config {
    pub verbose: bool,
    pub debug: bool,
    pub locale: i18n::Locale,
}

pub fn header(config: &crate::Config, key: &str) {
    println!("\n==> {} \n", config.locale.translate(key, None));
}
