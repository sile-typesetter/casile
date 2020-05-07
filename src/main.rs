use casile::cli::{Cli, Subcommand};
use casile::i18n::_t;
// use casile::i18n::FLUENT;
use casile::CASILE;
use casile::{make, setup, shell};
use clap::{FromArgMatches, IntoApp};
use std::error;

fn main() -> Result<(), Box<dyn error::Error>> {
    let version = env!("VERGEN_SEMVER_LIGHTWEIGHT");
    let app = Cli::into_app().version(version);
    let matches = app.get_matches();
    let args = Cli::from_arg_matches(&matches);
    CASILE.from_args(&args)?;
    CASILE.set_str("version", version)?;
    casile::show_welcome();
    foo().unwrap();
    // eprintln!("After {:#?}", FLUENT.read().unwrap());
    match args.subcommand {
        Subcommand::Make { target } => make::run(target),
        Subcommand::Setup { path } => setup::run(path),
        Subcommand::Shell { command } => shell::run(command),
    }
}

fn foo() -> Result<(), Box<dyn error::Error>> {
    // eprintln!("BBBBBetter = {:?}", CASILE.read()?.get_str("version"));
    // _t("welcome");
    Ok(())
}
