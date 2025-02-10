use std::io;
use std::io::Write;

mod lexer;

fn main() {
    // lexer::tokenizer("|!!".to_string());
    let input: Vec<char> = "ls -la \"path to directory\"".chars().collect(); 
    lexer::Tokenizer::init(input);

    // let out: Vec<char> = "test".chars().collect();
    // println!("{:?}", out);

    // loop {
    //     print!("> ");
    //     io::stdout().flush().unwrap();

    //     let mut input = String::new();
    //     io::stdin().read_line(&mut input).expect("Not a valid string");
    
    //     // input = input.replace("\r", "").replace("\n", "");
    //     // let cmd: Vec<_> = input.split(" ").collect();
    //     // println!("{:?}", cmd);
    // }
}