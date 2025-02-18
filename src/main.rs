use std::io;
use std::io::Write;

mod lexer;
mod parser;

fn main() {
    // loop {
        // print!("> ");
        // let mut input: String = String::new();
        // let _ = io::stdout().flush();
        
        // io::stdin().read_line(&mut input).expect("failed to read line");
        // input = input.replace("\n", ""); //TODO: eventually support multi-line commands, should just be able to adapt the current flow by iterating through the commands?

        let input = "ls -la".to_string();
    
        let mut tokenizer: lexer::Tokenizer = lexer::Tokenizer::new(input);
        let tokens: Vec<lexer::Token> = tokenizer.tokenize();

        let mut parser: parser::Parser = parser::Parser::new(tokens);
        let command = parser.parse();
        println!("{:?}", command);

        // if tokens.len() == 0 {
        //     continue;
        // }
    
        // println!("{:?}", tokens);
    // }
}