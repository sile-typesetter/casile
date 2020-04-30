use std::{fs, io};
use std::io::prelude::*;

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

// https://github.com/projectfluent/fluent-rs/blob/c9e45651/fluent-fallback/examples/simple-fallback.rs#L38
pub fn read_file(path: &str) -> Result<String, io::Error> {
    let mut f = fs::File::open(path)?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}
