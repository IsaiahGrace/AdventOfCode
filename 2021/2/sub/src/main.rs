use std::{
    env,
    io::{prelude::*, BufReader},
    path::Path,
    fs::File
};

enum Direction {
    Forward,
    Down,
    Up
}

struct Command {
    direction: Direction,
    distance: u32
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("Please specify an input file")
    }

    let commands: Vec<Command> = create_commands(read_input_file(&args[1]));

    let mut horizontal: u32 = 0;
    let mut depth: u32 = 0;

    for command in commands {
        match command.direction {
            Direction::Forward => horizontal += command.distance,
            Direction::Down => depth += command.distance,
            Direction::Up => depth -= command.distance,
        }
    }
    println!("Horizontal position: {}", horizontal);
    println!("Depth: {}", depth);
    println!("Answer: {}", horizontal * depth);
}

fn read_input_file(file: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(file).expect("No file found");
    let buf = BufReader::new(file);
    buf.lines()
        .map(|l| l.unwrap())
        .collect()
}

fn create_commands(lines: Vec<String>) -> Vec<Command> {
    let mut commands: Vec<Command> = Vec::new();
    for line in lines {
        let mut split = line.split_whitespace();
        commands.push(Command {
            direction: match split.next().unwrap() {
                "forward" => Direction::Forward,
                "down" => Direction::Down,
                "up" => Direction::Up,
                _ => panic!("Failed to parse direction")
            },
            distance: split.next().unwrap().parse::<u32>().expect("Failed to parse distance")
        })
    }
    commands
}
