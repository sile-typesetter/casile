use crate::i18n::LocalText;
use git2::Repository;
use std::{error, fs, io, path, result};

type Result<T> = result::Result<T, Box<dyn error::Error>>;

/// Setup CaSILE config file(s) on new repository
pub fn run(path: path::PathBuf) -> Result<()> {
    crate::header("setup-header");
    let metadata = fs::metadata(&path)?;
    match metadata.is_dir() {
        true => match Repository::open(path) {
            Ok(_repo) => Ok(()),
            Err(_error) => {
                let error_text = LocalText::new("setup-error-not-git");
                Err(Box::new(io::Error::new(
                    io::ErrorKind::InvalidInput,
                    error_text.fmt(None),
                )))
            }
        },
        false => {
            let error_text = LocalText::new("setup-error-not-dir");
            Err(Box::new(io::Error::new(
                io::ErrorKind::InvalidInput,
                error_text.fmt(None),
            )))
        }
    }
}
