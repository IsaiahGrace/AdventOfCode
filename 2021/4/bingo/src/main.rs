use std::{
    env,
    io::{prelude::*, BufReader},
    path::Path,
    fs::File,
    convert::TryInto
};
use colored::*;

type BingoBoard = [[BingoCell; 5]; 5];

#[derive(Copy, Clone, Debug, Default)]
struct BingoCell {
    n: u8,
    called: bool
}

#[derive(Debug)]
struct BingoGameBoard {
    board: BingoBoard,
    won: bool,
    turns_to_win: usize,
    score: u32,
}

fn construct_board(lines: &[String; 5]) -> BingoBoard {
    let mut bingo_board: BingoBoard = [[BingoCell {n: 0, called: false}; 5]; 5];
    for row in 0..5 {
        let mut nums = lines[row].split_whitespace();
        for col in 0..5 {
            bingo_board[row][col] = BingoCell {
                n: nums.next().unwrap().parse::<u8>().expect("Failed to parse bingo number"),
                called: false
            }
        }
    }
    bingo_board
}

fn generate_sequence(line: &String) -> Vec<u8> {
    line
    .split(',')
    .map(|s| s.parse::<u8>()
        .expect("Failed to parse bingo number sequence"))
    .collect()
}

fn read_input_file(file: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(file).expect("No file found");
    let buf = BufReader::new(file);
    buf.lines()
        .map(|l| l.unwrap())
        .collect()
}

fn mark_board(mut board: BingoBoard, n: u8) -> BingoBoard {
    for i in 0..5 {
        for j in 0..5 {
            if board[i][j].n == n {
                board[i][j].called = true;
            }
        }
    }
    board
}

fn check_win(board: &BingoBoard) -> bool {
    for row in 0..5 {
        if board[row].iter().map(|cell| cell.called).reduce(|a,b| a && b).unwrap() {
            return true
        }
    }
    for col in 0..5 {
        if board.iter().map(|row| row[col]).map(|cell| cell.called).reduce(|a,b| a && b).unwrap() {
            return true
        }
    }
    false
}

fn score_board(board: &BingoBoard, n: u8) -> u32 {
    u32::from(n) * board.iter()
                        .map(|row| row.iter()
                                      .filter(|cell| ! cell.called)
                                      .map(|cell| u32::from(cell.n))
                                      .sum::<u32>())
                        .sum::<u32>()
}

fn print_board(board: &BingoBoard) {
    for line in board {
        for cell in line {
            if cell.called {
                print!("{} ", format!("{:02}", cell.n).bold().green());
            } else {
                print!("{} ", format!("{:02}", cell.n).red());
            }
        }
        println!();
    }
}

fn play_bingo(mut board: BingoBoard, seq: &Vec<u8>) -> BingoGameBoard {
    for (i,n) in seq.iter().enumerate() {
        board = mark_board(board, *n);
        if check_win(&board) {
            println!("Bingo! i: {} n: {}", i, n);
            print_board(&board);
            return BingoGameBoard {
                board: board,
                won: true,
                turns_to_win: i,
                score: score_board(&board, *n)
            }
        }
    }
    BingoGameBoard {
        board: board,
        won: false,
        turns_to_win: 0,
        score: 0
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("Please specify an input file")
    }
    let lines = read_input_file(&args[1]);
    let num_sequence = generate_sequence(&lines[0]);
    let mut boards: Vec<BingoGameBoard> = Vec::new();
    for i in (1..lines.len()).step_by(6) {
        let board: BingoBoard = construct_board((&lines[i+1..i+6]).try_into().unwrap());
        boards.push(play_bingo(board, &num_sequence));
    }

    let mut best: usize = 0;
    for i in 0..boards.len() {
        if boards[i].turns_to_win < boards[best].turns_to_win {
            best = i;
        }
    }
    println!("Best board:");
    println!("Turns to win: {}", boards[best].turns_to_win);
    println!("Score: {}", boards[best].score);
    print_board(&boards[best].board);

    let mut worst: usize = 0;
    for i in 0..boards.len() {
        if boards[i].turns_to_win > boards[worst].turns_to_win {
            worst = i;
        }
    }
    println!("Worst board:");
    println!("Turns to win: {}", boards[worst].turns_to_win);
    println!("Score: {}", boards[worst].score);
    print_board(&boards[worst].board);
}
