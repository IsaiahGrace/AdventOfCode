// This puzzle relies on a mapping of segments -> segments.
use crate::solution::Solution;
use crate::segment::Segment;
use std::collections::HashSet;
use std::iter::FromIterator;
use strum::IntoEnumIterator;

// This struct maps an output segment to a set of possible input segments.
// We will eliminate impossible mappings iteratively, and solve the puzzle when each HashSet contains only one element.
#[derive(Debug)]
pub struct SegmentMap {
	pub a: HashSet<Segment>,
	pub b: HashSet<Segment>,
	pub c: HashSet<Segment>,
	pub d: HashSet<Segment>,
	pub e: HashSet<Segment>,
	pub f: HashSet<Segment>,
	pub g: HashSet<Segment>,
}


impl SegmentMap {
	pub fn new() -> SegmentMap {
		SegmentMap {
			a: HashSet::from_iter(Segment::iter()),
			b: HashSet::from_iter(Segment::iter()),
			c: HashSet::from_iter(Segment::iter()),
			d: HashSet::from_iter(Segment::iter()),
			e: HashSet::from_iter(Segment::iter()),
			f: HashSet::from_iter(Segment::iter()),
			g: HashSet::from_iter(Segment::iter()),
		}
	}

	fn check(&self) {
		assert!(!self.a.is_empty(), "{:?}", self);
		assert!(!self.b.is_empty(), "{:?}", self);
		assert!(!self.c.is_empty(), "{:?}", self);
		assert!(!self.d.is_empty(), "{:?}", self);
		assert!(!self.e.is_empty(), "{:?}", self);
		assert!(!self.f.is_empty(), "{:?}", self);
		assert!(!self.g.is_empty(), "{:?}", self);
	}

	fn assert_done(&self) {
		assert!(self.a.len() == 1, "{:?}", self);
		assert!(self.b.len() == 1, "{:?}", self);
		assert!(self.c.len() == 1, "{:?}", self);
		assert!(self.d.len() == 1, "{:?}", self);
		assert!(self.e.len() == 1, "{:?}", self);
		assert!(self.f.len() == 1, "{:?}", self);
		assert!(self.g.len() == 1, "{:?}", self);
	}

	fn filter_one(&mut self, one: &HashSet<Segment>) {
		// One has segments c and f
		self.c.retain(|s| one.contains(s));
		self.f.retain(|s| one.contains(s));

		for segment in one {
			self.a.remove(&segment);
			self.b.remove(&segment);
			self.d.remove(&segment);
			self.e.remove(&segment);
			self.g.remove(&segment);
		}
		self.check();
	}

	fn filter_four(&mut self, four: &HashSet<Segment>) {
		// Four has segments b, c, d, and f
		self.b.retain(|s| four.contains(s));
		self.c.retain(|s| four.contains(s));
		self.d.retain(|s| four.contains(s));
		self.f.retain(|s| four.contains(s));

		// Filter out c and f from all other segments
		for segment in four {
			self.a.remove(&segment);
			self.e.remove(&segment);
			self.g.remove(&segment);
		}
		self.check();
	}

	fn filter_seven(&mut self, seven: &HashSet<Segment>) {
		// Seven has segments a, c, and f
		self.a.retain(|s| seven.contains(s));
		self.c.retain(|s| seven.contains(s));
		self.f.retain(|s| seven.contains(s));

		for segment in seven {
			self.b.remove(&segment);
			self.d.remove(&segment);
			self.e.remove(&segment);
			self.g.remove(&segment);
		}
		self.check();
	}

	fn filter_two_three_five(&mut self, digits: &[&HashSet<Segment>;3]) {
		// 2, 3, and 5 have segments A, D, and G in common
		let mut common: HashSet<Segment> = HashSet::new();
		for segment in Segment::iter() {
			if ! digits[0].contains(&segment) { continue };
			if ! digits[1].contains(&segment) { continue };
			if ! digits[2].contains(&segment) { continue };
			common.insert(segment);
		}
		self.a.retain(|s| common.contains(s));
		self.d.retain(|s| common.contains(s));
		self.g.retain(|s| common.contains(s));

		for segment in common {
			self.b.remove(&segment);
			self.c.remove(&segment);
			self.e.remove(&segment);
			self.f.remove(&segment);
		}
		self.check();
	}

	fn filter_zero_six_nine(&mut self, digits: &[&HashSet<Segment>;3]) {
		// 0, 6 and 9 are each missing 1 segment, they are C, D, and E
		let mut missing: HashSet<Segment> = HashSet::new();
		for digit in digits {
			for segment in Segment::iter() {
				if digit.contains(&segment) { continue };
				missing.insert(segment);
			}
		}
		// Now missing contains C, D, and E
		for segment in missing {
			self.f.remove(&segment);
		}

		for segment in &self.f {
			self.c.remove(&segment);
		}
	}

	pub fn solve(&mut self, inputs: Vec<HashSet<Segment>>) -> Solution {
		let mut one: usize = 0;
		let mut four: usize = 0;
		let mut seven: usize = 0;
		let mut seg_235: Vec<usize> = vec![];
		let mut seg_069: Vec<usize> = vec![];

		for (i, val) in inputs.iter().enumerate() {
			match val.len() {
				2 => {one = i;}
				3 => {seven = i;}
				4 => {four = i;}
				5 => {seg_235.push(i);}
				6 => {seg_069.push(i);}
				_ => {}
			}
		}

		self.solve_args(&inputs[one],
			            &inputs[four],
			            &inputs[seven],
			            &[&inputs[seg_235[0]],&inputs[seg_235[1]],&inputs[seg_235[2]]],
			            &[&inputs[seg_069[0]],&inputs[seg_069[1]],&inputs[seg_069[2]]])
	}

	fn solve_args(&mut self,
		one: &HashSet<Segment>,
		four: &HashSet<Segment>,
		seven: &HashSet<Segment>,
		seg_235: &[&HashSet<Segment>;3],
		seg_069: &[&HashSet<Segment>;3]) -> Solution {
		//println!("one: {:?}", one);
		//println!("four: {:?}", four);
		//println!("seven: {:?}", seven);
		//println!("seg_235: {:?}", seg_235);
		//println!("seg_069: {:?}", seg_069);
		self.filter_one(one);
		self.check();
		self.filter_four(four);
		self.check();
		self.filter_seven(seven);
		self.check();
		self.filter_two_three_five(seg_235);
		self.check();
		self.filter_zero_six_nine(seg_069);
		self.assert_done();
		Solution::new(self)
	}
}
