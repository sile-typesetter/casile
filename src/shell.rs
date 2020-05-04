use std::error;

pub fn run(config: &crate::Config, command: Vec<String>) -> Result<(), Box<dyn error::Error>> {
    crate::header(config, "shell-header");
    crate::run_shell(config, command);
    Ok(())
}
