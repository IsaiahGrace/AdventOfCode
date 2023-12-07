use crate::puzzle;
use std::ops::Range;

/// Solves a special case of the quadratic formula where a = -1
/// The bounds are both rounded up to the nearest integer
fn solve_poly_roots(b: i64, c: i64) -> Range<i64> {
    let bf = b as f64;
    let cf = c as f64;
    assert!((bf * bf + 4.0 * cf) > 0.0);
    let sqrt = (bf * bf + 4.0 * cf).sqrt();
    let mut x1 = (-bf + sqrt) / -2.0;
    let x2 = (-bf - sqrt) / -2.0;

    if x1.floor() == x1.ceil() {
        x1 += 1.0;
    }

    x1.ceil() as i64..x2.ceil() as i64
}

pub struct Day06 {
    times: Vec<i64>,
    dists: Vec<i64>,
    p2_time: i64,
    p2_dist: i64,
}

impl Day06 {
    fn solve_p1(&self) -> i64 {
        self.times
            .iter()
            .zip(self.dists.iter())
            .map(|(b, c)| solve_poly_roots(*b, -c))
            .map(|r| r.end - r.start)
            .product()
    }

    fn solve_p2(&self) -> i64 {
        let range = solve_poly_roots(self.p2_time, -self.p2_dist);
        range.end - range.start
    }
}

impl From<String> for Day06 {
    fn from(input: String) -> Self {
        Day06 {
            times: input
                .lines()
                .next()
                .unwrap()
                .split_whitespace()
                .skip(1)
                .map(|n| n.parse::<i64>().unwrap())
                .collect(),
            dists: input
                .lines()
                .skip(1)
                .next()
                .unwrap()
                .split_whitespace()
                .skip(1)
                .map(|n| n.parse::<i64>().unwrap())
                .collect(),
            p2_time: input
                .lines()
                .next()
                .unwrap()
                .strip_prefix("Time:")
                .unwrap()
                .split_whitespace()
                .collect::<String>()
                .parse::<i64>()
                .unwrap(),
            p2_dist: input
                .lines()
                .skip(1)
                .next()
                .unwrap()
                .strip_prefix("Distance:")
                .unwrap()
                .split_whitespace()
                .collect::<String>()
                .parse::<i64>()
                .unwrap(),
        }
    }
}

impl puzzle::Solve for Day06 {
    fn solve(&mut self) -> Result<puzzle::Solution, Box<dyn std::error::Error>> {
        Ok(puzzle::Solution::Integer(self.solve_p1(), self.solve_p2()))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::puzzle::Solve;

    #[test]
    fn test_solve_poly_roots() {
        assert_eq!(solve_poly_roots(15, -40), 4..12);
        assert_eq!(solve_poly_roots(7, -9), 2..6);
    }

    #[test]
    fn file_01() {
        let mut solver: Day06 = std::fs::read_to_string("06/01").unwrap().into();
        assert_eq!(
            solver.solve().unwrap(),
            crate::Solution::Integer(288, 71503)
        );
    }

    #[test]
    fn file_input() {
        let mut solver: Day06 = std::fs::read_to_string("06/input").unwrap().into();
        assert_eq!(
            solver.solve().unwrap(),
            crate::Solution::Integer(4811940, 30077773)
        );
    }
}
