use clap::{Args, Command, FromArgMatches as _};

use casile::cli::{Cli, Commands};
use casile::config::CONF;
use casile::{make, run, setup, status};
use casile::{Result, VERSION};

use indicatif::MultiProgress;
use std::time::Instant;

fn main() -> Result<()> {
    let started = Instant::now();
    CONF.defaults()?;
    CONF.merge_env()?;
    CONF.merge_files()?;
    let cli = Command::new("casile").version(*VERSION);
    let cli = Cli::augment_args(cli);
    let matches = cli.get_matches();
    let args = Cli::from_arg_matches(&matches).expect("Unable to parse arguments");
    CONF.merge_args(&args)?;
    let subcommand_progress = MultiProgress::new();
    casile::show_welcome();
    let subcommand = Commands::from_arg_matches(&matches)?;
    let ret = match subcommand {
        Commands::Make { target } => make::run(subcommand_progress, target),
        Commands::Run { name, arguments } => run::run(subcommand_progress, name, arguments),
        Commands::Setup {} => setup::run(subcommand_progress),
        Commands::Status {} => status::run(subcommand_progress),
    };
    casile::show_farewell(started.elapsed());
    ret
}
