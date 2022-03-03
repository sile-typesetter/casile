use clap::{FromArgMatches, IntoApp};

use casile::cli::{Cli, Commands};
use casile::config::CONF;
use casile::{make, setup, status};
use casile::{Result, VERSION};

fn main() -> Result<()> {
    CONF.defaults()?;
    CONF.merge_env()?;
    CONF.merge_files()?;
    let app = Cli::command().infer_subcommands(true).version(VERSION);
    let matches = app.get_matches();
    let args = Cli::from_arg_matches(&matches).expect("Unable to parse arguments");
    CONF.merge_args(&args)?;
    casile::show_welcome();
    let ret = match args.subcommand {
        Commands::Make { target } => make::run(target),
        Commands::Setup {} => setup::run(),
        Commands::Status {} => status::run(),
    };
    casile::show_outro();
    ret
}
