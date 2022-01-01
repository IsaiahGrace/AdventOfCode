use std::{
    env,
    io::{prelude::*, BufReader},
    path::Path,
    fs::File,
    convert::TryFrom
};

#[derive(Clone, Debug)]
struct BitCount {
    zeros: u32,
    ones: u32
}

fn get_bit_freq(readings: &Vec<u32>) -> Vec<BitCount> {
    let mut bit_freq: Vec<BitCount> = vec![BitCount {zeros: 0, ones: 0}; 32];
    for reading in readings {
        for i in 0..32 {
            if reading & (1 << i) > 0 {
                bit_freq[i].ones += 1;
            } else {
                bit_freq[i].zeros += 1;
            }
        }
    }
    let length: u32 = u32::try_from(readings.len()).unwrap();
    for i in 0..32 {
        if bit_freq[i].ones == length {
            bit_freq[i].ones = 0;
        }
        if bit_freq[i].zeros == length {
            bit_freq[i].zeros = 0;
        }
    }
    bit_freq
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("Please specify an input file")
    }

    let lines: Vec<u32> = read_input_file(&args[1]);
    let bits: Vec<BitCount> = get_bit_freq(&lines);

    let mut gamma: u64 = 0;
    let mut epsilon: u64 = 0;

    let mut oxygen: Vec<u32> = lines.clone();
    let mut co2: Vec<u32> = oxygen.clone();

    for (i, bit) in bits.iter().enumerate() {
        gamma |= (if bit.ones > bit.zeros {1} else {0}) << i;
        epsilon |= (if bit.ones < bit.zeros {1} else {0}) << i;
    }

    for i in (0..32).rev() {
        let bit_count: &BitCount = &get_bit_freq(&oxygen)[i];
        //println!("i: {}", i);
        //println!("bit_count: {:?}", bit_count);
        let mut j = 0;
        while j < oxygen.len() {
            if oxygen.len() == 1 {
                j += 1;
                continue;
            }
            let oxygen_bit = oxygen[j] & (1 << i) != 0;
            if bit_count.ones > bit_count.zeros {
                if ! oxygen_bit {
                    //println!("Removed {:012b}", oxygen[j]);
                    oxygen.remove(j);
                    continue;
                }
            } else if bit_count.ones < bit_count.zeros {
                if oxygen_bit {
                    //println!("Removed {:012b}", oxygen[j]);
                    oxygen.remove(j);
                    continue;
                }
            } else {
                if ! oxygen_bit && bit_count.ones != 0 && bit_count.zeros != 0 {
                    //println!("Removed {:012b}", oxygen[j]);
                    oxygen.remove(j);
                    continue;
                }
            }
            j += 1;
        }
    }

    for i in (0..32).rev() {
        let bit_count: &BitCount = &get_bit_freq(&co2)[i];
        //println!("i: {}", i);
        //println!("bit_count: {:?}", bit_count);
        let mut j = 0;
        while j < co2.len() {
            if co2.len() == 1 {
                j += 1;
                continue;
            }
            let co2_bit = co2[j] & (1 << i) != 0;
            if bit_count.ones > bit_count.zeros {
                if co2_bit {
                    //println!("Removed {:012b}", co2[j]);
                    co2.remove(j);
                    continue;
                }
            } else if bit_count.ones < bit_count.zeros {
                if ! co2_bit {
                    //println!("Removed {:012b}", co2[j]);
                    co2.remove(j);
                    continue;
                }
            } else {
                if co2_bit && bit_count.ones != 0 && bit_count.zeros != 0 {
                    //println!("Removed {:012b}", co2[j]);
                    co2.remove(j);
                    continue;
                }
            }
            j += 1;
        }
    }

    println!("Gamma: {:012b}", gamma);
    println!("Epsilon: {:012b}", epsilon);
    println!("Pt. 1 Answer: {}", gamma * epsilon);
    println!("Oxygen: {:012b}", oxygen[0]);
    println!("CO2: {:012b}", co2[0]);
    println!("Pt. 2 Anser: {}", oxygen[0] * co2[0]);
    assert!(oxygen.len() == 1);
    assert!(co2.len() == 1);
}

fn read_input_file(file: impl AsRef<Path>) -> Vec<u32> {
    let file = File::open(file).expect("No file found");
    let buf = BufReader::new(file);
    buf.lines()
        .map(|l| u32::from_str_radix(&l.unwrap(),2).unwrap())
        .collect()
}
