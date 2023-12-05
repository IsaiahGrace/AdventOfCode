use crate::puzzle;
use std::collections::HashSet;

struct Card {
    winning_numbers: HashSet<i64>,
    random_numbers: HashSet<i64>,
}

impl From<&str> for Card {
    fn from(line: &str) -> Self {
        let (_card_num, numbers) = line.split_once(":").unwrap();
        let (winning, random) = numbers.split_once("|").unwrap();
        Card {
            winning_numbers: winning
                .split_whitespace()
                .map(|n| n.parse::<i64>().unwrap())
                .collect(),
            random_numbers: random
                .split_whitespace()
                .map(|n| n.parse::<i64>().unwrap())
                .collect(),
        }
    }
}

pub struct Day04 {
    copies: Vec<i64>,
    cards: Vec<Card>,
}

impl Day04 {
    fn solve_p1(&self) -> i64 {
        self.cards
            .iter()
            .map(|c| c.winning_numbers.intersection(&c.random_numbers))
            .map(|i| i.count())
            .filter(|n| *n != 0)
            .map(|n| i64::pow(2, (n - 1).try_into().unwrap()))
            .sum()
    }

    fn solve_p2(&mut self) -> i64 {
        for (i, card) in self.cards.iter().enumerate() {
            let points = card
                .winning_numbers
                .intersection(&card.random_numbers)
                .count();
            for x in 1..=points {
                self.copies[i + x] += self.copies[i];
            }
        }
        return self.copies.iter().sum();
    }
}

impl From<String> for Day04 {
    fn from(input: String) -> Self {
        Day04 {
            copies: Vec::from_iter(std::iter::repeat(1).take(input.lines().count())),
            cards: input.lines().map(Card::from).collect(),
        }
    }
}

impl puzzle::Solve for Day04 {
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
        let mut solver: Day04 = std::fs::read_to_string("04/01").unwrap().into();
        assert_eq!(solver.solve().unwrap(), crate::Solution::Integer(13, 30));
    }

    #[test]
    fn file_input() {
        let mut solver: Day04 = std::fs::read_to_string("04/input").unwrap().into();
        assert_eq!(
            solver.solve().unwrap(),
            crate::Solution::Integer(33950, 14814534)
        );
    }
}
