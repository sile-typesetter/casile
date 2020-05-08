use casile::cli::{Cli, Subcommand};
use casile::config::CONFIG;
use casile::VERSION;
use casile::{make, setup, shell};
use clap::{FromArgMatches, IntoApp};
use std::error;

fn main() -> Result<(), Box<dyn error::Error>> {
    let app = Cli::into_app().version(VERSION);
    let matches = app.get_matches();
    let args = Cli::from_arg_matches(&matches);
    CONFIG.defaults()?;
    CONFIG.from_env()?;
    CONFIG.from_args(&args)?;
    casile::show_welcome();
    match args.subcommand {
        Subcommand::Make { target } => make::run(target),
        Subcommand::Setup { path } => setup::run(path),
        Subcommand::Shell {
            command,
            interactive,
        } => shell::run(command, interactive),
    }
}
