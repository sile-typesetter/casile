use casile::cli::{Cli, Subcommand};
use casile::i18n::_t;
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
    let config = casile::Settings::init(&args);
    casile::show_welcome(&config);
    foo().unwrap();
    match args.subcommand {
        Subcommand::Make { target } => make::run(&config, target),
        Subcommand::Setup { path } => setup::run(&config, path),
        Subcommand::Shell { command } => shell::run(&config, command),
    }
}

fn foo() -> Result<(), Box<dyn error::Error>> {
    // eprintln!("BBBBBetter = {:?}", CASILE.read()?.get_str("version"));
    _t("welcome");
    Ok(())
}
