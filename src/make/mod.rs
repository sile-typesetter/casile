use crate::i18n::LocalText;
use crate::*;

use colored::Colorize;
use itertools::Itertools;
use regex::Regex;
use std::io::prelude::*;
use std::{ffi::OsString, io};
use subprocess::{Exec, ExitStatus, Redirection};

// FTL: help-subcommand-make
/// Build specified target(s)
pub fn run(target: Vec<String>) -> Result<()> {
    if !status::is_setup().unwrap() {
        return Err(Error::new("status-bad").into());
    }
    crate::header("make-header");
    let mut makeflags: Vec<OsString> = Vec::new();
    let cpus = num_cpus::get();
    makeflags.push(OsString::from(format!("--jobs={}", cpus)));
    let mut makefiles: Vec<OsString> = Vec::new();
    makefiles.push(OsString::from("-f"));
    makefiles.push(OsString::from(format!(
        "{}{}",
        CONFIGURE_DATADIR, "rules/casile.mk"
    )));
    makefiles.push(OsString::from("-f"));
    makefiles.push(OsString::from(format!(
        "{}{}",
        CONFIGURE_DATADIR, "rules/rules.mk"
    )));
    let mut process = Exec::cmd("make")
        .args(&makeflags)
        .args(&makefiles)
        .args(&target);
    let mut process = Exec::cmd("make").args(&target);
    if CONF.get_bool("debug")? {
        process = process.env("DEBUG", "true");
    };
    process.join()?;
    Ok(())
}

fn dump_backlog(backlog: &Vec<String>) {
    let start = LocalText::new("make-backlog-start").fmt();
    eprintln!("{} {}", "┖┄".cyan(), start);
    for line in backlog.iter() {
        eprintln!("{}", line);
    }
    let end = LocalText::new("make-backlog-end").fmt();
    eprintln!("{} {}", "┎┄".cyan(), end);
}

fn report_line(line: &str) {
    eprintln!("{} {}", "┠╎".cyan(), line.dimmed());
}

fn report_start(target: &str) {
    let text = LocalText::new("make-report-start")
        .arg("target", target.white().bold())
        .fmt();
    eprintln!("{} {}", "┠┄".cyan(), text.yellow());
}

fn report_end(target: &str) {
    let text = LocalText::new("make-report-end")
        .arg("target", target.white().bold())
        .fmt();
    eprintln!("{} {}", "┠┄".cyan(), text.green());
}

fn report_fail(target: &str) {
    let text = LocalText::new("make-report-fail")
        .arg("target", target.white().bold())
        .fmt();
    eprintln!("{} {}", "┠┄".cyan(), text.red());
}
