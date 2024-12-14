use std::env;
use std::fs::File;
use std::io::prelude::*;
use std::path::Path;
use std::vec::Vec;

fn parse_input() -> Vec<char> {
    let args: Vec<String> = env::args().collect();
    let path = Path::new(&args[1]);
    let display = path.display();

    let mut file = match File::open(&path) {
        Err(why) => panic!("couldn't open {}: {}", display, why),
        Ok(file) => file,
    };

    let mut s = String::new();
    match file.read_to_string(&mut s) {
        Err(why) => panic!("couldn't read {}: {}", display, why),
        Ok(_) => (),
    }

    s.chars().collect()
}

fn is_valid_num(x: char) -> bool {
    const NUMS: &str = "1234567890";
    NUMS.contains(x)
}

fn find_str(txt: &str, i: &mut usize, pattern: &str) -> bool {
    let pat_chars: Vec<char> = pattern.chars().collect();
    let mut idx = *i;
    for &c in pat_chars.iter() {
        if idx >= txt.len() || txt.chars().nth(idx).unwrap() != c {
            return false;
        }
        idx += 1;
    }
    *i = idx;
    true
}

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

fn find_do_dont(txt: &str, i: &mut usize) -> Option<bool> {
    if find_str(txt, i, "do()") {
        Some(true)
    } else if find_str(txt, i, "don't()") {
        Some(false)
    } else {
        None
    }
}

fn main() {
    let txt = parse_input();
    let txt_str: String = txt.iter().collect();

    let mut sum = 0;
    let mut i = 0;
    let prefix: Vec<char> = "mul(".chars().collect();

    // is_enable should persist across iterations
    let mut is_enable = true;

    while i < txt.len() {
        // Always check if there's a dont
        match find_do_dont(&txt_str, &mut i) {
            Some(toggle) => { 
                println!("Changing enable status: {} -> {}", is_enable, toggle);
                is_enable = toggle;},
            // Noop, because we only care if we're !is_enabled which is handled in the while loop
            None => (),
        }
        // As long as were disabled, look for a do or we just run out of chars
        while !is_enable {
            match find_do_dont(&txt_str, &mut i) {
                Some(toggle) => { 
                    println!("Changing enable status: {}", is_enable);
                    is_enable = toggle;},
                None => break,
            }
        }
        if !is_enable {
            i += 1;
            continue;
        }

        // Now look for "mul("
        let mut is_good = true;
        for &c in prefix.iter() {
            if i >= txt.len() || txt[i] != c {
                if c == prefix[0] {
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

        // Now look for the first number
        let number1 = match find_num(&txt_str, &mut i) {
            Some(num) => num,
            None => continue,
        };

        // Comma
        if i >= txt.len() || txt[i] != ',' {
            continue;
        }
        i += 1;

        // Now look for the second number
        let number2 = match find_num(&txt_str, &mut i) {
            Some(num) => num,
            None => continue,
        };

        // Final paren
        if i >= txt.len() || txt[i] != ')' {
            continue;
        }
        i += 1;

        println!("valid: {}", &txt_str[start_idx..i]);
        sum += number1 * number2;
    }

    println!("sum: {}", sum);
}
