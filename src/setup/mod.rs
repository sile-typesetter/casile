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
            Err(_error) => Err(Box::new(io::Error::new(
                io::ErrorKind::InvalidInput,
                "", // config.locale.translate("setup-error-not-git", None),
            ))),
        },
        false => Err(Box::new(io::Error::new(
            io::ErrorKind::InvalidInput,
            "", // config.locale.translate("setup-error-not-dir", None),
        ))),
    }
}
