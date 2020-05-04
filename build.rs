extern crate vergen;

use clap::IntoApp;
use clap_generate::generate_to;
use clap_generate::generators::{Bash, Elvish, Fish, PowerShell, Zsh};
use std::{env, fs};
use vergen::{generate_cargo_keys, ConstantsFlags};

include!("src/cli.rs");

fn main() {
    // Setup the flags, toggling off the 'SEMVER_FROM_CARGO_PKG' flag
    let mut flags = ConstantsFlags::all();
    flags.toggle(ConstantsFlags::SEMVER_FROM_CARGO_PKG);

    // Generate the 'cargo:' key output
    generate_cargo_keys(flags).expect("Unable to generate the cargo keys!");

    // let outdir = env::var_os("OUT_DIR").unwrap();
    let profile = env::var("PROFILE").unwrap();
    let completionsdir = format!("target/{}/completions", profile);
    fs::create_dir(&completionsdir).unwrap();
    println!("CoDi {}", &completionsdir);
    let mut app = Cli::into_app();
    let bin_name = "casile";
    generate_to::<Bash, _, _>(&mut app, bin_name, &completionsdir);
    generate_to::<Elvish, _, _>(&mut app, bin_name, &completionsdir);
    generate_to::<Fish, _, _>(&mut app, bin_name, &completionsdir);
    generate_to::<PowerShell, _, _>(&mut app, bin_name, &completionsdir);
    generate_to::<Zsh, _, _>(&mut app, bin_name, &completionsdir);
}
