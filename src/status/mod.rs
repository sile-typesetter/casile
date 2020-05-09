use crate::i18n::LocalText;
use git2::Repository;
use std::{env, error, result};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

/// Dump what we know about the repo
pub fn run() -> Result<()> {
    crate::header("status-header");
    let ya = LocalText::new("status-true");
    let no = LocalText::new("status-false");
    eprintln!(
        "{} {}",
        LocalText::new("status-is-repo").fmt(),
        if is_repo()? { &ya } else { &no }.fmt()
    );
    eprintln!(
        "{}",
        LocalText::new(if is_setup()? {
            "setup-good"
        } else {
            "setup-bad"
        })
        .fmt()
    );
    Ok(())
}

/// Evaluate whether this project is properl configured
pub fn is_setup() -> Result<bool> {
    let mut checks: Vec<bool> = Vec::new();
    let is_repo = is_repo()?;
    checks.push(is_repo);
    Ok(checks.iter().all(|&v| v))
}

/// Are we in a git repo?
pub fn is_repo() -> Result<bool> {
    let cwd = env::current_dir()?;
    Repository::open(cwd)?;
    Ok(true)
}
