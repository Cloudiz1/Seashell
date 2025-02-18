use crate::lexer;
use crate::lexer::{Token, TokenType};

// expand this to work with pipes later
// I think the idea is that pipes will generate two commands, where one will just feed into the other. 
#[derive(Debug)]
pub struct Command {
    command: String,
    args: Vec<String>
}

pub struct Parser {
    input: Vec<Token>,
    index: usize,
    curr: Token 
}

impl Parser {
    pub fn new(input: Vec<Token>) -> Parser {
        return Parser {
            curr: input[0].clone(),
            input: input,
            index: 0
        }
    }

    pub fn parse(&mut self) -> Command {
        let command_name = self.curr.clone().value.unwrap();
        let mut args: Vec<String> = Vec::new();
        
        let mut out = Command {
            command: command_name,
            args: args
        };

        self.get_next();

        loop {
            match self.curr.token_type {
                TokenType::Space => {},
                TokenType::StringLiteral => {
                    out.args.push(self.curr.clone().value.unwrap());
                },
                TokenType::SingleQuote => {
                    let quote = self.get_quote(TokenType::SingleQuote, self.index);
                    out.args.push(quote);
                },
                TokenType::DoubleQuote => {
                    let quote = self.get_quote(TokenType::DoubleQuote, self.index);
                    out.args.push(quote);
                },
                _ => {
                    println!("{:?}", self.curr.clone().token_type);
                }
            }

            if self.at_eol() {
                return out;
            }

            self.get_next();
        }
    }

    fn at_eol(&mut self) -> bool {
        if self.index + 1 == self.input.len() {
            return true;
        }

        false
    }

    fn get_next(&mut self) -> Token {
        self.index += 1;
        self.curr = self.input[self.index].clone();
        return self.curr.clone();
    }

    fn create_command(&mut self, command: String, args: Vec<String>) -> Command {
        return Command {
            command: command,
            args: args
        }
    }

    fn get_value(&mut self, input: Token, index: usize) -> String {
        input.clone().value.unwrap()
    }

    fn get_quote(&mut self, stop: TokenType, curr_index: usize) -> String { // curr index is used to not return nothing when first TokenType and stop TokenType are identical
        let mut out: String = String::new();

        loop {            
            match self.curr.token_type {
                TokenType::SingleQuote => out.push('\''),
                TokenType::DoubleQuote => out.push('\"'),
                TokenType::Space => out.push(' '),
                TokenType::StringLiteral => out.push_str(&self.curr.clone().value.unwrap()),
                _ => println!("{:?}", self.curr)
            }
            
            if self.at_eol() || (self.curr.token_type == stop && self.index != curr_index) {
                // println!("out_string: {}", out);
                return out;
            }

            self.get_next();
        }
    }
}

/*
loop through Vec<Tokens>
if no value, replace with string value (EG: SingleHypen -> -)
whitespace not in a string should be a different element in args[]

*/