use crate::i18n::LocalText;
use crate::ui::*;
use crate::*;

use console::style;
use regex::Regex;
use std::io::prelude::*;
use std::path::PathBuf;
use std::{ffi::OsString, io};
use subprocess::{Exec, ExitStatus, Redirection};

// FTL: help-subcommand-make
/// Build specified target(s)
pub fn run(target: Vec<String>) -> Result<()> {
    setup::is_setup()?;
    let mut subcommand_status = CASILEUI.new_subcommand("make");
    let mut makeflags: Vec<OsString> = Vec::new();
    let cpus = &num_cpus::get().to_string();
    makeflags.push(OsString::from(format!("--jobs={cpus}")));
    let mut makefiles: Vec<OsString> = Vec::new();
    let mut rules = status::get_rules()?;
    rules.insert(
        0,
        PathBuf::from(format!("{}/rules/casile.mk", CONFIGURE_DATADIR)),
    );
    rules.push(PathBuf::from(format!(
        "{}/rules/rules.mk",
        CONFIGURE_DATADIR
    )));
    for rule in rules {
        makefiles.push(OsString::from("-f"));
        let p = rule.into_os_string();
        makefiles.push(p);
    }
    let mut targets: Vec<_> = target.into_iter().collect();
    if targets.is_empty() {
        targets.push(String::from("default"));
    }
    let is_gha = status::status_is_gha()?;
    let is_glc = status::status_is_glc()?;
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
        .env("BUILDDIR", CONF.get_string("builddir")?)
        .env("CASILE_CLI", "true")
        .env("CASILE_JOBS", cpus)
        .env("CASILEDIR", CONFIGURE_DATADIR)
        .env("CONTAINERIZED", status::is_container().to_string())
        .env("LANGUAGE", locale_to_language(CONF.get_string("language")?))
        .env("PROJECT", gitname)
        .env("PROJECTDIR", CONF.get_string("project")?)
        .env("PROJECTVERSION", git_version);
    if CONF.get_bool("debug")? {
        // || targets.contains(&"-p".into())
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
    let mut buf = io::BufReader::new(popen.stdout.as_mut().unwrap());
    let seps = Regex::new(r"\x1C").unwrap(); // U+001C File Separator character
    let mut line = Vec::new();
    while buf.read_until(b'\n', &mut line).unwrap_or(0) > 0 {
        // Lossy because LaTeX's xindy package is throwing a broken UTF-8 prefix at us
        let text = String::from_utf8_lossy(&line).into_owned();
        let text = text.trim_end_matches(['\n', '\r']);
        let fields: Vec<&str> = seps.splitn(text, 4).collect();
        match fields[0] {
            "CASILE" => match fields[1] {
                "PRE" => {
                    let target = fields[2].to_owned();
                    let target = MakeTarget::new(&target);
                    subcommand_status.new_target(target);
                }
                "STDOUT" => {
                    let target = fields[2].to_owned();
                    let target = MakeTarget::new(&target);
                    let target_status = subcommand_status.get_target(target.clone());
                    match target_status {
                        Some(target_status) => {
                            target_status.stdout(fields[3]);
                        }
                        None => {
                            let text = LocalText::new("make-error-unknown-target")
                                .arg("target", style(target).white())
                                .fmt();
                            subcommand_status.error(format!("{}", style(text).red()));
                            subcommand_status.error(fields[3].to_string());
                        }
                    }
                }
                "STDERR" => {
                    let target = fields[2].to_owned();
                    let target = MakeTarget::new(&target);
                    let target_status = subcommand_status.get_target(target.clone());
                    match target_status {
                        Some(target_status) => {
                            target_status.stderr(fields[3]);
                        }
                        None => {
                            let text = LocalText::new("make-error-unknown-target")
                                .arg("target", style(target).white())
                                .fmt();
                            subcommand_status.error(format!("{}", style(text).red()));
                            subcommand_status.error(fields[3].to_string());
                        }
                    }
                }
                "POST" => {
                    let target = fields[2].to_owned();
                    let target = MakeTarget::new(&target);
                    let target_status = subcommand_status.get_target(target);
                    match target_status {
                        Some(target_status) => match fields[3] {
                            "0" => {
                                target_status.pass();
                            }
                            val => {
                                let code = val.parse().unwrap_or(1);
                                target_status.fail(code);
                            }
                        },
                        None => {
                            let text = LocalText::new("make-error-unknown-target").fmt();
                            subcommand_status.error(format!("{}", style(text).red()));
                        }
                    }
                }
                _ => {
                    let errmsg = LocalText::new("make-error-unknown-code").fmt();
                    subcommand_status.error(format!("Make wrapper failed: {errmsg}"));
                }
            },
            _ => {
                subcommand_status.error(format!(
                    "Output not captured by target wrapper: {:?}",
                    fields
                ));
            }
        }
        line.clear();
    }
    let status = popen.wait();
    let ret = match status {
        Ok(ExitStatus::Exited(code)) => match code {
            0 => Ok(()),
            1 => Err(Box::new(io::Error::new(
                io::ErrorKind::InvalidInput,
                LocalText::new("make-error-unfinished").fmt(),
            ))),
            2 => Err(Box::new(io::Error::new(
                io::ErrorKind::InvalidInput,
                LocalText::new("make-error-build").fmt(),
            ))),
            3 => Err(Box::new(io::Error::new(
                io::ErrorKind::InvalidInput,
                LocalText::new("make-error-target").fmt(),
            ))),
            137 => Err(Box::new(io::Error::new(
                io::ErrorKind::InvalidInput,
                LocalText::new("make-error-oom").fmt(),
            ))),
            _ => Err(Box::new(io::Error::new(
                io::ErrorKind::InvalidInput,
                LocalText::new("make-error-unknown").fmt(),
            ))),
        },
        _ => Err(Box::new(io::Error::new(
            io::ErrorKind::InvalidInput,
            LocalText::new("make-error").fmt(),
        ))),
    };
    subcommand_status.end(ret.is_ok());
    Ok(ret?)
}
