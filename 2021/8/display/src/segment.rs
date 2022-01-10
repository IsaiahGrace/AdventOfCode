use std::collections::HashSet;
use std::iter::FromIterator;
use strum::IntoEnumIterator;
use strum_macros::EnumIter;

/* These are the Segment semantics
 aaaa
b    c
b    c
 dddd
e    f
e    f
 gggg
*/

#[derive(Copy, Clone, Debug, EnumIter, PartialEq, Eq, Hash)]
pub enum Segment {
    A,
    B,
    C,
    D,
    E,
    F,
    G
}

pub fn segment_set(number: i32) -> HashSet<Segment> {
    match number {
        0 => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::A, Segment::B, Segment::C, Segment::E, Segment::F, Segment::G].contains(s)))
        }
        1 => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::C, Segment::F].contains(s)))
        }
        2 => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::A, Segment::C, Segment::D, Segment::E, Segment::G].contains(s)))
        }
        3 => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::A, Segment::C, Segment::D, Segment::F, Segment::G].contains(s)))
        }
        4 => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::B, Segment::C, Segment::D, Segment::F].contains(s)))
        }
        5 => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::A, Segment::B, Segment::D, Segment::F, Segment::G].contains(s)))
        }
        6 => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::A, Segment::B, Segment::D, Segment::E, Segment::F, Segment::G].contains(s)))
        }
        7 => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::A, Segment::C, Segment::F].contains(s)))
        }
        8 => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::A, Segment::B, Segment::C, Segment::D, Segment::E, Segment::F, Segment::G].contains(s)))
        }
        9 => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::A, Segment::B, Segment::C, Segment::D, Segment::F, Segment::G].contains(s)))
        }
        0xA => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::A, Segment::B, Segment::C, Segment::D, Segment::E, Segment::F].contains(s)))
        }
        0xB => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::B, Segment::D, Segment::E, Segment::F, Segment::G].contains(s)))
        }
        0xC => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::A, Segment::B, Segment::E, Segment::G].contains(s)))
        }
        0xD => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::C, Segment::D, Segment::E, Segment::F, Segment::G].contains(s)))
        }
        0xE => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::A, Segment::B, Segment::D, Segment::E, Segment::G].contains(s)))
        }
        0xF => {
            HashSet::from_iter(Segment::iter().filter(|s| [Segment::A, Segment::B, Segment::D, Segment::E].contains(s)))
        }
        _ => {
            HashSet::from_iter(Segment::iter())
        }
    }
}
