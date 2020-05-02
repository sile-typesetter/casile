use casile::{cli::*, i18n};
use clap::{FromArgMatches, IntoApp};
use std::error;

fn main() -> Result<(), Box<dyn error::Error>> {
    let app = Cli::into_app().version(env!("VERGEN_SEMVER"));
    let matches = app.get_matches();
    let args = Cli::from_arg_matches(&matches);
    let config = casile::Config {
        verbose: args.verbose,
        debug: args.debug,
        locale: i18n::Locale::negotiate(args.language),
    };
    match args.subcommand {
        Subcommand::Make { target } => casile::make::run(&config, target),
        Subcommand::Setup { path } => casile::setup::run(&config, path),
        Subcommand::Other(input) => casile::shell::run(&config, input),
    }
}
