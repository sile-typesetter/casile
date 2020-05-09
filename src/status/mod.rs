use std::{error, result};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

/// Dump what we know about the repo
pub fn run() -> Result<()> {
    Ok(())
}
