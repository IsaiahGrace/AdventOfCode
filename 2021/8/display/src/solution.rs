use crate::segment_set;
use std::collections::HashSet;
use crate::SegmentMap;
use crate::Segment;

#[derive(Debug)]
pub struct Solution {
	pub a: Segment,
	pub b: Segment,
	pub c: Segment,
	pub d: Segment,
	pub e: Segment,
	pub f: Segment,
	pub g: Segment,
}

impl Solution {
	pub fn new(map: &SegmentMap) -> Solution {
		Solution {
			a: *map.a.iter().next().unwrap(),
			b: *map.b.iter().next().unwrap(),
			c: *map.c.iter().next().unwrap(),
			d: *map.d.iter().next().unwrap(),
			e: *map.e.iter().next().unwrap(),
			f: *map.f.iter().next().unwrap(),
			g: *map.g.iter().next().unwrap(),
		}
	}

	pub fn decode(&self, code: HashSet<Segment>) -> i32 {
		let mut segments = HashSet::new();

		// Remember, self.a might be Segment::D
		// This is the solution mapping...

		if code.contains(&self.a) {segments.insert(Segment::A);}
		if code.contains(&self.b) {segments.insert(Segment::B);}
		if code.contains(&self.c) {segments.insert(Segment::C);}
		if code.contains(&self.d) {segments.insert(Segment::D);}
		if code.contains(&self.e) {segments.insert(Segment::E);}
		if code.contains(&self.f) {segments.insert(Segment::F);}
		if code.contains(&self.g) {segments.insert(Segment::G);}

		for i in 0..10 {
			if segment_set(i) == segments { return i };
		}
		panic!("Could not find a digit matching the segment set: {:?}", segments);
	}
}
