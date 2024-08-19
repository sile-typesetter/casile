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

#[ignore] // Test assumes stderr, indicatif is in some paged mode that doesn't reach there any more
#[test]
fn output_is_localized() -> Result<()> {
    let mut cmd = Command::cargo_bin(BIN_NAME)?;
    cmd.arg("-l").arg("tr").arg("status");
    cmd.assert()
        .stderr(predicate::str::contains("hoş geldiniz"));
    Ok(())
}

#[test]
fn setup_path_exists() -> Result<()> {
    let mut cmd = Command::cargo_bin(BIN_NAME)?;
    cmd.arg("-P").arg("not_a_dir").arg("setup");
    cmd.assert()
        .failure()
        .stderr(predicate::str::contains("No such file or directory"));
    Ok(())
}

// #[test]
// fn fail_on_casile_sources() -> Result<()> {
//     let mut cmd = Command::cargo_bin(BIN_NAME)?;
//     cmd.arg("-p").arg("./").arg("setup");
//     cmd.assert()
//         .failure()
//         .stderr(predicate::str::contains("Make failed to parse or execute"));
//     Ok(())
// }
