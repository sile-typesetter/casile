#[macro_use]
extern crate lazy_static;

use crate::config::CONFIG;
use fluent::{FluentArgs, FluentValue};
use i18n::LocalText;

pub mod cli;
pub mod config;
pub mod i18n;
pub mod make;
pub mod setup;
pub mod shell;

pub static DEFAULT_LOCALE: &'static str = "en-US";

pub fn show_welcome() {
    let mut args = FluentArgs::new();
    let version = CONFIG.get_string("version").unwrap();
    args.insert("version", FluentValue::from(version));
    let welcome = LocalText::new("welcome");
    eprintln!("==> {} \n", welcome.fmt(Some(&args)));
}

pub fn header(key: &str) {
    let text = LocalText::new(key);
    eprintln!("--> {} \n", text.fmt(None));
}
