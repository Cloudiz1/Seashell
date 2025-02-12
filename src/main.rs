use std::io;
use std::io::Write;

mod lexer;

fn main() {
    // print!("> ");
    // let mut input: String = String::new();
    // io::stdout().flush();
    
    // io::stdin().read_line(&mut input).expect("failed to read line");
    // input = input.replace("\n", "");

    let mut tokenizer = lexer::Tokenizer::new("ls -la".to_string());
    let tokens = tokenizer.tokenize();
    println!("{:?}", tokens);
    // tokenizer.debug();
}