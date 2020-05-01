use std::{io, vec};

pub fn run(config: crate::Config, _target: vec::Vec<String>) -> io::Result<()> {
    println!("{}", config.locale.translate("debug-make"));
    Ok(())
}
