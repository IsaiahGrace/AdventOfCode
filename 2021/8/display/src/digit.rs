use std::collections::HashSet;

/* These are the Segment semantics
 aaaa
b    c
b    c
 dddd
e    f
e    f
 gggg

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
pub struct Digit {
    segments: HashSet<Segment>,
}

impl Digit {
    pub fn new(digit: i8) -> Digit {
        let mut segments: HashSet<Segment> = HashSet::new();
        match digit {
            0 => {
                segments.insert(Segment::A);
                segments.insert(Segment::B);
                segments.insert(Segment::C);
                segments.insert(Segment::E);
                segments.insert(Segment::F);
                segments.insert(Segment::G);
            }
            1 => {
                segments.insert(Segment::C);
                segments.insert(Segment::F);
            }
            2 => {
                segments.insert(Segment::A);
                segments.insert(Segment::C);
                segments.insert(Segment::D);
                segments.insert(Segment::E);
                segments.insert(Segment::G);
            }
            3 => {
                segments.insert(Segment::A);
                segments.insert(Segment::C);
                segments.insert(Segment::D);
                segments.insert(Segment::F);
                segments.insert(Segment::G);
            }
            4 => {
                segments.insert(Segment::B);
                segments.insert(Segment::C);
                segments.insert(Segment::D);
                segments.insert(Segment::F);
            }
            5 => {
                segments.insert(Segment::A);
                segments.insert(Segment::B);
                segments.insert(Segment::D);
                segments.insert(Segment::F);
                segments.insert(Segment::G);
            }
            6 => {
                segments.insert(Segment::A);
                segments.insert(Segment::B);
                segments.insert(Segment::D);
                segments.insert(Segment::F);
                segments.insert(Segment::E);
                segments.insert(Segment::G);
            }
            7 => {
                segments.insert(Segment::A);
                segments.insert(Segment::C);
                segments.insert(Segment::F);
            }
            8 => {
                segments.insert(Segment::A);
                segments.insert(Segment::B);
                segments.insert(Segment::C);
                segments.insert(Segment::D);
                segments.insert(Segment::E);
                segments.insert(Segment::F);
                segments.insert(Segment::G);
            }
            9 => {
                segments.insert(Segment::A);
                segments.insert(Segment::B);
                segments.insert(Segment::C);
                segments.insert(Segment::D);
                segments.insert(Segment::F);
                segments.insert(Segment::G);
            }
            _ => {}
        }
        Digit {
            segments: segments,
        }
    }

    pub fn print_lines(&self) -> [String; 7] {
        let mut lines: [String; 7] = Default::default();

        if self.segments.contains(&Segment::A) {
            lines[0].push_str(" ████ ");
        } else {
            lines[0].push_str("      ");
        }

        for i in 1..3 {
            if self.segments.contains(&Segment::B) {
                lines[i].push_str("█");
            } else {
                lines[i].push_str(" ");
            }
            lines[i].push_str("    ");
            if self.segments.contains(&Segment::C) {
                lines[i].push_str("█");
            } else {
                lines[i].push_str(" ");
            }
        }

        if self.segments.contains(&Segment::D) {
            lines[3].push_str(" ████ ");
        } else {
            lines[3].push_str("      ");
        }

        for i in 4..6 {
            if self.segments.contains(&Segment::E) {
                lines[i].push_str("█");
            } else {
                lines[i].push_str(" ");
            }
            lines[i].push_str("    ");
            if self.segments.contains(&Segment::F) {
                lines[i].push_str("█");
            } else {
                lines[i].push_str(" ");
            }
        }

        if self.segments.contains(&Segment::G) {
            lines[6].push_str(" ████ ");
        } else {
            lines[6].push_str("      ");
        }
        lines
    }
}
