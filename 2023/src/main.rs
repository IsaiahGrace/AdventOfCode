mod day01;
mod puzzle;

use crate::day01::Day01;
use crate::puzzle::*;
use std::env;
use std::error;
use std::fs;

fn main() -> Result<(), Box<dyn error::Error>> {
    let mut args = env::args();

    // The first argument is the program name
    _ = args.next();

    let day = args
        .next()
        .expect("Please specify the day with two digits.");

    let input_file = args
        .next()
        .expect("Please specify the input file in the day directory.");

    let inpuf_file_path = format!("{}/{}", day, input_file);
    let input = fs::read_to_string(inpuf_file_path)?;

    let puzzle_solver = match day.as_str() {
        "01" => Day01::from(input),
        _ => return Err("Day given is not implemented.".into()),
    };

    let solution = puzzle_solver.solve()?;

    println!("{}", solution);
    return Ok(());
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn day_01_01() {
        let solver: Day01 = fs::read_to_string("01/01").unwrap().into();
        assert_eq!(solver.solve().unwrap(), Solution::Integer(142, 0));
    }

    #[test]
    fn day_01_input() {
        let solver: Day01 = fs::read_to_string("01/input").unwrap().into();
        assert_eq!(solver.solve().unwrap(), Solution::Integer(55488, 0));
    }
}
