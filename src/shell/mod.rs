use crate::CONFIG;
use std::error;
use subprocess::Exec;

/// Pass command string through to a shell or launch interactive shell
pub fn run(command: Vec<String>) -> Result<(), Box<dyn error::Error>> {
    crate::header("shell-header");
    let mut process = Exec::shell(command.join(" "));
    if CONFIG.get_bool("debug")? {
        process = process.env("DEBUG", "true");
    };
    process.join()?;
    Ok(())
}
