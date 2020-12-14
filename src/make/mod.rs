use crate::*;

use subprocess::Exec;

/// Execute GNU Make on given target
pub fn run(target: Vec<String>) -> Result<()> {
    if !status::is_setup().unwrap() {
        return Err(Error::new("status-bad").into());
    }
    crate::header("make-header");
    let mut process = Exec::cmd("make").args(&target);
    if CONF.get_bool("debug")? {
        process = process.env("DEBUG", "true");
    };
    process.join()?;
    Ok(())
}
