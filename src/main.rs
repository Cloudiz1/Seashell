use std::io;
use std::io::Write;

fn main() {
    loop {
        print!("> ");
        io::stdout().flush().unwrap();

        let mut input = String::new();
        io::stdin().read_line(&mut input).expect("Not a valid string");

        let cmd: Vec<_> = input.split(" ").collect();
        println!("{:?}", cmd);
    }
}