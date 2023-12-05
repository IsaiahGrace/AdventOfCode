use crate::puzzle;

pub struct Day01 {
    input: String,
}

fn get_calibration(line: &str) -> i64 {
    let mut filter = line.chars().filter(char::is_ascii_digit);
    // Some example inputs aren't valid for part 1 rules, in these cases we'll just return 0.
    let first = filter.next().unwrap_or('0');
    let last = filter.last().unwrap_or(first);
    let first_byte = u8::try_from(first).unwrap();
    let last_byte = u8::try_from(last).unwrap();
    return i64::from((first_byte - b'0') * 10 + (last_byte - b'0'));
}

impl Day01 {
    fn solve_p1(&self) -> i64 {
        self.input.lines().map(get_calibration).sum()
    }

    fn solve_p2(&self) -> i64 {
        self.input
            // Note the strange replace strings. This is to account for partial overlaps in the input data.
            .replace("one", "o1e") // twone, oneight
            .replace("two", "t2o") // eightwo, twone
            .replace("three", "t3e") // eighthree, threeight
            .replace("four", "4")
            .replace("five", "5e") // fiveight
            .replace("six", "6")
            .replace("seven", "7n") // sevenine
            .replace("eight", "e8t") // threeight, eightwo, eighthree
            .replace("nine", "n9e") // sevenine, nineight
            .lines()
            .map(get_calibration)
            .sum()
    }
}

impl From<String> for Day01 {
    fn from(input: String) -> Self {
        Day01 { input }
    }
}

impl puzzle::Solve for Day01 {
    fn solve(&mut self) -> Result<puzzle::Solution, Box<dyn std::error::Error>> {
        Ok(puzzle::Solution::Integer(self.solve_p1(), self.solve_p2()))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::puzzle::Solve;

    #[test]
    fn file_01() {
        let mut solver: Day01 = std::fs::read_to_string("01/01").unwrap().into();
        assert_eq!(solver.solve().unwrap(), crate::Solution::Integer(142, 142));
    }

    #[test]
    fn file_02() {
        let mut solver: Day01 = std::fs::read_to_string("01/02").unwrap().into();
        assert_eq!(solver.solve().unwrap(), crate::Solution::Integer(209, 281));
    }

    #[test]
    fn file_input() {
        let mut solver: Day01 = std::fs::read_to_string("01/input").unwrap().into();
        assert_eq!(
            solver.solve().unwrap(),
            crate::Solution::Integer(55488, 55614)
        );
    }

    #[test]
    fn test_get_calibration() {
        assert_eq!(get_calibration("1abc2"), 12);
        assert_eq!(get_calibration("pqr3stu8vwx"), 38);
        assert_eq!(get_calibration("a1b2c3d4e5f"), 15);
        assert_eq!(get_calibration("treb7uchet"), 77);
    }
}
