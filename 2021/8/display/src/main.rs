use std::collections::HashSet;
use std::fmt;


/* These are the Segment semantics
 aaaa
b    c
b    c
 dddd
e    f
e    f
 gggg
*/
#[derive(Debug, PartialEq, Eq, Hash)]
enum Segment {
    A,
    B,
    C,
    D,
    E,
    F,
    G
}

#[derive(Debug)]
struct Digit {
    segments: HashSet<Segment>,
}

#[derive(Debug)]
struct Display {
    digits: Vec<Digit>,
}

/*
  0:      1:      2:      3:      4:
 ████            ████    ████
█    █       █       █       █  █    █
█    █       █       █       █  █    █
                 ████    ████    ████
█    █       █  █            █       █
█    █       █  █            █       █
 ████            ████    ████

  5:      6:      7:      8:      9:
 ████    ████    ████    ████    ████
█       █            █  █    █  █    █
█       █            █  █    █  █    █
 ████    ████            ████    ████
     █  █    █       █  █    █       █
     █  █    █       █  █    █       █
 ████    ████            ████    ████

*/
impl fmt::Display for Digit {
    // This trait requires `fmt` with this exact signature.
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        if self.segments.contains(&Segment::A) {
            writeln!(f, " ████ ").unwrap();
        } else {
            writeln!(f, "      ").unwrap();
        }
        for _ in 0..2 {
            if self.segments.contains(&Segment::B) {
                write!(f, "█").unwrap();
            } else {
                write!(f, " ").unwrap();
            }
            write!(f, "    ").unwrap();
            if self.segments.contains(&Segment::C) {
                write!(f, "█").unwrap();
            } else {
                write!(f, " ").unwrap();
            }
            write!(f, "\n").unwrap();
        }
        if self.segments.contains(&Segment::D) {
            writeln!(f, " ████ ").unwrap();
        } else {
            writeln!(f, "      ").unwrap();
        }
        for _ in 0..2 {
            if self.segments.contains(&Segment::E) {
                write!(f, "█").unwrap();
            } else {
                write!(f, " ").unwrap();
            }
            write!(f, "    ").unwrap();
            if self.segments.contains(&Segment::F) {
                write!(f, "█").unwrap();
            } else {
                write!(f, " ").unwrap();
            }
            write!(f, "\n").unwrap();
        }
        if self.segments.contains(&Segment::G) {
            write!(f, " ████ ")
        } else {
            write!(f, "      ")
        }
    }
}

fn main() {
    let mut eight: Digit = Digit{
        segments: HashSet::new()
    };
    eight.segments.insert(Segment::A);
    eight.segments.insert(Segment::B);
    eight.segments.insert(Segment::C);
    eight.segments.insert(Segment::D);
    eight.segments.insert(Segment::E);
    eight.segments.insert(Segment::F);
    eight.segments.insert(Segment::G);
    println!("{}", eight);
}
