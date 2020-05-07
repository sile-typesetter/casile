use std::error;
use subprocess::Exec;

/// Execute GNU Make on given target
pub fn run(target: Vec<String>) -> Result<(), Box<dyn error::Error>> {
    crate::header("make-header");
    let mut process = Exec::cmd("make").args(&target);
    if crate::CASILE.get_bool("debug")? {
        process = process.env("DEBUG", "true");
    };
    process.join()?;
    Ok(())
}
