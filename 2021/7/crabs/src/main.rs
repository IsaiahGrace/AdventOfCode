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

fn calculate_cost1(dist: &Vec<usize>, pos: usize) -> usize {
    let mut cost = 0;
    for (i, n) in dist.iter().enumerate() {
        cost += n * if i < pos {pos - i} else {i - pos};
    }
    cost
}

fn calculate_cost2(dist: &Vec<usize>, pos: usize) -> usize {
    let mut cost: usize = 0;
    for (i, n) in dist.iter().enumerate() {
        let dist = if i < pos {pos - i} else {i - pos};
        cost += n * (dist * (dist + 1) / 2);
    }
    cost
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("Please specify an input file")
    }

    let input: Vec<usize> = read_input(&args[1]);

    // Create a vec with size max(input)
    // Initilize with zeros
    let mut dist: Vec<usize> = vec!(0; *input.iter().max().unwrap() + 1);

    // Each index is a position, value is number of crabs at that position
    for n in input {
        dist[n] += 1;
    }

    // Create a new vec with same size, this will be the cost vec
    let mut cost1: Vec<usize> = vec!(0; dist.len());
    let mut cost2: Vec<usize> = vec!(0; dist.len());

    // for each index in the cost vector, calculate the cost of all crabs moving to that index
    for i in 0..dist.len() {
        cost1[i] = calculate_cost1(&dist, i);
    }

    for i in 0..dist.len() {
        cost2[i] = calculate_cost2(&dist, i);
    }

    // find the minimum value of the cost vector
    let answer_pt1 = cost1.iter().min().unwrap();
    let answer_pt2 = cost2.iter().min().unwrap();

    println!("Part 1. Minimum fuel cost: {}", answer_pt1);
    println!("Part 2. Minimum fuel cost: {}", answer_pt2);
}
