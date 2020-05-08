#[macro_use]
extern crate lazy_static;

use crate::config::CONFIG;
use i18n::LocalText;

pub mod cli;
pub mod config;
pub mod i18n;
pub mod make;
pub mod setup;
pub mod shell;

pub static DEFAULT_LOCALE: &'static str = "en-US";
pub static VERSION: &'static str = env!("VERGEN_SEMVER_LIGHTWEIGHT");

pub fn show_welcome() {
    let welcome = LocalText::new("welcome").arg("version", VERSION);
    eprintln!("==> {} \n", welcome.fmt());
}

pub fn header(key: &str) {
    let text = LocalText::new(key);
    eprintln!("--> {} \n", text.fmt());
}
