mod display;
mod hex_digit;
mod segment;
mod segment_map;
mod solution;
mod string_parser;

use crate::string_parser::parse_line;
use crate::string_parser::read_input_file;
use crate::segment::segment_set;
use crate::display::Display;
use crate::segment::Segment;
use crate::segment_map::SegmentMap;
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("Please specify an input file")
    }

    let input: Vec<String> = read_input_file(&args[1]);

    let mut sum = 0;

    for line in input {
        let line_tuple = parse_line(line);
        let mut set = SegmentMap::new();
        let codex = set.solve(line_tuple.0);
        let mut num: i32 = 0;
        let mut display = Display::new();
        for out_code in line_tuple.1 {
            let x: i32 = codex.decode(out_code);
            display.push(x);
            num = (num * 10) + x;
        }
        sum += num;
        println!("{}\n\n", display);
    }
    println!("Answer: {}", sum);
}
