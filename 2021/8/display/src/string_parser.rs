use crate::segment::Segment;
use std::fs::File;
use std::io::{prelude::*, BufReader};
use std::path::Path;
use std::collections::HashSet;

pub fn parse_line(line: String) -> (Vec<HashSet<Segment>>, Vec<HashSet<Segment>>) {
	let mut codes: Vec<HashSet<Segment>> = Vec::new();
	let mut output: Vec<HashSet<Segment>> = Vec::new();

	let mut split_line = line.split("|");

	let codes_string = split_line.next().unwrap();
	let output_string = split_line.next().unwrap();

	for code in codes_string.split_whitespace() {
		codes.push(gen_segment_set(code.to_string()));
	}

	for out in output_string.split_whitespace() {
		output.push(gen_segment_set(out.to_string()));
	}

	(codes, output)
}

fn gen_segment_set(string: String) -> HashSet<Segment> {
	let mut set: HashSet<Segment> = HashSet::new();
	for c in string.chars() {
		match c {
			'a' => {set.insert(Segment::A);}
			'b' => {set.insert(Segment::B);}
			'c' => {set.insert(Segment::C);}
			'd' => {set.insert(Segment::D);}
			'e' => {set.insert(Segment::E);}
			'f' => {set.insert(Segment::F);}
			'g' => {set.insert(Segment::G);}
			_ => {panic!("Unknown char in string: {}", c);}
		}
	}
	set
}

pub fn read_input_file(file: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(file).expect("No file found");
    let buf = BufReader::new(file);
    buf.lines().map(|l| l.unwrap()).collect()
}

