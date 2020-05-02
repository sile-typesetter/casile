use casile::{cli::*, i18n};
use clap::Clap;
use std::{error};

fn main() -> Result<(), Box<dyn error::Error>> {
    let args = Cli::parse();
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
