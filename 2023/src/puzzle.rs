use std::error;
use std::fmt;

#[derive(Debug, PartialEq)]
pub enum Solution {
    Integer(i64, i64),
}

impl fmt::Display for Solution {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Solution::Integer(p1, p2) => write!(f, "part1: {}\npart2: {}", p1, p2),
        }
    }
}

pub trait Solve {
    fn solve(&mut self) -> Result<Solution, Box<dyn error::Error>>;
}
