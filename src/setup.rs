use git2::Repository;
use std::{fs, io, path};

pub fn run(_config: crate::Config, path: path::PathBuf) -> io::Result<()> {
    let metadata = fs::metadata(&path)?;
    match metadata.is_dir() {
        true => match Repository::open(path) {
            Ok(_repo) => Ok(println!(
                "Run setup, “They said you were this great colossus!”"
            )),
            Err(_error) => Err(io::Error::new(io::ErrorKind::InvalidInput, "Not a git repo!")),
        },
        false => Err(io::Error::new(io::ErrorKind::InvalidInput, "Not a dir, Frank!")),
    }
}
