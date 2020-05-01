use std::error;

pub fn run(config: &crate::Config, input: Vec<String>) -> Result<(), Box<dyn error::Error>> {
    crate::header(config, "debug-shell");
    crate::run_shell(config, input);
    Ok(())
}
