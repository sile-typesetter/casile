use crate::i18n::LocalText;
use crate::*;

use colored::Colorize;
use regex::Regex;
use std::io::prelude::*;
use std::{ffi::OsString, io};
use subprocess::{Exec, ExitStatus, Redirection};

// FTL: help-subcommand-make
/// Build specified target(s)
pub fn run(target: Vec<String>) -> Result<()> {
    setup::is_setup()?;
    show_header("make-header");
    let mut makeflags: Vec<OsString> = Vec::new();
    let cpus = &num_cpus::get().to_string();
    makeflags.push(OsString::from(format!("--jobs={cpus}")));
    let mut makefiles: Vec<OsString> = Vec::new();
    let rules = status::get_rules()?;
    makefiles.push(OsString::from("-f"));
    makefiles.push(OsString::from(format!(
        "{}{}",
        CONFIGURE_DATADIR, "/rules/casile.mk"
    )));
    for rule in rules {
        makefiles.push(OsString::from("-f"));
        let p = rule.into_os_string();
        makefiles.push(p);
    }
    makefiles.push(OsString::from("-f"));
    makefiles.push(OsString::from(format!(
        "{}{}",
        CONFIGURE_DATADIR, "/rules/rules.mk"
    )));
    let mut targets: Vec<_> = target.into_iter().collect();
    if targets.is_empty() {
        targets.push(String::from("default"));
    }
    let is_gha = status::is_gha()?;
    let is_glc = status::is_glc()?;
    if is_gha {
        targets.push(String::from("_gha"));
    }
    if is_glc {
        targets.push(String::from("_glc"));
    }
    if (is_gha || is_glc)
        && targets.first().unwrap() != "debug"
        && targets.first().unwrap() != ".gitignore"
    {
        targets.push(String::from("install-dist"));
    }
    let mut process = Exec::cmd("make")
        .args(&makeflags)
        .args(&makefiles)
        .args(&targets);
    let gitname = status::get_gitname()?;
    let git_version = status::get_git_version();
    process = process
        .env("CASILE_CLI", "true")
        .env("CASILE_JOBS", cpus)
        .env("CASILEDIR", CONFIGURE_DATADIR)
        .env("CONTAINERIZED", status::is_container().to_string())
        .env("LANGUAGE", locale_to_language(CONF.get_string("language")?))
        .env("PROJECT", gitname)
        .env("PROJECTDIR", CONF.get_string("path")?)
        .env("PROJECTVERSION", git_version);
    if CONF.get_bool("debug")? {
        process = process.env("DEBUG", "true");
    };
    if CONF.get_bool("quiet")? {
        process = process.env("QUIET", "true");
    };
    if CONF.get_bool("verbose")? || targets.contains(&"debug".into()) {
        process = process.env("VERBOSE", "true");
    };
    let repo = get_repo()?;
    let workdir = repo.workdir().unwrap();
    process = process.cwd(workdir);
    let process = process.stderr(Redirection::Merge).stdout(Redirection::Pipe);
    let mut popen = process.popen()?;
    let buf = io::BufReader::new(popen.stdout.as_mut().unwrap());
    let mut backlog: Vec<String> = Vec::new();
    let seps = Regex::new(r"").unwrap();
    let mut ret: u32 = 0;
    for line in buf.lines() {
        let text: &str =
            &line.unwrap_or_else(|_| String::from("INVALID UTF-8 FROM CHILD PROCESS STREAM"));
        let fields: Vec<&str> = seps.splitn(text, 4).collect();
        match fields[0] {
            "CASILE" => match fields[1] {
                "PRE" => report_start(fields[2]),
                "STDOUT" => {
                    if is_gha || is_glc {
                        println!("{}", fields[3]);
                    } else if CONF.get_bool("verbose")? {
                        report_line(fields[3]);
                    } else {
                        backlog.push(String::from(fields[3]));
                    }
                }
                "STDERR" => {
                    if CONF.get_bool("verbose")? {
                        report_line(fields[3]);
                    } else {
                        backlog.push(String::from(fields[3]));
                    }
                }
                "POST" => match fields[2] {
                    "0" => {
                        report_end(fields[3]);
                    }
                    val => {
                        report_fail(fields[3]);
                        ret = val.parse().unwrap_or(1);
                    }
                },
                _ => {
                    let errmsg = LocalText::new("make-error-unknown-code").fmt();
                    panic!("{}", errmsg)
                }
            },
            _ => backlog.push(String::from(fields[0])),
        }
    }
    let status = popen.wait();
    match status {
        Ok(ExitStatus::Exited(int)) => {
            let code = int + ret;
            match code {
                0 => {
                    if CONF.get_bool("debug")?
                        || targets.contains(&"debug".into())
                        || targets.contains(&"-p".into())
                    {
                        dump_backlog(&backlog)
                    };
                    Ok(())
                }
                1 => {
                    dump_backlog(&backlog);
                    Err(Box::new(io::Error::new(
                        io::ErrorKind::InvalidInput,
                        LocalText::new("make-error-unfinished").fmt(),
                    )))
                }
                2 => {
                    dump_backlog(&backlog);
                    Err(Box::new(io::Error::new(
                        io::ErrorKind::InvalidInput,
                        LocalText::new("make-error-build").fmt(),
                    )))
                }
                3 => {
                    if !CONF.get_bool("verbose")? {
                        dump_backlog(&backlog);
                    }
                    Err(Box::new(io::Error::new(
                        io::ErrorKind::InvalidInput,
                        LocalText::new("make-error-target").fmt(),
                    )))
                }
                137 => {
                    if !CONF.get_bool("verbose")? {
                        dump_backlog(&backlog);
                    }
                    Err(Box::new(io::Error::new(
                        io::ErrorKind::InvalidInput,
                        LocalText::new("make-error-oom").fmt(),
                    )))
                }
                _ => {
                    dump_backlog(&backlog);
                    Err(Box::new(io::Error::new(
                        io::ErrorKind::InvalidInput,
                        LocalText::new("make-error-unknown").fmt(),
                    )))
                }
            }
        }
        _ => Err(Box::new(io::Error::new(
            io::ErrorKind::InvalidInput,
            LocalText::new("make-error").fmt(),
        ))),
    }
}

fn dump_backlog(backlog: &[String]) {
    let start = LocalText::new("make-backlog-start").fmt();
    eprintln!("{} {}", "┖┄".cyan(), start);
    for line in backlog.iter() {
        eprintln!("{line}");
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
