use casile::cli::{Cli, Subcommand};
use casile::config::CONFIG;
use casile::{make, setup, shell};
use clap::{FromArgMatches, IntoApp};
use std::error;

fn main() -> Result<(), Box<dyn error::Error>> {
    let version = env!("VERGEN_SEMVER_LIGHTWEIGHT");
    let app = Cli::into_app().version(version);
    let matches = app.get_matches();
    let args = Cli::from_arg_matches(&matches);
    CONFIG.from_args(&args)?;
    CONFIG.set_str("version", version)?;
    casile::show_welcome();
    match args.subcommand {
        Subcommand::Make { target } => make::run(target),
        Subcommand::Setup { path } => setup::run(path),
        Subcommand::Shell { command } => shell::run(command),
    }
}
