use std::error;

pub fn run(config: &crate::Config, input: Vec<String>) -> Result<(), Box<dyn error::Error>> {
    crate::header(config, "shell-header");
    println!("{}", config.locale.translate("debug-shell"));
    crate::run_shell(config, input);
    Ok(())
}
