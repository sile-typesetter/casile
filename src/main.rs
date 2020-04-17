use structopt::StructOpt;

/// The CaSILE command line interface, publishing automation level wizard.
#[derive(StructOpt)]
struct Cli {
    /// Activate debug mode
    #[structopt(short, long)]
    debug: bool,

    /// Output verbose feedback where possible
    #[structopt(short, long)]
    verbose: bool,

    /// Primary CaSILE command (try make)
    command: String,
}

fn main() {
    let args = Cli::from_args();
    println!("Insert magic potion!");
}
