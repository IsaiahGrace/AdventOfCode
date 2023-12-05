use crate::puzzle;

#[derive(Clone, Copy, Debug, PartialEq)]
enum State {
    Searching,
    ReadingDigits,
    Validating,
}

pub struct Day03 {
    schematic: Vec<String>,
}

impl Day03 {
    fn solve_p1(&self) -> i64 {
        (1..(self.schematic.len() - 1))
            .map(|line_num| self.read_line(line_num).into_iter().sum::<i64>())
            .sum()
    }

    fn read_line(&self, line_num: usize) -> Vec<i64> {
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
                    if (line_num - 1..=line_num + 1)
                        .map(|l| &self.schematic[l][byte_start..=byte_end])
                        .any(|s| {
                            s.chars().any(|c| match c {
                                '#' | '%' | '&' | '*' | '+' | '-' | '/' | '=' | '@' | '$' => true,
                                _ => false,
                            })
                        })
                    {
                        parts.push(part_number);
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

        Day03 { schematic }
    }
}

impl puzzle::Solve for Day03 {
    fn solve(&self) -> Result<puzzle::Solution, Box<dyn std::error::Error>> {
        Ok(puzzle::Solution::Integer(self.solve_p1(), 0))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::puzzle::Solve;

    #[test]
    fn file_01() {
        let solver: Day03 = std::fs::read_to_string("03/01").unwrap().into();
        assert_eq!(solver.solve().unwrap(), crate::Solution::Integer(4361, 0));
    }

    #[test]
    fn file_input() {
        let solver: Day03 = std::fs::read_to_string("03/input").unwrap().into();
        assert_eq!(solver.solve().unwrap(), crate::Solution::Integer(546563, 0));
    }
}
