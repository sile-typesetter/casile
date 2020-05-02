extern crate vergen;

use clap::{IntoApp};
use clap_generate::{generate_to, generators};
use std::env;
use vergen::{generate_cargo_keys, ConstantsFlags};

include!("src/cli.rs");

fn main() {
    // Setup the flags, toggling off the 'SEMVER_FROM_CARGO_PKG' flag
    let mut flags = ConstantsFlags::all();
    flags.toggle(ConstantsFlags::SEMVER_FROM_CARGO_PKG);

    // Generate the 'cargo:' key output
    generate_cargo_keys(flags).expect("Unable to generate the cargo keys!");

    let outdir = match env::var_os("OUT_DIR") {
        None => return,
        Some(outdir) => outdir,
    };
    let mut app = Cli::into_app();
    generate_to::<generators::Bash, _, _>(&mut app, "casile", &outdir,);
    generate_to::<generators::Fish, _, _>(&mut app, "casile", &outdir,);
    generate_to::<generators::Zsh, _, _>(&mut app, "casile", &outdir,);
}
