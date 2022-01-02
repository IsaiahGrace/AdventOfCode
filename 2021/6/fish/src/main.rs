use std::fs::File;
use std::io::{prelude::*, BufReader};
use std::path::Path;
use std::env;

fn read_input(file: impl AsRef<Path>) -> Vec<usize> {
    let file = File::open(file).expect("No file found");
    let buf = BufReader::new(file);
    let lines = buf.lines().map(|l| l.unwrap());
    let mut input: Vec<usize> = Vec::new();
    for line in lines {
        input.append(&mut line.split(',').map(|n| n.parse::<usize>().unwrap()).collect());
    }
    input
}

fn day(today: [usize;9]) -> [usize;9] {
    let mut tomorrow: [usize;9] = [0;9];
    for i in 1..9 {
        tomorrow[i-1] = today[i];
    }
    tomorrow[6] += today[0];
    tomorrow[8] += today[0];
    tomorrow
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("Please specify an input file")
    }

    let input: Vec<usize> = read_input(&args[1]);
    let mut school: [usize;9] = [0;9];
    for fish in input {
        school[fish] += 1;
    }

    println!("{:?} = {}", school, school.iter().sum::<usize>());
    for _ in 0..256 {
        school = day(school);
        println!("{:?} = {}", school, school.iter().sum::<usize>());
    }
}
