use clap::IntoApp;
use clap_generate::generate_to;
use clap_generate::generators::{Bash, Elvish, Fish, PowerShell, Zsh};
use std::{collections, env, fs};
use vergen::vergen;

include!("src/cli.rs");

fn main() {
    let mut flags = vergen::Config::default();
    // If automake has passed a version, use that instead of vergen's formatting
    if let Ok(val) = env::var("CASILE_VERSION") {
        *flags.git_mut().semver_mut() = false;
        println!("cargo:rustc-env=VERGEN_GIT_SEMVER={}", val)
    };
    vergen(flags).expect("Unable to generate the cargo keys!");
    pass_on_configure_details();
    generate_shell_completions();
}

/// Generate shell completion files from CLI interface
fn generate_shell_completions() {
    let profile =
        env::var("PROFILE").expect("Could not find what build profile is boing used by Cargo");
    let completionsdir = format!("target/{}/completions", profile);
    fs::create_dir_all(&completionsdir)
        .expect("Could not create directory in which to place completions");
    let app = Cli::into_app();
    let bin_name: &str = app
        .get_bin_name()
        .expect("Could not retrieve bin-name from generated Clap app");
    let mut app = Cli::into_app();
    generate_to::<Bash, _, _>(&mut app, bin_name, &completionsdir);
    generate_to::<Elvish, _, _>(&mut app, bin_name, &completionsdir);
    generate_to::<Fish, _, _>(&mut app, bin_name, &completionsdir);
    generate_to::<PowerShell, _, _>(&mut app, bin_name, &completionsdir);
    generate_to::<Zsh, _, _>(&mut app, bin_name, &completionsdir);
}

/// Pass through some variables set by autoconf/automake about where we're installed to cargo for
/// use in finding resources at runtime
fn pass_on_configure_details() {
    let mut autoconf_vars = collections::HashMap::new();
    autoconf_vars.insert("CONFIGURE_PREFIX", String::from("./"));
    autoconf_vars.insert("CONFIGURE_BINDIR", String::from("./"));
    autoconf_vars.insert("CONFIGURE_DATADIR", String::from("./"));
    for (var, default) in autoconf_vars {
        let val = env::var(var).unwrap_or(default);
        println!("cargo:rustc-env={}={}", var, val);
    }
}
