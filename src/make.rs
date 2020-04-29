use std::{io, vec};

pub fn run(_config: crate::Config, _target: vec::Vec<String>) -> io::Result<()> {
    let a = crate::i18n::get_str("debug-shell");
    println!("Translation: {}", a);
    println!("Make make make sense or I’ll make you make makefiles.");
    Ok(())
}
