use std::collections::HashSet;
use std::fmt;
use colored::*;
use plotters::prelude::*;
use plotters::style::Color;

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
	grid: Vec<Vec<Point>>,
	frame: u32,
	colors: Vec<(f32,f32,f32)>,
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

		let gradient = Gradient::new(vec![
			LinSrgb::new(0.95, 0.90, 0.30),
			LinSrgb::new(0.70, 0.10, 0.20),
			LinSrgb::new(0.00, 0.05, 0.20),
		]);

		let colors: Vec<(f32,f32,f32)> = gradient.take(10).map(|c| {c.into_linear(); (c.red, c.green, c.blue)}).collect();


		SeaFloor {
			minima: HashSet::new(),
			grid: grid,
			frame: 0,
			colors: colors,
		}
	}

	pub fn plot(&self) {
		let bs = 10;
		let name = format!("{}.png", self.frame);
		let size = ((self.grid[0].len() * bs) as u32, (self.grid.len() * bs) as u32);
		let image = BitMapBackend::new(&name, size).into_drawing_area();
		for (y_idx, row) in self.grid.iter().enumerate() {
			for (x_idx, point) in row.iter().enumerate() {
				let rgb = self.colors[(point.height % 10) as usize];
				let color;
				if point.visited {
					// Green heavy
					color = RGBColor {
						0: (rgb.2 * 255.0) as u8,
						1: (rgb.1 * 255.0) as u8,
						2: (rgb.0 * 255.0) as u8,
					};
				} else {
					// Red heavy
					color = RGBColor {
						0: (rgb.0 * 255.0) as u8,
						1: (rgb.1 * 255.0) as u8,
						2: (rgb.2 * 255.0) as u8,
					};
				}
				let style = ShapeStyle {
					color: color.to_rgba(),
					filled: true,
					stroke_width: 1,
				};
				let x = (x_idx * bs) as i32;
				let y = (y_idx * bs) as i32;
				let upper_left = (x, y);
				let lower_right = (x + bs as i32, y + bs as i32);
				let rect = Rectangle::new([upper_left, lower_right], style);
				image.draw(&rect).unwrap();
			}
		}
    }
}

impl fmt::Display for SeaFloor {
	// This trait requires `fmt` with this exact signature.
	fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
		for row in &self.grid {
			for point in row {
				let rgb = self.colors[(point.height % 10) as usize];
				let color: (u8, u8, u8);
				if point.visited {
					// Blue heavy
					color = ((rgb.2 * 255.0) as u8, (rgb.1 * 255.0) as u8, (rgb.0 * 255.0) as u8);
				} else {
					// Red heavy
					color = ((rgb.0 * 255.0) as u8, (rgb.1 * 255.0) as u8, (rgb.2 * 255.0) as u8);
				}
				write!(f, "{}", format!("{}", point.height).truecolor(color.0, color.1, color.2).bold())?;
			}
			writeln!(f)?;
		}
		Ok(())
	}
}