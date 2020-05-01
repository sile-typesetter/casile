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
