use plotters::coord::Shift;
use std::collections::HashSet;
use std::fmt;
use colored::*;
use plotters::prelude::*;
use plotters::style::Color;
use rand::thread_rng;
use rand::seq::SliceRandom;
use palette::{Gradient, LinSrgb};

// Is this overkill for the puzzle? Yeah. Do I care? No!
// It's a good time to learn lifetimes, and to actually use Option
#[derive(Debug)]
struct Point {
	height: u32,
	visited: bool,
}

pub struct SeaFloor<'a> {
	minima: HashSet<(usize,usize)>,
	grid: Vec<Vec<Point>>,
	frame: u32,
	colors: Vec<(f32,f32,f32)>,
	gif: DrawingArea<plotters::prelude::BitMapBackend<'a>, Shift>,
	bs: usize,
	img_size: (u32, u32),
}

impl<'a> SeaFloor<'a> {
	pub fn new(input: Vec<String>) -> SeaFloor<'a> {
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

		let bs = 10;
		let img_size = ((grid[0].len() * bs) as u32, (grid.len() * bs) as u32);

		SeaFloor {
			minima: HashSet::new(),
			grid: grid,
			frame: 0,
			colors: colors,
			gif: BitMapBackend::gif("vents.gif", img_size, 1).unwrap().into_drawing_area(),
			bs: bs,
			img_size: img_size,
		}
	}

	fn get_height(&self, x: usize, y: usize) -> u32 {
		if y >= self.grid.len() {
			return u32::MAX;
		}
		if x >= self.grid[y].len() {
			return u32::MAX;
		}
		return self.grid[y][x].height;
	}

	pub fn explore_all(&mut self) {
		let y_val: Vec<usize> = (0..self.grid.len()).collect();
		let x_val: Vec<usize> = (0..self.grid[0].len()).collect();
		let mut point_order: Vec<(usize,usize)> = vec![];
		for x in &x_val {
			for y in &y_val {
				point_order.push((*x,*y));
			}
		}
		point_order.shuffle(&mut thread_rng());

		for (x,y) in point_order {
			println!("({},{})", x,y);
			self.explore(x,y);
		}
	}

	pub fn explore(&mut self, x: usize, y: usize) {
		if y >= self.grid.len() {
			return;
		}
		if x >= self.grid[y].len() {
			return;
		}
		if self.grid[y][x].visited {
			return;
		}

		self.grid[y][x].visited = true;
		//println!("{}", self);
		println!("({},{})",x,y);
		self.plot();

		// Recurse!
		let height = self.grid[y][x].height;

		if height > self.get_height(x + 1, y) {
			self.explore(x + 1, y);
			return
		}
		if x > 0 && height > self.get_height(x - 1, y) {
			self.explore(x - 1, y);
			return
		}
		if height > self.get_height(x, y + 1) {
			self.explore(x, y + 1);
			return
		}
		if y > 0 && height > self.get_height(x, y - 1) {
			self.explore(x, y - 1);
			return
		}

		// Base case: This point is a local minimum
		self.minima.insert((x,y));
	}

	pub fn plot(&mut self) {
		//let name = format!("{}.png", self.frame);
		//let image = BitMapBackend::new(&name, self.img_size).into_drawing_area();

		for (y_idx, row) in self.grid.iter().enumerate() {
			for (x_idx, point) in row.iter().enumerate() {

				let rgb = self.colors[(point.height % 10) as usize];
				let color;

				if point.visited {
					// Blue heavy
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

				let x = (x_idx * self.bs) as i32;
				let y = (y_idx * self.bs) as i32;
				let upper_left = (x, y);
				let lower_right = (x + self.bs as i32, y + self.bs as i32);
				let rect = Rectangle::new([upper_left, lower_right], style);

				//image.draw(&rect).unwrap();

				self.gif.draw(&rect).unwrap();
			}
		}
		self.frame += 1;
		self.gif.present().unwrap();
    }
}

impl fmt::Display for SeaFloor<'_> {
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
