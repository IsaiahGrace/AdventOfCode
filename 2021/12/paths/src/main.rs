use std::collections::HashMap;
use std::collections::HashSet;
use std::env;
use std::fs::File;
use std::io::{prelude::*, BufReader};
use std::path::Path;

#[derive(Debug, PartialEq, Eq)]
enum CaveSize {
    Big,
    Small,
}

#[derive(Debug)]
struct CaveInfo {
    size: CaveSize,
    neighbors: HashSet<String>,
}

fn read_input_file(file: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(file).expect("No file found");
    let buf = BufReader::new(file);
    buf.lines().map(|l| l.unwrap()).collect()
}

fn construct_graph(input: Vec<String>) -> HashMap<String, CaveInfo> {
    let mut graph: HashMap<String, CaveInfo> = HashMap::new();
    for line in input {
        let mut caves = line.splitn(2,"-");
        let source = caves.next().unwrap();
        let dest = caves.next().unwrap();

        let source_size;
        if source.chars().next().unwrap().is_uppercase() {
            source_size = CaveSize::Big;
        } else {
            source_size = CaveSize::Small;
        }

        let dest_size;
        if dest.chars().next().unwrap().is_uppercase() {
            dest_size = CaveSize::Big;
        } else {
            dest_size = CaveSize::Small;
        }

        if graph.contains_key(source) {
            graph.get_mut(source).unwrap().neighbors.insert(dest.to_string());
        } else {
            let mut source_neighbors = HashSet::new();
            source_neighbors.insert(dest.to_string());
            graph.insert(source.to_string(), CaveInfo {size: source_size, neighbors: source_neighbors});
        }

        if graph.contains_key(dest) {
            graph.get_mut(dest).unwrap().neighbors.insert(source.to_string());
        } else {
            let mut dest_neighbors = HashSet::new();
            dest_neighbors.insert(source.to_string());
            graph.insert(dest.to_string(), CaveInfo {size: dest_size, neighbors: dest_neighbors});
        }
    }
    graph
}

fn explore(visited_caves: Vec<String>, graph: &HashMap<String, CaveInfo>) -> Vec<Vec<String>> {
    //println!("{:?} | explore", visited_caves);
    let current_cave: &String = visited_caves.last().expect("visited_caves is empty!");

    if current_cave == "end" {
        //println!("Found the end!");
        return vec![visited_caves];
    }

    let current_cave_info: &CaveInfo = graph.get(current_cave).expect("current_cave not in graph!");

    let mut new_paths: Vec<Vec<String>> = vec![vec![]];

    for neighbor in &current_cave_info.neighbors {
        //println!("{:?} | neighbor {}", visited_caves, neighbor);
        if graph.get(neighbor).unwrap().size == CaveSize::Small && visited_caves.contains(neighbor) {
            //println!("{:?} | skipping {} because it's small and already visited.", visited_caves, neighbor);
            continue;
        }
        let mut new_visited_caves = visited_caves.clone();
        new_visited_caves.push(neighbor.to_string());
        new_paths.extend(explore(new_visited_caves, graph))
    }

    new_paths
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("Please specify an input file")
    }

    let input = read_input_file(&args[1]);

    let graph = construct_graph(input);

    println!("{:#?}", graph);

    let paths: Vec<Vec<String>> = explore(vec!["start".to_string()], &graph).into_iter().filter(|e| !e.is_empty()).collect();

    println!("Found {:?} paths to the end.", paths.len());

    //for path in paths {
    //    println!("{:?}", path);
    //}
}
