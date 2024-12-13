use std::env;
use std::fs::File;
use std::io::prelude::*;
use std::path::Path;
use std::vec::Vec;

fn parse_input() -> Vec<char> {
    let args: Vec<String> = env::args().collect();

    // Create a path to the desired file
    let path = Path::new(&args[1]);
    let display = path.display();

    // Open the path in read-only mode, returns `io::Result<File>`
    let mut file = match File::open(&path) {
        Err(why) => panic!("couldn't open {}: {}", display, why),
        Ok(file) => file,
    };

    // Read the file contents into a string, returns `io::Result<usize>`
    let mut s = String::new();
    match file.read_to_string(&mut s) {
        Err(why) => panic!("couldn't read {}: {}", display, why),
        Ok(_) => (),
    }

    return s.chars().collect();
}

fn is_valid_num(x: char) -> bool {
    const NUMS: &str = "1234567890";

    return NUMS.contains(x);
}

// mul(111,222)

fn find_num(txt: &str, i: &mut usize) -> Option<i32> {
    let mut num: String = String::new();
    while *i < txt.len() && is_valid_num(txt.chars().nth(*i).unwrap()) {
        num.push(txt.chars().nth(*i).unwrap());
        *i += 1;
    }
    if num.is_empty() {
        return None;
    }
    num.parse::<i32>().ok()
}

fn main() {
    let txt = parse_input();

    // Try to build an expression by moving index forward
    let mut sum = 0;
    let mut i = 0;
    let prefix: Vec<char> = "mul(".chars().collect();

    while i < txt.len() {
        // Find the prefix match
        let mut is_good = true;
        for x in prefix.iter() {
            if i >= txt.len() || txt[i] != *x {
                // Prevent infinite looping if the first character of the prefix doesn't match
                if *x == prefix[0] {
                    i += 1;
                }
                is_good = false;
                break;
            }
            i += 1;
        }
        if !is_good {
            continue;
        }

        let start_idx = i - prefix.len();

        // Now look for number 1
        let number1 = match find_num(&txt.iter().collect::<String>(), &mut i) {
            Some(num) => num,
            None => continue,
        };

        // Comma
        if i >= txt.len() || txt[i] != ',' {
            continue;
        }
        i += 1;

        // Now look second number 2
        let number2 = match find_num(&txt.iter().collect::<String>(), &mut i) {
            Some(num) => num,
            None => continue,
        };

        // Final parens
        if i >= txt.len() || txt[i] != ')' {
            continue;
        }
        i += 1;

        println!("valid: {}", txt.iter().collect::<String>()[start_idx..i].to_string());

        // Finally we made it! If we made it here, then number1 and number2 are defined at the rest of the string matches the pattern.
        sum += number1 * number2;
    }

    println!("sum: {}", sum);
}
