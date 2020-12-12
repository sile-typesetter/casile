use crate::config::CONFIG;
use crate::i18n::LOCALES;
use crate::*;

use subprocess::Exec;

/// Exectute some set of argumets as a shell command with CaSILE related enviroment variables set.
pub fn run(command: Vec<String>, interactive: bool) -> Result<()> {
    crate::header("shell-header");
    let locales = LOCALES.read()?;
    let locale = locales[0].to_string();
    let lang: &str = &[&locale.replace("-", "_"), "utf8"].join(".");
    let mut process = Exec::cmd("zsh").env("LANG", lang);
    if CONFIG.get_bool("debug")? {
        process = process.env("CASILE_DEBUG", "true").arg("-x");
    };
    let process = if interactive {
        process.arg("-i")
    } else {
        process.arg("-c").arg(command.join(" "))
    };
    process.join()?;
    Ok(())
}
