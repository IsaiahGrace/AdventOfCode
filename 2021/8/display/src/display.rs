use crate::digit::Digit;
use std::fmt;

#[derive(Debug)]
pub struct Display {
    digits: Vec<Digit>,
}

impl Display {
    pub fn new() -> Display {
        Display {
            digits: Vec::new(),
        }
    }

    pub fn push(&mut self, digit: i8) {
        self.digits.push(Digit::new(digit % 10));
    }
}

impl fmt::Display for Display {
    // This trait requires `fmt` with this exact signature.
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut lines: [String;7] = Default::default();
        for digit in &self.digits {
            let digit_lines = digit.print_lines();
            for i in 0..7 {
                lines[i].push_str(&digit_lines[i]);
                lines[i].push_str("  ");
            }
        }
        write!(f, "{}\n{}\n{}\n{}\n{}\n{}\n{}", lines[0], lines[1], lines[2], lines[3], lines[4], lines[5], lines[6])
    }
}
