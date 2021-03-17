use clap::{FromArgMatches, IntoApp};

use casile::cli::{Cli, Subcommand};
use casile::config::CONF;
use casile::{make, setup, status};
use casile::{Result, VERSION};

fn main() -> Result<()> {
    CONF.defaults()?;
    CONF.merge_env()?;
    CONF.merge_files()?;
    let app = Cli::into_app().version(VERSION);
    let matches = app.get_matches();
    let args = Cli::from_arg_matches(&matches);
    CONF.merge_args(&args)?;
    casile::show_welcome();
    let ret = match args.subcommand {
        Subcommand::Make { target } => make::run(target),
        Subcommand::Setup {} => setup::run(),
        Subcommand::Status {} => status::run(),
    };
    casile::show_outro();
    ret
}
