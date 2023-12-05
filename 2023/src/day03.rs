use crate::puzzle;
use std::collections::HashMap;

#[derive(Clone, Copy, Debug, PartialEq)]
enum State {
    Searching,
    ReadingDigits,
    Validating,
}

pub struct Day03 {
    schematic: Vec<String>,
    gears: HashMap<(usize, usize), (i64, i64)>,
}

impl Day03 {
    fn solve_p1(&mut self) -> i64 {
        (1..(self.schematic.len() - 1))
            .map(|line_num| self.read_line(line_num).into_iter().sum::<i64>())
            .sum()
    }

    fn solve_p2(&mut self) -> i64 {
        self.gears.drain().map(|(_k, v)| v.0 * v.1).sum()
    }

    fn read_line(&mut self, line_num: usize) -> Vec<i64> {
        let mut byte_start: usize = 0;
        let mut byte_end: usize = 0;

        let line = self.schematic[line_num].as_bytes();

        let mut search_state = State::Searching;
        let mut part_number: i64 = 0;
        let mut idx: usize = 0;

        let mut parts: Vec<i64> = vec![];

        while idx < line.len() {
            match search_state {
                State::Searching => match line[idx] {
                    b'0'..=b'9' => {
                        byte_start = idx - 1;
                        part_number = 0;
                        search_state = State::ReadingDigits;
                    }
                    _ => idx += 1,
                },
                State::ReadingDigits => match line[idx] {
                    b'0'..=b'9' => {
                        part_number = (part_number * 10) + i64::from(line[idx] - b'0');
                        idx += 1;
                    }
                    _ => {
                        byte_end = idx;
                        search_state = State::Validating;
                    }
                },
                State::Validating => {
                    for l in line_num - 1..=line_num + 1 {
                        let s = &self.schematic[l][byte_start..=byte_end];
                        for (col, c) in s.chars().enumerate() {
                            match c {
                                '*' => {
                                    parts.push(part_number);
                                    let pos = (l, byte_start + col);
                                    let mut gear_parts = self.gears.remove(&pos).unwrap_or((0, 0));
                                    if gear_parts.0 == 0 {
                                        gear_parts.0 = part_number;
                                    } else if gear_parts.1 == 0 {
                                        gear_parts.1 = part_number;
                                    } else {
                                        panic!("A third part attached to a gear!?");
                                    }
                                    self.gears.insert(pos, gear_parts);
                                }
                                '#' | '%' | '&' | '+' | '-' | '/' | '=' | '@' | '$' => {
                                    parts.push(part_number);
                                }
                                _ => {}
                            }
                        }
                    }
                    idx += 1;
                    part_number = 0;
                    search_state = State::Searching;
                }
            }
        }
        return parts;
    }
}

impl From<String> for Day03 {
    fn from(input: String) -> Self {
        // We're going to add a border of '.' so that no digits will be on the edges of the schematic.
        let mut schematic: Vec<String> = input.lines().map(String::from).collect();
        let line_length = schematic.first().unwrap().len();

        schematic.insert(0, ".".repeat(line_length));
        schematic.push(".".repeat(line_length));

        for line in schematic.iter_mut() {
            line.insert(0, '.');
            line.push('.');
        }

        Day03 {
            schematic,
            gears: HashMap::new(),
        }
    }
}

impl puzzle::Solve for Day03 {
    fn solve(&mut self) -> Result<puzzle::Solution, Box<dyn std::error::Error>> {
        // We need to call solve_p1() before we can call solve_p2().
        let part1 = self.solve_p1();
        let part2 = self.solve_p2();
        Ok(puzzle::Solution::Integer(part1, part2))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::puzzle::Solve;

    #[test]
    fn file_01() {
        let mut solver: Day03 = std::fs::read_to_string("03/01").unwrap().into();
        assert_eq!(
            solver.solve().unwrap(),
            crate::Solution::Integer(4361, 467835)
        );
    }

    #[test]
    fn file_input() {
        let mut solver: Day03 = std::fs::read_to_string("03/input").unwrap().into();
        assert_eq!(
            solver.solve().unwrap(),
            crate::Solution::Integer(546563, 91031374)
        );
    }
}
