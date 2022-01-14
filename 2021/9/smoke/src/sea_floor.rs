use std::fmt;
use std::collections::HashMap;
use std::collections::HashSet;
use colored::*;
use itertools::Itertools;
use rand::thread_rng;
use rand::seq::SliceRandom;
use palette::{Gradient, LinSrgb};
use plotters::prelude::*;
use plotters::coord::Shift;
use plotters::style::Color;

#[derive(Debug)]
struct Point {
	height: u32,
	visited: bool,
	basin: Option<(usize, usize)>,
}

pub struct SeaFloor<'a> {
	minima: HashSet<(usize,usize)>,
	basins: HashMap<(usize,usize),u32>,
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
					basin: None,
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
			basins: HashMap::new(),
			grid: grid,
			frame: 0,
			colors: colors,
			gif: BitMapBackend::gif("vents.gif", img_size, 1).unwrap().into_drawing_area(),
			bs: bs,
			img_size: img_size,
		}
	}

	pub fn pt1_answer(&self) -> u32 {
		let mut risk: u32 = 0;
		for minimum in &self.minima {
			risk += self.get_height(minimum.0, minimum.1) + 1;
		}
		risk
	}

	pub fn pt2_answer(&self) -> u32 {
		self.basins.values().sorted().rev().take(3).copied().reduce(|a, b| a * b).unwrap()
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
		for y in &y_val {
			for x in &x_val {
				point_order.push((*x,*y));
			}
		}
		//point_order.shuffle(&mut thread_rng());

		self.plot();
		println!("{}", self);

		for (x,y) in point_order {
			self.explore(x,y);
		}
		self.plot();
		println!("{}", self);
	}

	pub fn explore_spiral(&mut self) {
		// Let's see how it looks to expore the sea floor starting from the center and working our way out.
		// https://stackoverflow.com/questions/33684970/print-2-d-array-in-clockwise-expanding-spiral-from-center
		let mut x; // current position; x
		let mut y; // current position; y
		let mut d = 0; // current direction; 0=RIGHT, 1=DOWN, 2=LEFT, 3=UP
		let mut s = 1; // chain size

		let size = if self.grid.len() > self.grid[0].len() { self.grid.len() } else { self.grid[0].len() };
		
		// starting point
		x = size / 2;
		y = size / 2;

		let mut k = 0;
		while k <= size {
			let mut j = 0;
			while j < ( if k < size {2} else {3}) {
				let mut i = 0;
				while i < s {
					self.explore(x,y);
					match d {
						0 => { y += 1 }
						1 => { x += 1 }
						2 => { y -= 1 }
						3 => { x -= 1 }
						_ => { panic!() }
					}
					i += 1;
				}
				d = (d + 1) % 4;
				j += 1;
			}
			s += 1;
			k += 1;
		}
	}

	pub fn explore(&mut self, x: usize, y: usize) -> Option<(usize,usize)> {
		if y >= self.grid.len() {
			return None;
		}
		if x >= self.grid[y].len() {
			return None;
		}
		if self.grid[y][x].visited {
			return self.grid[y][x].basin;
		}

		self.grid[y][x].visited = true;

		// Recurse!
		let height = self.grid[y][x].height;

		let basin;
		if self.grid[y][x].height == 9 {
			basin = None;
		} else if height > self.get_height(x + 1, y) {
			basin = self.explore(x + 1, y);
		} else if x > 0 && height > self.get_height(x - 1, y) {
			basin = self.explore(x - 1, y);
		} else if height > self.get_height(x, y + 1) {
			basin = self.explore(x, y + 1);
		} else if y > 0 && height > self.get_height(x, y - 1) {
			basin = self.explore(x, y - 1);
		} else {
			// Base case: This point is a local minimum.
			self.minima.insert((x,y));
			basin = Some((x,y));
			println!("{}", self);
			self.plot();
		}

		// This point is in a basin, add one to the basin count.
		if basin.is_some() {
			self.grid[y][x].basin = basin;
			*self.basins.entry(basin.unwrap()).or_insert(0) += 1;
		}

		basin
	}

	pub fn plot(&mut self) {
		let name = format!("{}.png", self.frame);
		let image = BitMapBackend::new(&name, self.img_size).into_drawing_area();

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

				image.draw(&rect).unwrap();

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
