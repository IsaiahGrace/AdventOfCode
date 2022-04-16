use std::env;
use std::fs::File;
use std::io::{prelude::*, BufReader};
use std::path::Path;
use colored::*;

#[derive(Clone, Debug)]
struct Dumbo {
    energy: u8,
    flashing: bool,
    flashes: u32,
}

fn read_input_file(file: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(file).expect("No file found");
    let buf = BufReader::new(file);
    buf.lines().map(|l| l.unwrap()).collect()
}

fn parse_input(input: Vec<String>) -> Vec<Vec<Dumbo>> {
    let mut grid: Vec<Vec<Dumbo>> = Vec::new();
    for row in input {
        grid.push(Vec::new());
        for character in row.chars() {
            grid.last_mut().unwrap().push(Dumbo {
                energy: character.to_digit(10).expect("Could not parse char to u32.") as u8,
                flashing: false,
                flashes: 0,
            });
        }
    }
    grid
}

fn print_grid(grid: &Vec<Vec<Dumbo>>) {
    for row in grid.into_iter() {
        for dumbo in row {
            let energy;
            if dumbo.flashing {
                energy = format!("{}", dumbo.energy).bold().yellow();
            } else {
                energy = format!("{}", dumbo.energy).blue();
            }
            print!("{}", energy)
        }
        println!("");
    }
}

fn flash(row: usize, col: usize, grid: &mut Vec<Vec<Dumbo>>) {
    if row >= grid.len() {
        return;
    }
    if col >= grid[row].len() {
        return;
    }
    if grid[row][col].energy < 10 {
        return;
    }

    if grid[row][col].flashing {
        return;
    }

    grid[row][col].flashing = true;
    grid[row][col].flashes += 1;

    let rows: Vec<usize>;
    let cols: Vec<usize>;

    if row > 0 {
        rows = vec![row - 1, row, row + 1];
    } else {
        rows = vec![row, row + 1];
    }

    if col > 0 {
        // In the middle somewhere
        cols = vec![col - 1, col, col + 1];
    } else {
        // On the top edge
        cols = vec![col, col + 1];
    }

    for y in rows {
        if y >= grid.len() {continue;}
        for x in &cols {
            if *x >= grid[y].len() {continue;}
            if *x == col && y == row {continue;}
            grid[y][*x].energy += 1;
            flash(y, *x, grid);
        }
    }
}

fn step(grid: &mut Vec<Vec<Dumbo>>) {
    // increment energy
    for row in grid.into_iter() {
        for dumbo in row {
            dumbo.energy += 1;
        }
    }

    // Do some depth first recursion for flashing chain reactions
    for row in 0..grid.len() {
        for col in 0..grid[row].len() {
            flash(row, col, grid);
        }
    }

    // Reset flashers back to zero
    for row in grid.into_iter() {
        for dumbo in row {
            if dumbo.flashing {
                dumbo.energy = 0;
            }
        }
    }

    // Print out the grid, making flashers bold
    print_grid(grid);
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("Please specify an input file")
    }

    let input = read_input_file(&args[1]);

    let mut grid = parse_input(input);

    let mut all_flashing = false;
    let mut i = 0;

    println!("Before any steps:");
    print_grid(&grid);
    while !all_flashing {
        println!();
        println!("After step {}:", i+1);
        step(&mut grid);
        i += 1;

        // Check if all the dumbos are flashing
        all_flashing = true;
        for row in &grid {
            for dumbo in row {
                if !dumbo.flashing {
                    all_flashing = false;
                }
            }
        }

        // Turn off flashers so that we have a fresh start for next time
        for row in &mut grid {
            for dumbo in row {
                dumbo.flashing = false;
            }
        }
    }

    // Count the total number of flashes
    let mut flashes = 0;
    for row in grid.into_iter() {
        for dumbo in row {
            flashes += dumbo.flashes;
        }
    }

    println!("Total flashes: {}", flashes);
    println!("Steps: {}", i);
}
