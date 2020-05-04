use std::error;
use subprocess::Exec;

pub fn run(config: &crate::Config, target: Vec<String>) -> Result<(), Box<dyn error::Error>> {
    crate::header(config, "make-header");
    let mut process = Exec::cmd("make").args(&target);
    if config.debug {
        process = process.env("DEBUG", "true");
    };
    process.join()?;
    Ok(())
}
