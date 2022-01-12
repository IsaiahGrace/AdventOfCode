use std::collections::HashSet;
use std::fmt;
use colored::*;
use palette::{Gradient, LinSrgb};

// Is this overkill for the puzzle? Yeah. Do I care? No!
// It's a good time to learn lifetimes, and to actually use Option
#[derive(Debug)]
struct Point {
	height: u32,
	visited: bool,
	//north: &'a Option<Point<'a>>,
	//south: &'a Option<Point<'a>>,
	//east: &'a Option<Point<'a>>,
	//west: &'a Option<Point<'a>>,
}

#[derive(Debug)]
pub struct SeaFloor {
	minima: HashSet<(usize,usize)>,
	grid: Vec<Vec<Point>>
}

impl SeaFloor {
	pub fn new(input: Vec<String>) -> SeaFloor {
		let mut grid: Vec<Vec<Point>> = vec![];

		for line in input {
			grid.push(vec![]);
			for c in line.chars() {
				grid.last_mut().unwrap().push( Point {
					height: c.to_digit(10).unwrap(),
					visited: false,
				});
			}
		}

		SeaFloor {
			minima: HashSet::new(),
			grid: grid,
		}
	}
}

impl fmt::Display for SeaFloor {
	// This trait requires `fmt` with this exact signature.
	fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
		let gradient = Gradient::new(vec![
			LinSrgb::new(0.95, 0.90, 0.30),
			LinSrgb::new(0.70, 0.10, 0.20),
			LinSrgb::new(0.00, 0.05, 0.20),
		]);

		let colors: Vec<_> = gradient.take(10).map(|c| c.into_linear()).collect();

		for row in &self.grid {
			for point in row {
				let rgb = colors[(point.height % 10) as usize];
				let color: (u8, u8, u8) = ((rgb.red * 255.0) as u8, (rgb.green * 255.0) as u8, (rgb.blue * 255.0) as u8);
				write!(f, "{}", format!("{}", point.height).truecolor(color.0, color.1, color.2).bold()).unwrap();
			}
			writeln!(f).unwrap();
		}
		writeln!(f)
	}
}