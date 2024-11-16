use crate::i18n::LocalText;
use crate::ui::*;
use crate::*;

use console::style;
use git2::{Repository, Status};
use git_warp_time::reset_mtimes;
use std::io::prelude::*;
use std::sync::{Arc, RwLock};
use std::{fs, io, path};
use subprocess::{Exec, NullFile, Redirection};

// FTL: help-subcommand-setup
/// Setup a publishing project for use with CaSILE
pub fn run() -> Result<()> {
    let subcommand_status = CASILEUI.new_subcommand("setup");
    let project = &CONF.get_string("project")?;
    let metadata = fs::metadata(project)?;
    let ret = match metadata.is_dir() {
        true => match is_repo()? {
            true => {
                regen_dotfiles(get_repo()?)?;
                configure_short_shas(get_repo()?)?;
                if is_deep()? {
                    warp_time(get_repo()?)?;
                }
                Ok(())
            }
            false => Err(Box::new(io::Error::new(
                io::ErrorKind::InvalidInput,
                LocalText::new("setup-error-not-git").fmt(),
            ))),
        },
        false => Err(Box::new(io::Error::new(
            io::ErrorKind::InvalidInput,
            LocalText::new("setup-error-not-dir").fmt(),
        ))),
    };
    subcommand_status.end(ret.is_ok());
    Ok(ret?)
}

/// Evaluate whether this project is properly configured
pub fn is_setup() -> Result<bool> {
    let subcommand_status = CASILEUI.new_subcommand("is-setup");
    let results = Arc::new(RwLock::new(Vec::new()));

    // First round of tests, entirely independent
    rayon::scope(|s| {
        s.spawn(|_| {
            let ret = is_repo().unwrap();
            results.write().unwrap().push(ret);
        });
        s.spawn(|_| {
            let ret = is_make_executable().unwrap();
            results.write().unwrap().push(ret);
        });
    });

    // Second round of tests, dependent on first set
    if results.read().unwrap().iter().all(|&v| v) {
        rayon::scope(|s| {
            s.spawn(|_| {
                let ret = is_not_casile_source().unwrap();
                results.write().unwrap().push(ret);
            });
            s.spawn(|_| {
                let ret = is_writable().unwrap();
                results.write().unwrap().push(ret);
            });
            s.spawn(|_| {
                let ret = is_make_gnu().unwrap();
                results.write().unwrap().push(ret);
            });
        });
    }

    let ret = results.read().unwrap().iter().all(|&v| v);
    subcommand_status.end(ret);
    Ok(ret)
}

/// Are we in a git repo?
pub fn is_repo() -> Result<bool> {
    let status = CASILEUI.new_check("setup-is-repo");
    let ret = get_repo().is_ok();
    status.end(ret);
    Ok(ret)
}

/// Is this repo a deep clone?
pub fn is_deep() -> Result<bool> {
    let status = CASILEUI.new_check("setup-is-deep");
    let ret = !get_repo()?.is_shallow();
    status.end(ret);
    Ok(ret)
}

/// Are we not in the CaSILE source repo?
pub fn is_not_casile_source() -> Result<bool> {
    let status = CASILEUI.new_check("setup-is-not-casile");
    let repo = get_repo()?;
    let workdir = repo.workdir().unwrap();
    let testfile = workdir.join("Makefile.am");
    let ret = fs::File::open(testfile).is_err();
    status.end(ret);
    Ok(ret)
}

/// Is the git repo we are in writable?
pub fn is_writable() -> Result<bool> {
    let status = CASILEUI.new_check("setup-is-writable");
    let repo = get_repo()?;
    let workdir = repo.workdir().unwrap();
    let testfile = workdir.join(".casile-write-test");
    let mut file = fs::File::create(&testfile)?;
    file.write_all(b"test")?;
    fs::remove_file(&testfile)?;
    let ret = true;
    status.end(ret);
    Ok(ret)
}

/// Check if we can execute the system's `make` utility
pub fn is_make_executable() -> Result<bool> {
    let status = CASILEUI.new_check("setup-is-make-executable");
    let ret = Exec::cmd("make")
        .arg("-v")
        .stdout(NullFile)
        .stderr(NullFile)
        .join()
        .is_ok();
    status.end(ret);
    Ok(ret)
}

/// Check that the system's `make` utility is GNU Make
pub fn is_make_gnu() -> Result<bool> {
    let status = CASILEUI.new_check("setup-is-make-gnu");
    let out = Exec::cmd("make")
        .arg("-v")
        .stdout(Redirection::Pipe)
        .stderr(NullFile)
        .capture()?
        .stdout_str();
    let ret = out.starts_with("GNU Make 4.");
    status.end(ret);
    Ok(ret)
}

fn regen_dotfiles(repo: Repository) -> Result<()> {
    let targets = [".editorconfig", ".gitignore", ".luacheckrc", ".luarc.json"];
    let make_targets: Vec<String> = targets.iter().map(|&x| x.into()).collect();
    make::run(make_targets)?;
    let mut index = repo.index()?;
    targets.iter().for_each(|&target| {
        let path = path::Path::new(target);
        index.add_path(path).unwrap();
    });
    let oid = index.write_tree()?;
    let fresh = targets.iter().fold(true, |acc, &target| {
        let path = path::Path::new(target);
        acc && repo.status_file(path) == Ok(Status::CURRENT)
    });
    if fresh {
        let status = CASILEUI.new_check("setup-dotfiles-fresh");
        status.end(true);
        Ok(())
    } else {
        let status = CASILEUI.new_check("setup-dotfiles-committing");
        match commit(repo, oid, "Refresh dotfiles") {
            Ok(_) => {
                index.write()?;
                status.end(true);
                Ok(())
            }
            Err(error) => {
                status.end(false);
                Err(Box::new(error))
            }
        }
    }
}

fn warp_time(repo: Repository) -> Result<()> {
    let opts = git_warp_time::Options::new();
    let text = LocalText::new("setup-warp-time").fmt();
    eprintln!("{} {}", style("┠┄").cyan(), text);
    let files = reset_mtimes(repo, opts)?;
    if CONF.get_bool("verbose")? {
        for file in files.iter() {
            let path = file.clone().into_os_string().into_string().unwrap();
            let text = LocalText::new("setup-warp-time-file")
                .arg("path", style(path).white().bold())
                .fmt();
            eprintln!("{} {}", style("┠┄").cyan(), text);
        }
    }
    Ok(())
}

fn configure_short_shas(repo: Repository) -> Result<()> {
    let text = LocalText::new("setup-short-shas").fmt();
    eprintln!("{} {}", style("┠┄").cyan(), text);
    let mut conf = repo.config()?;
    Ok(conf.set_i32("core.abbrev", 7)?)
}
