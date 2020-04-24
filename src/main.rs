use structopt::StructOpt;

/// The command line interface to the CaSILE toolkit, a book publishing
/// workflow employing SILE and other wizardry
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
    command: Subcommand,

}

#[derive(StructOpt)]
enum Subcommand {

    /// Executes a make target
    Make {
        /// Target as defined in CaSILE makefile
        target: String
    },

    /// Configure a book repository
    Setup {
        #[structopt(default_value = "./")]
        /// Path to project repository
        path: String
    },

    /// Pass through other commands to shell
    #[structopt(external_subcommand)]
    Other(Vec<String>),

}

fn main() {

    let args = Cli::from_args();
    println!("Insert magic potion! (Unimplemented)");

}
