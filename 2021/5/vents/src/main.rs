use crate::lib::read_input_file;
use std::collections::HashMap;
use std::convert::TryInto;
use std::env;

mod lib;

fn plot_vents(sea_floor: &mut HashMap<(u32, u32), u32>, vent: &String) {
    let mut endpoints: Vec<[u32; 2]> = Vec::new();
    for point in vent.split(" -> ") {
        endpoints.push(
            point
                .split(',')
                .map(|n| n.parse::<u32>().unwrap())
                .collect::<Vec<u32>>()
                .as_slice()
                .try_into()
                .unwrap(),
        )
    }

    let (mut start, stop) = (endpoints[0], endpoints[1]);

    println!("{}", vent);

    if start[0] != stop[0] && start[1] != stop[1] {
        println!("Skipping!");
        return;
    }

    while start[0] != stop[0] {
        *sea_floor.entry((start[0], start[1])).or_insert(0) += 1;
        println!(
            "({},{}) = {}",
            start[0],
            start[1],
            sea_floor[&(start[0],start[1])]
            );
        if start[0] < stop[0] {
            start[0] += 1;
        } else {
            start[0] -= 1;
        }
    }

    while start[1] != stop[1] {
        *sea_floor.entry((start[0], start[1])).or_insert(0) += 1;
        println!(
            "({},{}) = {}",
            start[0],
            start[1],
            sea_floor[&(start[0],start[1])]
            );
        if start[1] < stop[1] {
            start[1] += 1;
        } else {
            start[1] -= 1;
        }
    }
    *sea_floor.entry((stop[0], stop[1])).or_insert(0) += 1;
    println!(
        "({},{}) = {}",
        stop[0],
        stop[1],
        sea_floor[&(stop[0],stop[1])]
        );
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("Please specify an input file")
    }

    let vents: Vec<String> = read_input_file(&args[1]);

    let mut sea_floor: HashMap<(u32, u32), u32> = HashMap::new();

    for vent in vents {
        plot_vents(&mut sea_floor, &vent);
    }

    let num2 = sea_floor.values().filter(|v| **v > 1).count();
    println!("Vents with more than 1 line: {}", num2);
}
