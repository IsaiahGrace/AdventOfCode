use std::env;
use std::fs::File;
use std::io::{prelude::*, BufReader};
use std::path::Path;

struct Chunk {
    open: char,
    close: char,
    children: Vec<Chunk>,
}

impl Chunck {
    pub fn new(line: String) -> Chunk {
        
    }
}

struct Line {
    chunks: Vec<Chunk>,
}

impl Line {
    pub fn new(line: String) -> Line {
        Line {
            chunks: Vec::new(),
        }
    }
}


fn read_input_file(file: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(file).expect("No file found");
    let buf = BufReader::new(file);
    buf.lines().map(|l| l.unwrap()).collect()
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("Please specify an input file")
    }

    let input = read_input_file(&args[1]);

    println!("{:?}", input);
}
