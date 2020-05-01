use std::{io, vec};

pub fn run(config: crate::Config, input: vec::Vec<String>) -> io::Result<()> {
    println!("{}", config.locale.translate("debug-make"));
    let mut cmd: Vec<String> = Vec::new();
    cmd.push(String::from("make"));
    if !config.debug {
        cmd.push(String::from("DEBUG=true"))
    }
    cmd.extend(input);
    crate::run_shell(config, cmd);
    Ok(())
}
