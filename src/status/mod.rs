use crate::i18n::LocalText;
use git2::Repository;
use std::io::prelude::*;
use std::sync::{Arc, RwLock};
use std::{env, error, fs, result};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

/// Dump what we know about the repo
pub fn run() -> Result<()> {
    crate::header("status-header");
    is_setup()?;
    Ok(())
}

/// Evaluate whether this project is pis_setup()?roperly configured
pub fn is_setup() -> Result<bool> {
    let results = Arc::new(RwLock::new(Vec::new()));
    // First round of tests, entirely independent
    rayon::scope(|s| {
        s.spawn(|_| {
            let repo = is_repo().unwrap();
            results.write().unwrap().push(repo);
        });
    });
    let ret = results.read().unwrap().iter().all(|&v| v);
    // Second round of tests, dependent on first set
    if ret {
        rayon::scope(|s| {
            s.spawn(|_| {
                let writable = is_writable().unwrap();
                results.write().unwrap().push(writable);
            });
        });
    }
    let ret = results.read().unwrap().iter().all(|&v| v);
    eprintln!(
        "{}",
        LocalText::new(if ret { "status-good" } else { "status-bad" }).fmt()
    );
    Ok(ret)
}

/// Are we in a git repo?
pub fn is_repo() -> Result<bool> {
    let cwd = env::current_dir()?;
    let ret = Repository::discover(cwd).is_ok();
    eprintln!(
        "{} {}",
        LocalText::new("status-is-repo").fmt(),
        fmt_t_f(ret)
    );
    Ok(ret)
}

/// Is the git repo we are in writable?
pub fn is_writable() -> Result<bool> {
    let cwd = env::current_dir()?;
    let repo = Repository::discover(cwd)?;
    let workdir = repo.workdir().unwrap();
    let testfile = workdir.join(".casile-write-test");
    let mut file = fs::File::create(&testfile)?;
    file.write_all(b"test")?;
    fs::remove_file(&testfile)?;
    let ret = true;
    eprintln!(
        "{} {}",
        LocalText::new("status-is-writable").fmt(),
        fmt_t_f(ret)
    );
    Ok(true)
}

/// Format a localized string just for true / false status prints
fn fmt_t_f(val: bool) -> String {
    let key = if val { "status-true" } else { "status-false" };
    LocalText::new(key).fmt()
}
