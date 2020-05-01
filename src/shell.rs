use std::io;

pub fn run(config: crate::Config) -> io::Result<()> {
    println!("{}", config.locale.translate("debug-shell"));
    Ok(())
}
