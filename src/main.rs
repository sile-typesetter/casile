use clap::{FromArgMatches, IntoApp};

use casile::cli::{Cli, Subcommand};
use casile::config::CONF;
use casile::{make, setup, status};
use casile::{Result, VERSION};

fn main() -> Result<()> {
    let app = Cli::into_app().version(VERSION);
    let matches = app.get_matches();
    let args = Cli::from_arg_matches(&matches);
    CONF.defaults()?;
    CONF.from_env()?;
    CONF.from_args(&args)?;
    casile::show_welcome();
    match args.subcommand {
        Subcommand::Make { target } => make::run(target),
        Subcommand::Setup { path } => setup::run(path),
        Subcommand::Status {} => status::run(),
    }
}
