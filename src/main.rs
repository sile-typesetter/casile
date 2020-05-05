use casile::cli::{Cli, Subcommand};
use casile::{make, setup, shell};
use clap::{FromArgMatches, IntoApp};
use std::error;

fn main() -> Result<(), Box<dyn error::Error>> {
    let version = env!("VERGEN_SEMVER_LIGHTWEIGHT");
    let app = Cli::into_app().version(version);
    let matches = app.get_matches();
    let args = Cli::from_arg_matches(&matches);
    let config = casile::Config::init(&args, version.to_string());
    match args.subcommand {
        Subcommand::Make { target } => make::run(&config, target),
        Subcommand::Setup { path } => setup::run(&config, path),
        Subcommand::Shell { command } => shell::run(&config, command),
    }
}
