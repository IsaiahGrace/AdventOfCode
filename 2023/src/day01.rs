use crate::puzzle;
use std::error;

pub struct Day01 {
    input: String,
}

impl Day01 {
    fn solve_p1(&self) -> i64 {
        let mut calibration_sum: i64 = 0;
        for line in self.input.lines() {
            let first = line.find(|c: char| c.is_ascii_digit()).unwrap();
            let last = line.rfind(|c: char| c.is_ascii_digit()).unwrap();
            calibration_sum +=
                i64::from((line.as_bytes()[first] - b'0') * 10 + (line.as_bytes()[last] - b'0'));
        }
        return calibration_sum;
    }
}

impl From<String> for Day01 {
    fn from(input: String) -> Self {
        Day01 { input }
    }
}

impl puzzle::Solve for Day01 {
    fn solve(&self) -> Result<puzzle::Solution, Box<dyn error::Error>> {
        return Ok(puzzle::Solution::Integer(self.solve_p1(), 0));
    }
}
