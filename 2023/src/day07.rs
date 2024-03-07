use crate::puzzle;
use fancy_regex::Regex;
use itertools::Itertools;

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
enum HandType {
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind,
}

fn compile_hand_regex() -> Vec<Regex> {
    vec![
        Regex::new(r"(.)\1{4}").unwrap(),
        Regex::new(r"(.)\1{3}").unwrap(),
        Regex::new(r"(.)\1{2}(.)\2").unwrap(),
        Regex::new(r"(.)\1(.)\2{2}").unwrap(),
        Regex::new(r"(.)\1{2}").unwrap(),
        Regex::new(r"(.)\1.?(.)\2").unwrap(),
        Regex::new(r"(.)\1").unwrap(),
    ]
}

impl From<&str> for HandType {
    fn from(hand: &str) -> Self {
        HandType::new(hand, compile_hand_regex())
    }
}

impl HandType {
    fn new(hand_in: &str, regex: Vec<Regex>) -> Self {
        assert!(hand_in.len() == 5);
        let hand = hand_in.chars().sorted().collect::<String>();

        if regex[0].is_match(&hand).unwrap() {
            HandType::FiveOfAKind
        } else if regex[1].is_match(&hand).unwrap() {
            HandType::FourOfAKind
        } else if regex[2].is_match(&hand).unwrap() || regex[3].is_match(&hand).unwrap() {
            HandType::FullHouse
        } else if regex[4].is_match(&hand).unwrap() {
            HandType::ThreeOfAKind
        } else if regex[5].is_match(&hand).unwrap() {
            HandType::TwoPair
        } else if regex[6].is_match(&hand).unwrap() {
            HandType::OnePair
        } else {
            HandType::HighCard
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
enum Card {
    Joker,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Ten,
    Jack,
    Queen,
    King,
    Ace,
}

impl From<u8> for Card {
    fn from(n: u8) -> Self {
        match n {
            b'A' => Card::Ace,
            b'K' => Card::King,
            b'Q' => Card::Queen,
            b'J' => Card::Jack,
            b'T' => Card::Ten,
            b'9' => Card::Nine,
            b'8' => Card::Eight,
            b'7' => Card::Seven,
            b'6' => Card::Six,
            b'5' => Card::Five,
            b'4' => Card::Four,
            b'3' => Card::Three,
            b'2' => Card::Two,
            c @ _ => panic!("Invalid u8 given, cannot create a Card from {}", c),
        }
    }
}

#[derive(Debug, Eq)]
struct Hand {
    cards: [Card; 5],
    bid: i64,
    hand_type: HandType,
}

impl Ord for Hand {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        if self.hand_type == other.hand_type {
            self.cards.cmp(&other.cards)
        } else {
            self.hand_type.cmp(&other.hand_type)
        }
    }
}

impl PartialOrd for Hand {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl PartialEq for Hand {
    fn eq(&self, other: &Self) -> bool {
        self.hand_type == other.hand_type && self.cards == other.cards
    }
}

impl From<&str> for Hand {
    fn from(line: &str) -> Self {
        Hand::new(line, compile_hand_regex())
    }
}

impl Hand {
    fn new(line: &str, regex: Vec<Regex>) -> Self {
        let mut splits = line.split_whitespace();
        let cards_str = splits.next().unwrap();
        let cards_slice = cards_str.as_bytes();

        let mut cards: [Card; 5] = [Card::Two; 5];
        cards[0] = Card::from(*cards_slice.get(0).unwrap());
        cards[1] = Card::from(*cards_slice.get(1).unwrap());
        cards[2] = Card::from(*cards_slice.get(2).unwrap());
        cards[3] = Card::from(*cards_slice.get(3).unwrap());
        cards[4] = Card::from(*cards_slice.get(4).unwrap());

        Hand {
            cards,
            bid: splits.next().unwrap().parse::<i64>().unwrap(),
            hand_type: HandType::new(cards_str, regex),
        }
    }

    fn assign_p2_hand_type(self: &mut Self) {
        for card in &mut self.cards {
            if *card == Card::Jack {
                *card = Card::Joker;
            }
            // TODO: Do some magic here to re-score the hands. I really don't know how to begin...
        }
    }
}

#[derive(Debug)]
pub struct Day07 {
    hands: Vec<Hand>,
}

impl From<String> for Day07 {
    fn from(input: String) -> Self {
        let regex = compile_hand_regex();
        Day07 {
            hands: input.lines().map(|l| Hand::new(l, regex.clone())).collect(),
        }
    }
}

impl Day07 {
    fn solve_p1(&mut self) -> i64 {
        self.hands.sort();
        std::iter::zip(self.hands.iter(), 1..)
            .map(|(h, i)| i * h.bid)
            .sum()
    }

    fn solve_p2(&mut self) -> i64 {
        for hand in &mut self.hands {
            hand.assign_p2_hand_type();
        }
        self.solve_p1()
    }
}

impl puzzle::Solve for Day07 {
    fn solve(&mut self) -> Result<puzzle::Solution, Box<dyn std::error::Error>> {
        Ok(puzzle::Solution::Integer(self.solve_p1(), self.solve_p2()))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::puzzle::Solve;

    #[test]
    fn create_card_from_char() {
        assert_eq!(Card::from(b'A'), Card::Ace);
        assert_eq!(Card::from(b'K'), Card::King);
        assert_eq!(Card::from(b'Q'), Card::Queen);
        assert_eq!(Card::from(b'J'), Card::Jack);
        assert_eq!(Card::from(b'T'), Card::Ten);
        assert_eq!(Card::from(b'9'), Card::Nine);
        assert_eq!(Card::from(b'8'), Card::Eight);
        assert_eq!(Card::from(b'7'), Card::Seven);
        assert_eq!(Card::from(b'6'), Card::Six);
        assert_eq!(Card::from(b'5'), Card::Five);
        assert_eq!(Card::from(b'4'), Card::Four);
        assert_eq!(Card::from(b'3'), Card::Three);
        assert_eq!(Card::from(b'2'), Card::Two);
    }

    #[test]
    #[should_panic]
    fn create_card_from_invalid_char() {
        _ = Card::from(b'x');
    }

    #[test]
    fn create_hand_type_from_cards() {
        assert_eq!(HandType::from("AAAAA"), HandType::FiveOfAKind);
        assert_eq!(HandType::from("AA8AA"), HandType::FourOfAKind);
        assert_eq!(HandType::from("23332"), HandType::FullHouse);
        assert_eq!(HandType::from("TTT98"), HandType::ThreeOfAKind);
        assert_eq!(HandType::from("23432"), HandType::TwoPair);
        assert_eq!(HandType::from("A23A4"), HandType::OnePair);
        assert_eq!(HandType::from("23456"), HandType::HighCard);
    }

    #[test]
    fn comapre_hands() {
        assert_eq!(
            Hand::from("QQQJA 483").cmp(&Hand::from("KK677 28")),
            std::cmp::Ordering::Greater
        );
        assert_eq!(
            Hand::from("QQQJA 483").cmp(&Hand::from("QQQJA 28")),
            std::cmp::Ordering::Equal
        );
        assert_eq!(
            Hand::from("KK677 483").cmp(&Hand::from("KTJJT 28")),
            std::cmp::Ordering::Greater
        );
        assert_eq!(
            Hand::from("32T3K 765").cmp(&Hand::from("T55J5 684")),
            std::cmp::Ordering::Less
        );
        assert_eq!(
            Hand::from("T55J5 684").cmp(&Hand::from("QQQJA 483")),
            std::cmp::Ordering::Less
        );
    }

    #[test]
    fn sort_hands() {
        assert_eq!(
            vec![
                Hand::from("32T3K 765"),
                Hand::from("T55J5 684"),
                Hand::from("KK677 28"),
                Hand::from("KTJJT 220"),
                Hand::from("QQQJA 483"),
            ]
            .into_iter()
            .sorted()
            .collect::<Vec<_>>(),
            vec![
                Hand::from("32T3K 765"),
                Hand::from("KTJJT 220"),
                Hand::from("KK677 28"),
                Hand::from("T55J5 684"),
                Hand::from("QQQJA 483"),
            ]
        );
    }

    #[test]
    fn file_01() {
        let mut solver: Day07 = std::fs::read_to_string("07/01").unwrap().into();
        assert_eq!(
            solver.solve().unwrap(),
            crate::Solution::Integer(6440, 5905)
        );
    }

    #[test]
    fn file_input() {
        let mut solver: Day07 = std::fs::read_to_string("07/input").unwrap().into();
        assert_eq!(
            solver.solve().unwrap(),
            crate::Solution::Integer(248559379, 0)
        );
    }
}
