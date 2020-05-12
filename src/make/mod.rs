use crate::i18n::LocalText;
use crate::status;
use crate::Error;
use crate::CONFIG;
use std::{error, result};
use subprocess::Exec;

type Result<T> = result::Result<T, Box<dyn error::Error>>;

/// Execute GNU Make on given target
pub fn run(target: Vec<String>) -> Result<()> {
    if !status::is_setup().unwrap() {
        return Err(Error::new("status-bad").into());
    }
    crate::header("make-header");
    let mut process = Exec::cmd("make").args(&target);
    if CONFIG.get_bool("debug")? {
        process = process.env("DEBUG", "true");
    };
    process.join()?;
    Ok(())
}
