mod day01;
mod day02;
mod day03;
mod day04;
mod day05;
mod puzzle;

use crate::day01::Day01;
use crate::day02::Day02;
use crate::day03::Day03;
use crate::day04::Day04;
use crate::day05::Day05;
use crate::puzzle::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut args = std::env::args();

    // The first argument is the program name
    _ = args.next();

    let day = args
        .next()
        .expect("Please specify the day with two digits.");

    let input_file = args
        .next()
        .expect("Please specify the input file in the day directory.");

    let inpuf_file_path = format!("{}/{}", day, input_file);
    let input = std::fs::read_to_string(inpuf_file_path)?;

    let mut puzzle_solver: Box<dyn Solve> = match day.as_str() {
        "01" => Box::new(Day01::from(input)),
        "02" => Box::new(Day02::from(input)),
        "03" => Box::new(Day03::from(input)),
        "04" => Box::new(Day04::from(input)),
        "05" => Box::new(Day05::from(input)),
        _ => return Err("Day given is not implemented.".into()),
    };

    let solution = puzzle_solver.solve()?;

    println!("{}", solution);
    return Ok(());
}
