mod day01;
mod puzzle;

use crate::day01::Day01;
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

    let puzzle_solver = match day.as_str() {
        "01" => Day01::from(input),
        _ => return Err("Day given is not implemented.".into()),
    };

    let solution = puzzle_solver.solve()?;

    println!("{}", solution);
    return Ok(());
}
