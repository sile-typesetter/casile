use crate::config::CONFIG;
use crate::i18n::LOCALES;
use std::{error, result};
use subprocess::Exec;

type Result<T> = result::Result<T, Box<dyn error::Error>>;

pub fn run(command: Vec<String>, interactive: bool) -> Result<()> {
    crate::header("shell-header");
    let locales = LOCALES.read().unwrap();
    let locale = locales[0].to_string();
    let lang: &str = &[&locale.replace("-", "_"), "utf8"].join(".");
    let mut process = Exec::cmd("zsh").env("LANG", lang);
    if CONFIG.get_bool("debug")? {
        process = process.env("CASILE_DEBUG", "true").arg("-x");
    };
    if interactive {
        process = process.arg("-i")
    } else {
        process = process.arg("-c").arg(command.join(" "));
    }
    process.join()?;
    Ok(())
}
