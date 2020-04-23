use structopt::StructOpt;

/// The CaSILE command line interface, publishing automation level wizard.
#[derive(StructOpt)]
#[structopt(version = env!("VERGEN_SEMVER"))]
struct Cli {
    /// Activate debug mode
    #[structopt(short, long, env = "DEBUG")]
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
    },

    /// Pass through other commands to shell
    #[structopt(external_subcommand)]
    Other(Vec<String>),
}

fn main() {
    let args = Cli::from_args();
    println!("Insert magic potion!");
}
