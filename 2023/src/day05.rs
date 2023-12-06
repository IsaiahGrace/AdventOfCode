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
        std::cmp::max(self.start, other.start)..std::cmp::min(self.end, other.end)
    }
}

fn range_remainder(this: &Range<i64>, other: &Range<i64>) -> Vec<Range<i64>> {
    // There are 6 cases to consider

    // 1. No overlap, other is less than this
    if other.end <= this.start {
        return vec![this.clone()];
    }

    // 2. Overlap on the lower part of this
    if other.start <= this.start && other.end < this.end {
        return vec![{ other.end..this.end }];
    }

    // 3. Overlap in the middle of this, but on neither ends
    if other.start > this.start && other.end < this.end {
        return vec![{ this.start..other.start }, { other.end..this.end }];
    }

    // 4. Overlap in the upper part of this
    if other.start > this.start && other.end >= this.end {
        return vec![{ this.start..other.start }];
    }

    // 5. No overlap, other is greater than this
    if other.start >= this.end {
        return vec![this.clone()];
    }

    // 6. other completely overlaps this
    if other.start <= this.start && other.end >= this.end {
        return vec![];
    }

    panic!("There's a bug in range_remainder!");
}

#[derive(Debug, PartialEq)]
struct MapEntry {
    src: Range<i64>,
    offset: i64,
}

impl From<&str> for MapEntry {
    fn from(line: &str) -> Self {
        let mut iter = line.trim().split_whitespace();
        let dst: i64 = iter.next().unwrap().parse().unwrap();
        let src_start = iter.next().unwrap().parse().unwrap();
        let range: i64 = iter.next().unwrap().parse().unwrap();
        let src = src_start..src_start + range;
        let offset = dst - src_start;
        MapEntry { src, offset }
    }
}

#[derive(Debug)]
struct Alminac {
    map: BTreeMap<i64, MapEntry>,
}

impl Alminac {
    /// Transforms a range of numbers into a collection of transformed ranges.
    fn lookup_range(&self, src: Range<i64>) -> Vec<Range<i64>> {
        let mut input_ranges = vec![src.clone()];
        let mut output_ranges = vec![];

        // Get all B-tree entries with src ranges starting up to and including the end of our input range.
        let map_entries = self.map.range((Bound::Unbounded, Bound::Excluded(src.end)));

        // For each potentially applicable range, find the intersection, and offset if needed.
        while !input_ranges.is_empty() {
            let input = input_ranges.pop().unwrap();

            // This map entry does not transform the input.
            // We'll use it as the default if there are no "real" transformations applicable.
            let identity_map_entry = MapEntry {
                src: input.clone(),
                offset: 0,
            };

            // Find a transformation which applies to the input, if none, use the identity element.
            let transform = map_entries
                .clone()
                .map(|kvp| kvp.1)
                .find(|e| !input.intersection(&e.src).is_empty())
                .unwrap_or(&identity_map_entry);

            // Transform the input and push it to the output_ranges vec
            output_ranges.push(input.intersection(&transform.src).offset(transform.offset));

            // If there are any leftover ranges which must be considered, put them into the input_ranges vec
            input_ranges.extend(
                range_remainder(&input, &transform.src)
                    .into_iter()
                    .filter(|r| !r.is_empty()),
            );
        }
        return output_ranges;
    }
}

impl From<&str> for Alminac {
    fn from(lines: &str) -> Self {
        Alminac {
            map: BTreeMap::from_iter(lines.lines().map(MapEntry::from).map(|e| (e.src.start, e))),
        }
    }
}

impl From<Vec<&str>> for Alminac {
    fn from(lines: Vec<&str>) -> Self {
        Alminac {
            map: BTreeMap::from_iter(
                lines
                    .into_iter()
                    .map(MapEntry::from)
                    .map(|e| (e.src.start, e)),
            ),
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
            .map(|s| (s..s + 1)) // We can use ranges to solve part 1!
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
                src: 200..225,
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

    #[test]
    fn file_input() {
        let mut solver: Day05 = std::fs::read_to_string("05/input").unwrap().into();
        assert_eq!(
            solver.solve().unwrap(),
            crate::Solution::Integer(825516882, 136096660)
        );
    }
}
