use git2::Repository;
use std::{fs, io, path};

pub fn run(config: crate::Config, path: path::PathBuf) -> io::Result<()> {
    let metadata = fs::metadata(&path)?;
    match metadata.is_dir() {
        true => match Repository::open(path) {
            Ok(_repo) => Ok(println!("{}", config.locale.translate("debug-setup"))),
            Err(_error) => Err(io::Error::new(
                io::ErrorKind::InvalidInput,
                config.locale.translate("setup-not-git"),
            )),
        },
        false => Err(io::Error::new(
            io::ErrorKind::InvalidInput,
            config.locale.translate("setup-not-dir"),
        )),
    }
}
