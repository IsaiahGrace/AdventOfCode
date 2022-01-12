use std::collections::HashSet;

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
pub struct SeaMap {
	minima: HashSet<(usize,usize)>,
	grid: Vec<Vec<Point>>
}

impl SeaMap {
	pub fn new(input: Vec<String>) -> SeaMap {
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

		SeaMap {
			minima: HashSet::new(),
			grid: grid,
		}
	}
}
