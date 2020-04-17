use structopt::StructOpt;

/// The CaSILE command line interface, publishing automation level wizard.
#[derive(StructOpt)]
struct Cli {
    // #[structopt(short, long)]
    // version: [ version = env!("VERGEN_SEMVER") ],

    /// Activate debug mode
    #[structopt(short, long)]
    debug: bool,

    /// Outputs verbose feedback where possible
    #[structopt(short, long)]
    verbose: bool,

    #[structopt(subcommand)]
    command: Command,
}

#[derive(StructOpt)]
enum Command {
    /// Executes a make target
    Make {
        target: String
    }
}

fn main() {
    let args = Cli::from_args();
    println!("Insert magic potion!");
    println!("Build SHA: {}", env!("VERGEN_SHA_SHORT"));
}
