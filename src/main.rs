use casile::cli::{Cli, Subcommand};
use casile::i18n;
use casile::{make, setup, shell};
use clap::{FromArgMatches, IntoApp};
use std::error;

fn main() -> Result<(), Box<dyn error::Error>> {
    let version = env!("VERGEN_SEMVER_LIGHTWEIGHT");
    let app = Cli::into_app().version(version);
    let matches = app.get_matches();
    let args = Cli::from_arg_matches(&matches);
    let config = casile::Config {
        version: version.to_string(),
        verbose: args.verbose,
        debug: args.debug,
        locale: i18n::Locale::negotiate(args.language),
    };
    match args.subcommand {
        Subcommand::Make { target } => make::run(&config, target),
        Subcommand::Setup { path } => setup::run(&config, path),
        Subcommand::Shell { command } => shell::run(&config, command),
    }
}
