use crate::puzzle;
use rayon::prelude::*;
use std::collections::BTreeMap;
use std::ops::Bound;
use std::ops::Range;

#[derive(Debug)]
struct MapEntry {
    dst: i64,
    src: i64,
    range: i64,
}

impl From<&str> for MapEntry {
    fn from(line: &str) -> Self {
        let mut iter = line.trim().split_whitespace();
        let mut entry = MapEntry {
            dst: 0,
            src: 0,
            range: 0,
        };
        entry.dst = iter.next().unwrap().parse().unwrap();
        entry.src = iter.next().unwrap().parse().unwrap();
        entry.range = iter.next().unwrap().parse().unwrap();
        return entry;
    }
}

#[derive(Debug)]
struct Alminac {
    map: BTreeMap<i64, MapEntry>,
}

impl Alminac {
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
            .iter()
            .map(|r| {
                r.clone()
                    .par_iter()
                    // .map(|seed| {
                    //     dbg!(seed);
                    //     seed
                    // })
                    .map(|s| self.seed_to_soil.lookup(s))
                    // .map(|soil| {
                    //     dbg!(soil);
                    //     soil
                    // })
                    .map(|s| self.soil_to_fertilizer.lookup(s))
                    // .map(|fertilizer| {
                    //     dbg!(fertilizer);
                    //     fertilizer
                    // })
                    .map(|s| self.fertilizer_to_water.lookup(s))
                    // .map(|water| {
                    //     dbg!(water);
                    //     water
                    // })
                    .map(|s| self.water_to_light.lookup(s))
                    // .map(|light| {
                    //     dbg!(light);
                    //     light
                    // })
                    .map(|s| self.light_to_temperature.lookup(s))
                    // .map(|temperature| {
                    //     dbg!(temperature);
                    //     temperature
                    // })
                    .map(|s| self.temperature_to_humidity.lookup(s))
                    // .map(|humidity| {
                    //     dbg!(humidity);
                    //     humidity
                    // })
                    .map(|s| self.humidity_to_location.lookup(s))
                    // .map(|location| {
                    //     dbg!(location);
                    //     location
                    // })
                    .min()
                    .unwrap()
            })
            .min()
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

    #[test]
    fn construct_map_entry() {
        let entry = MapEntry::from("3547471595 1239929038 174680800");
        assert_eq!(entry.dst, 3547471595);
        assert_eq!(entry.src, 1239929038);
        assert_eq!(entry.range, 174680800);

        let entry = MapEntry::from("787487885 0 54862533");
        assert_eq!(entry.dst, 787487885);
        assert_eq!(entry.src, 0);
        assert_eq!(entry.range, 54862533);
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
