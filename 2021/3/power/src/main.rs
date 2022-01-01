use std::{
    env,
    io::{prelude::*, BufReader},
    path::Path,
    fs::File
};

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("Please specify an input file")
    }

    let lines = read_input_file(&args[1]);
    let num_bits = lines[0].len();

    let mut bits: Vec<i32> = vec![0; num_bits];

    for line in lines {
        for (i, val) in line.chars().enumerate() {
            match val {
                '0' => bits[i] -= 1,
                '1' => bits[i] += 1,
                _ => panic!("Unknown bit in input. Not 1 or 0.")
            }
        }
    }

    let mut gamma: u64 = 0;
    let mut epsilon: u64 = 0;

    for (i, bit) in bits.iter().enumerate() {
        gamma |= (if *bit > 0 {1} else {0}) << (num_bits - i - 1);
        epsilon |= (if *bit > 0 {0} else {1}) << (num_bits - i - 1);
    }

    println!("Gamma: {}", gamma);
    println!("Epsilon: {}", epsilon);
    println!("Answer: {}", gamma * epsilon);
}

fn read_input_file(file: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(file).expect("No file found");
    let buf = BufReader::new(file);
    buf.lines()
        .map(|l| l.unwrap())
        .collect()
}
