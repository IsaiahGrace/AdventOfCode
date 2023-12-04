use crate::puzzle;

struct Sample {
    red: u8,
    green: u8,
    blue: u8,
}

fn is_sample_valid_part1(s: &Sample) -> bool {
    s.red <= 12 && s.green <= 13 && s.blue <= 14
}

impl From<&str> for Sample {
    fn from(sample_text: &str) -> Self {
        let mut sample = Sample {
            red: 0,
            green: 0,
            blue: 0,
        };
        for s in sample_text.split(",") {
            let (number, color) = s.trim().split_once(" ").unwrap();
            let parsed_number = number.parse::<u8>().unwrap();
            match color {
                "red" => sample.red = parsed_number,
                "green" => sample.green = parsed_number,
                "blue" => sample.blue = parsed_number,
                _ => panic!("Invalid color: {}", color),
            }
        }
        return sample;
    }
}

struct Game {
    id: i64,
    samples: Vec<Sample>,
}

struct GameSoA {
    red: Vec<i64>,
    green: Vec<i64>,
    blue: Vec<i64>,
}

impl From<&Game> for GameSoA {
    fn from(game: &Game) -> Self {
        GameSoA {
            red: game.samples.iter().map(|s| i64::from(s.red)).collect(),
            green: game.samples.iter().map(|s| i64::from(s.green)).collect(),
            blue: game.samples.iter().map(|s| i64::from(s.blue)).collect(),
        }
    }
}

pub struct Day02 {
    games: Vec<Game>,
}

impl Day02 {
    fn solve_p1(&self) -> i64 {
        self.games
            .iter()
            .filter(|g| g.samples.iter().all(is_sample_valid_part1))
            .fold(0, |acc, g| acc + g.id)
    }

    fn solve_p2(&self) -> i64 {
        self.games
            .iter()
            .map(GameSoA::from)
            .map(|g| {
                g.red.into_iter().reduce(i64::max).unwrap()
                    * g.green.into_iter().reduce(i64::max).unwrap()
                    * g.blue.into_iter().reduce(i64::max).unwrap()
            })
            .sum()
    }
}

impl From<String> for Day02 {
    fn from(input: String) -> Self {
        Day02 {
            games: input
                .lines()
                .map(|l| {
                    // Game 1: 3 blue, 4 red;
                    // prefix: suffix
                    let (prefix, suffix) = l.split_once(":").unwrap();
                    Game {
                        id: prefix
                            .strip_prefix("Game ")
                            .unwrap()
                            .parse::<i64>()
                            .unwrap(),
                        samples: suffix.split(";").map(Sample::from).collect(),
                    }
                })
                .collect(),
        }
    }
}

impl puzzle::Solve for Day02 {
    fn solve(&self) -> Result<puzzle::Solution, Box<dyn std::error::Error>> {
        Ok(puzzle::Solution::Integer(self.solve_p1(), self.solve_p2()))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::puzzle::Solve;

    #[test]
    fn file_01() {
        let solver: Day02 = std::fs::read_to_string("02/01").unwrap().into();
        assert_eq!(solver.solve().unwrap(), crate::Solution::Integer(8, 2286));
    }

    #[test]
    fn file_input() {
        let solver: Day02 = std::fs::read_to_string("02/input").unwrap().into();
        assert_eq!(
            solver.solve().unwrap(),
            crate::Solution::Integer(2101, 58269)
        );
    }
}
