use std::fs::File;
use std::io::{prelude::*, BufReader};
use std::path::Path;

pub fn read_input_file(file: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(file).expect("No file found");
    let buf = BufReader::new(file);
    buf.lines().map(|l| l.unwrap()).collect()
}
