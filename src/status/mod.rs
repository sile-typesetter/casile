use crate::i18n::LocalText;
use git2::Repository;
use std::sync::{Arc, RwLock};
use std::{env, error, path, result, thread};

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
    rayon::scope(|s| {
        s.spawn(|_| {
            let repo = is_repo(&env::current_dir().unwrap()).unwrap();
            results.write().unwrap().push(repo);
        });
    });
    let ret = results.read().unwrap().iter().all(|&v| v);
    eprintln!(
        "{}",
        LocalText::new(if ret { "status-good" } else { "status-bad" }).fmt()
    );
    Ok(ret)
}

/// Are we in a git repo?
pub fn is_repo(path: &path::PathBuf) -> Result<bool> {
    let ret = Repository::discover(path).is_ok();
    eprintln!(
        "{} {}",
        LocalText::new("status-is-repo").fmt(),
        LocalText::new(if ret { "status-true" } else { "status-false" }).fmt()
    );
    Ok(ret)
}
