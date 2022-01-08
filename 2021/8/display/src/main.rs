mod display;
use crate::display::Display;

fn main() {
    let mut line1: Display = Display::new();
    line1.push(8);
    line1.push(6);
    line1.push(7);
    line1.push(5);
    line1.push(3);
    line1.push(0);
    line1.push(9);
    println!("{}", line1);
}
