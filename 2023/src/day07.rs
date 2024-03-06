use crate::puzzle;

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
enum HandType {
    FiveOfAKind,
    FourOfAKind,
    FullHouse,
    ThreeOfAKind,
    TwoPair,
    OnePair,
    HighCard,
}

impl From<&[Card; 5]> for HandType {
    fn from(hand: &[Card; 5]) -> Self {
        HandType::FullHouse
    }
}

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
enum Card {
    Ace,
    King,
    Queen,
    Jack,
    Ten,
    Nine,
    Eight,
    Seven,
    Six,
    Five,
    Four,
    Three,
    Two,
}

impl From<&u8> for Card {
    fn from(n: &u8) -> Self {
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
            _ => panic!("Invalid u8 given, cannot create a Card"),
        }
    }
}

#[derive(Debug)]
struct Hand {
    cards: [Card; 5],
    bid: u32,
    hand_type: HandType,
}

impl From<&str> for Hand {
    fn from(line: &str) -> Self {
        let cards_slice = line.split_whitespace().next().unwrap().as_bytes();
        let mut cards: [Card; 5] = [Card::Two; 5];
        cards[0] = Card::from(cards_slice.get(0).unwrap());
        cards[1] = Card::from(cards_slice.get(1).unwrap());
        cards[2] = Card::from(cards_slice.get(2).unwrap());
        cards[3] = Card::from(cards_slice.get(3).unwrap());
        cards[4] = Card::from(cards_slice.get(4).unwrap());
        cards.sort();
        Hand {
            cards,
            bid: line
                .split_whitespace()
                .skip(1)
                .next()
                .unwrap()
                .parse::<u32>()
                .unwrap(),
            hand_type: HandType::from(&cards),
        }
    }
}

#[derive(Debug)]
pub struct Day07 {
    hands: Vec<Hand>,
}

impl From<String> for Day07 {
    fn from(input: String) -> Self {
        Day07 {
            hands: input.lines().map(Hand::from).collect(),
        }
    }
}

impl puzzle::Solve for Day07 {
    fn solve(&mut self) -> Result<puzzle::Solution, Box<dyn std::error::Error>> {
        println!("{:#?}", self);
        Ok(puzzle::Solution::Integer(0, 0))
    }
}
