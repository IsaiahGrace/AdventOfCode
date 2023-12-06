use crate::puzzle;
use std::collections::BTreeMap;
use std::ops::Bound;
use std::ops::Range;

trait Offset<T> {
    fn offset(&self, offset: T) -> Self;
}

impl Offset<i64> for Range<i64> {
    fn offset(&self, offset: i64) -> Self {
        (self.start + offset)..(self.end + offset)
    }
}

trait Intersection<T = Self> {
    fn intersection(&self, other: &T) -> Self;
}

impl Intersection<Range<i64>> for Range<i64> {
    /// Returns the intersection, or overlap, of two ranges.
    /// If there is not overlap in the ranges, then an empty range where end > start is returned.
    fn intersection(&self, other: &Range<i64>) -> Self {
        println!(
            "intersection: {:?}",
            std::cmp::max(self.start, other.start)..std::cmp::min(self.end, other.end)
        );
        std::cmp::max(self.start, other.start)..std::cmp::min(self.end, other.end)
    }
}

// trait Remainder<T = Self> {
//     fn remainder(&self, other: &T) -> Self;
// }

// impl Remainder<Range<i64>> for Range<i64> {
//     /// Returns the remaining range after removing other range from self.
//     /// If `other.end > self.end` then the empty range `0..0` is returned.
//     fn remainder(&self, other: &Range<i64>) -> Self {
//         // dbg!("REMAINDER");
//         // dbg!(self);
//         // dbg!(other);
//         if other.end > self.end {
//             self.start..other.end
//         } else {
//             std::cmp::max(self.start, other.end)..self.end
//         }
//     }
// }

fn range_remainder(this: &Range<i64>, other: &Range<i64>) -> Vec<Range<i64>> {
    // There are 6 cases to consider
    dbg!(&this);
    dbg!(&other);

    // 1. No overlap, other is less than this
    if other.end <= this.start {
        println!("1. No overlap, other is less than this");
        return vec![this.clone()];
    }

    // 2. Overlap on the lower part of this
    if other.start <= this.start && other.end < this.end {
        println!("2. Overlap on the lower part of this");
        return vec![{ other.end..this.end }];
    }

    // 3. Overlap in the middle of this, but on neither ends
    if other.start > this.start && other.end < this.end {
        println!("3. Overlap in the middle of this, but on neither ends");
        return vec![{ this.start..other.start }, { other.end..this.end }];
    }

    // 4. Overlap in the upper part of this
    if other.start > this.start && other.end >= this.end {
        println!("4. Overlap in the upper part of this");
        return vec![{ this.start..other.start }];
    }

    // 5. No overlap, other is greater than this
    if other.start >= this.end {
        println!("5. No overlap, other is greater than this");
        return vec![this.clone()];
    }

    // 6. other completely overlaps this
    if other.start <= this.start && other.end >= this.end {
        println!("6. other completely overlaps this");
        return vec![];
    }

    panic!("There's a bug in range_remainder!");
}

#[derive(Debug, PartialEq)]
struct MapEntry {
    dst: i64,
    src: i64,
    range: i64,
    src_range: Range<i64>,
    offset: i64,
}

impl From<&str> for MapEntry {
    fn from(line: &str) -> Self {
        let mut iter = line.trim().split_whitespace();
        let dst = iter.next().unwrap().parse().unwrap();
        let src = iter.next().unwrap().parse().unwrap();
        let range = iter.next().unwrap().parse().unwrap();
        let src_range = src..src + range;
        let offset = dst - src;
        MapEntry {
            dst,
            src,
            range,
            src_range,
            offset,
        }
    }
}

#[derive(Debug)]
struct Alminac {
    map: BTreeMap<i64, MapEntry>,
}

impl Alminac {
    /// Transforms a single entry using the map.
    fn lookup(&self, src: i64) -> i64 {
        let Some(entry) = self
            .map
            .range((Bound::Unbounded, Bound::Included(src)))
            .next_back()
        else {
            return src;
        };
        if entry.0 + entry.1.range >= src {
            return entry.1.dst + (src - entry.0);
        } else {
            return src;
        }
    }

    /// Transforms a range of numbers into a collection of transformed ranges.
    fn lookup_range(&self, src: Range<i64>) -> Vec<Range<i64>> {
        dbg!("START LOOKUP");
        let mut remainder_ranges = vec![src.clone()];
        let mut transformed_ranges = vec![];

        // Get all B-tree entries with src values up to and including the max number on our input range.
        let potentially_applicable_ranges =
            self.map.range((Bound::Unbounded, Bound::Excluded(src.end)));

        // For each potentially applicable range, find the intersection, and offset if needed.
        while !remainder_ranges.is_empty() {
            println!("START LOOP");
            dbg!(&remainder_ranges);
            dbg!(&transformed_ranges);

            if (remainder_ranges.len() > 10) || (transformed_ranges.len() > 10) {
                panic!("infinte loop!");
            }
            let input = remainder_ranges.pop().unwrap();

            let Some(transform) = potentially_applicable_ranges
                .clone()
                .find(|par| !input.intersection(&par.1.src_range).is_empty())
            else {
                println!(
                    "No transformation are applicable, pushing untransformed range: {:?}",
                    input
                );
                transformed_ranges.push(input);
                break;
            };

            let applicable_range = input.intersection(&transform.1.src_range);
            let transformed_range = applicable_range.offset(transform.1.offset);

            println!("transformation applicable:");
            dbg!(&transform);
            println!("applicable range:");
            dbg!(&applicable_range);
            println!("transformed range:");
            dbg!(&transformed_range);

            transformed_ranges.push(transformed_range);

            let remainders = range_remainder(&input, &transform.1.src_range);

            println!("remaining range: {:?}", remainders);
            for remainder in remainders {
                if !remainder.is_empty() {
                    remainder_ranges.push(remainder);
                }
            }

            // for potential_transformation in potentially_applicable_ranges.clone() {
            //     dbg!(&potential_transformation);
            //     let applicable_range = input.intersection(&potential_transformation.1.src_range);
            //     dbg!(&applicable_range);

            //     if applicable_range.is_empty() {
            //         dbg!("transformation not applicable");
            //         continue;
            //     }

            //     dbg!("transformation applicable");
            //     transformed_ranges.push(applicable_range.offset(potential_transformation.1.offset));
            //     let remainder = input.remainder(&potential_transformation.1.src_range);

            //     dbg!(&remainder);
            //     if !remainder.is_empty() {
            //         remainder_ranges.push(remainder);
            //     }
            // }
        }

        // We need to break apart the input range
        return transformed_ranges;
    }
}

impl From<&str> for Alminac {
    fn from(lines: &str) -> Self {
        Alminac {
            map: BTreeMap::from_iter(lines.lines().map(MapEntry::from).map(|e| (e.src, e))),
        }
    }
}

impl From<Vec<&str>> for Alminac {
    fn from(lines: Vec<&str>) -> Self {
        Alminac {
            map: BTreeMap::from_iter(lines.into_iter().map(MapEntry::from).map(|e| (e.src, e))),
        }
    }
}

pub struct Day05 {
    seeds: Vec<i64>,
    seed_ranges: Vec<Range<i64>>,
    seed_to_soil: Alminac,
    soil_to_fertilizer: Alminac,
    fertilizer_to_water: Alminac,
    water_to_light: Alminac,
    light_to_temperature: Alminac,
    temperature_to_humidity: Alminac,
    humidity_to_location: Alminac,
}

impl Day05 {
    fn solve_p1(&mut self) -> i64 {
        self.seeds
            .iter()
            .cloned()
            .map(|s| self.seed_to_soil.lookup(s))
            .map(|s| self.soil_to_fertilizer.lookup(s))
            .map(|s| self.fertilizer_to_water.lookup(s))
            .map(|s| self.water_to_light.lookup(s))
            .map(|s| self.light_to_temperature.lookup(s))
            .map(|s| self.temperature_to_humidity.lookup(s))
            .map(|s| self.humidity_to_location.lookup(s))
            .min()
            .unwrap()
    }

    fn solve_p2(&mut self) -> i64 {
        self.seed_ranges
            .clone()
            .into_iter()
            .flat_map(|r| self.seed_to_soil.lookup_range(r))
            .flat_map(|r| self.soil_to_fertilizer.lookup_range(r))
            .flat_map(|r| self.fertilizer_to_water.lookup_range(r))
            .flat_map(|r| self.water_to_light.lookup_range(r))
            .flat_map(|r| self.light_to_temperature.lookup_range(r))
            .flat_map(|r| self.temperature_to_humidity.lookup_range(r))
            .flat_map(|r| self.humidity_to_location.lookup_range(r))
            .map(Range::min)
            .min()
            .unwrap()
            .unwrap()
    }
}

impl From<String> for Day05 {
    fn from(input: String) -> Self {
        let seed_ranges = input
            .lines()
            .next()
            .unwrap()
            .strip_prefix("seeds: ")
            .unwrap()
            .split_whitespace()
            .map(|n| n.parse::<i64>().unwrap())
            .collect::<Vec<i64>>()
            .chunks_exact(2)
            .map(|s| (s[0]..s[0] + s[1]))
            .collect();

        let mut lines = input.lines();
        let seeds = Vec::from_iter(
            lines
                .next()
                .unwrap()
                .strip_prefix("seeds: ")
                .unwrap()
                .split_whitespace()
                .map(|n| n.parse::<i64>().unwrap()),
        );

        assert_eq!(lines.next(), Some(""));

        assert_eq!(lines.next(), Some("seed-to-soil map:"));
        let seed_to_soil =
            Alminac::from(lines.by_ref().take_while(|l| *l != "").collect::<Vec<_>>());

        assert_eq!(lines.next(), Some("soil-to-fertilizer map:"));
        let soil_to_fertilizer =
            Alminac::from(lines.by_ref().take_while(|l| *l != "").collect::<Vec<_>>());

        assert_eq!(lines.next(), Some("fertilizer-to-water map:"));
        let fertilizer_to_water =
            Alminac::from(lines.by_ref().take_while(|l| *l != "").collect::<Vec<_>>());

        assert_eq!(lines.next(), Some("water-to-light map:"));
        let water_to_light =
            Alminac::from(lines.by_ref().take_while(|l| *l != "").collect::<Vec<_>>());

        assert_eq!(lines.next(), Some("light-to-temperature map:"));
        let light_to_temperature =
            Alminac::from(lines.by_ref().take_while(|l| *l != "").collect::<Vec<_>>());

        assert_eq!(lines.next(), Some("temperature-to-humidity map:"));
        let temperature_to_humidity =
            Alminac::from(lines.by_ref().take_while(|l| *l != "").collect::<Vec<_>>());

        assert_eq!(lines.next(), Some("humidity-to-location map:"));
        let humidity_to_location =
            Alminac::from(lines.by_ref().take_while(|l| *l != "").collect::<Vec<_>>());

        // dbg!(&seeds);
        // dbg!(&seed_ranges);
        // dbg!(&seed_to_soil);
        // dbg!(&soil_to_fertilizer);
        // dbg!(&fertilizer_to_water);
        // dbg!(&water_to_light);
        // dbg!(&light_to_temperature);
        // dbg!(&temperature_to_humidity);
        // dbg!(&humidity_to_location);

        Day05 {
            seeds,
            seed_ranges,
            seed_to_soil,
            soil_to_fertilizer,
            fertilizer_to_water,
            water_to_light,
            light_to_temperature,
            temperature_to_humidity,
            humidity_to_location,
        }
    }
}

impl puzzle::Solve for Day05 {
    fn solve(&mut self) -> Result<puzzle::Solution, Box<dyn std::error::Error>> {
        Ok(puzzle::Solution::Integer(self.solve_p1(), self.solve_p2()))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::puzzle::Solve;
    use std::collections::HashSet;

    #[test]
    fn construct_map_entry() {
        let entry = MapEntry::from("100 200 25");
        assert_eq!(
            entry,
            MapEntry {
                dst: 100,
                src: 200,
                range: 25,
                src_range: 200..225,
                offset: -100,
            }
        );
    }

    #[test]
    fn range_offset() {
        assert_eq!((0..5).offset(10), (10..15));
        assert_eq!((10..15).offset(-10), (0..5));
    }

    #[test]
    fn range_intersection() {
        assert_eq!((10..20).intersection(&(20..25)), (20..20));
        assert_eq!((0..5).intersection(&(3..10)), (3..5));
        assert_eq!((10..15).intersection(&(20..30)), (20..15));
        assert!((10..15).intersection(&(20..30)).is_empty());
    }

    #[test]
    fn test_range_remainder() {
        assert_eq!(range_remainder(&(10..25), &(10..20)), vec![{ 20..25 }]);
        assert_eq!(range_remainder(&(5..10), &(0..5)), vec![{ 5..10 }]);
        assert_eq!(range_remainder(&(5..10), &(0..6)), vec![{ 6..10 }]);
        assert_eq!(
            range_remainder(&(5..10), &(6..8)),
            vec![{ 5..6 }, { 8..10 }]
        );
        assert_eq!(range_remainder(&(5..10), &(7..20)), vec![{ 5..7 }]);
        assert_eq!(range_remainder(&(5..10), &(10..20)), vec![{ 5..10 }]);
        assert_eq!(range_remainder(&(1..10), &(0..5)), vec![{ 5..10 }]);
        assert_eq!(range_remainder(&(10..15), &(0..5)), vec![{ 10..15 }]);
        assert_eq!(range_remainder(&(10..15), &(5..20)), vec![]);
        assert_eq!(range_remainder(&(1..11), &(10..20)), vec![{ 1..10 }]);
    }

    fn alminac_lookup_range_helper(
        alminac_str: &str,
        range: Range<i64>,
        expected: HashSet<Range<i64>>,
    ) {
        let alminac = Alminac::from(alminac_str);
        let actual: HashSet<Range<i64>> = HashSet::from_iter(alminac.lookup_range(range));

        // If there is no difference in the sets, then everything is okay.
        if actual.symmetric_difference(&expected).count() == 0 {
            return;
        };

        // Otherwise, we have an issue
        dbg!(&actual);
        dbg!(&expected);
        dbg!(actual.symmetric_difference(&expected).collect::<Vec<_>>());
        assert_eq!(actual.symmetric_difference(&expected).count(), 0);
    }

    #[test]
    fn alminac_lookup_range_01() {
        alminac_lookup_range_helper("100 10 10", 10..15, HashSet::from([100..105]));
    }

    #[test]
    fn alminac_lookup_range_02() {
        alminac_lookup_range_helper("100 10 10", 10..25, HashSet::from([100..110, 20..25]));
    }

    #[test]
    fn alminac_lookup_range_03() {
        alminac_lookup_range_helper("100 10 10", 1..11, HashSet::from([100..101, 1..10]));
    }

    #[test]
    fn file_01() {
        let mut solver: Day05 = std::fs::read_to_string("05/01").unwrap().into();
        assert_eq!(solver.solve().unwrap(), crate::Solution::Integer(35, 46));
    }

    // #[test]
    // fn file_input() {
    //     let mut solver: Day05 = std::fs::read_to_string("05/input").unwrap().into();
    //     assert_eq!(
    //         solver.solve().unwrap(),
    //         crate::Solution::Integer(825516882, 136096660)
    //     );
    // }
}
