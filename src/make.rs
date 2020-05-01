use std::error;

pub fn run(config: &crate::Config, input: Vec<String>) -> Result<(), Box<dyn error::Error>> {
    crate::header(config, "make-header");
    let mut cmd: Vec<String> = Vec::new();
    cmd.push(String::from("make"));
    if !config.debug {
        cmd.push(String::from("DEBUG=true"))
    }
    cmd.extend(input);
    crate::run_shell(config, cmd);
    Ok(())
}
