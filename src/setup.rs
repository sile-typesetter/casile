use git2::Repository;
use std::{error, fs, io, path};

pub fn run(config: &crate::Config, path: path::PathBuf) -> Result<(), Box<dyn error::Error>> {
    let metadata = fs::metadata(&path)?;
    match metadata.is_dir() {
        true => match Repository::open(path) {
            Ok(_repo) => Ok(
                crate::header(config, "debug-setup")
            ),
            Err(_error) => Err(Box::new(io::Error::new(
                io::ErrorKind::InvalidInput,
                config.locale.translate("setup-not-git"),
            ))),
        },
        false => Err(Box::new(io::Error::new(
            io::ErrorKind::InvalidInput,
            config.locale.translate("setup-not-dir"),
        ))),
    }
}
