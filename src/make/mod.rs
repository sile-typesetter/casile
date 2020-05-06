use std::error;
use subprocess::Exec;

/// Execute GNU Make on given target
pub fn run(config: &crate::Settings, target: Vec<String>) -> Result<(), Box<dyn error::Error>> {
    crate::header(config, "make-header");
    let mut process = Exec::cmd("make").args(&target);
    if config.debug {
        process = process.env("DEBUG", "true");
    };
    process.join()?;
    Ok(())
}
