use casile::*;

use assert_cmd::prelude::*;
use predicates::prelude::*;
use std::process::Command;

static BIN_NAME: &str = "casile";

#[test]
fn outputs_version() -> Result<()> {
    let mut cmd = Command::cargo_bin(BIN_NAME)?;
    cmd.arg("--version");
    cmd.assert().stdout(predicate::str::starts_with("casile v"));
    Ok(())
}

#[test]
fn ouput_is_localized() -> Result<()> {
    let mut cmd = Command::cargo_bin(BIN_NAME)?;
    cmd.arg("-l").arg("tr").arg("setup");
    cmd.assert().stderr(predicate::str::contains("kurun artık"));
    Ok(())
}

#[test]
fn setup_path_exists() -> Result<()> {
    let mut cmd = Command::cargo_bin(BIN_NAME)?;
    cmd.arg("setup").arg("not_a_file");
    cmd.assert()
        .failure()
        .stderr(predicate::str::contains("No such file or directory"));
    Ok(())
}
