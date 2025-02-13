use crate::lexer;

//TODO: pipes :3
// expand this to work with pipes later
// I think the idea is that pipes will generate two commands, where one will just feed into the other. 
struct Command {
    command: String,
    args: Vec<String>
}

struct Parser {
    input: Vec<lexer::Token>,
    index: usize,
    curr: char 
}

impl Parser {
    pub fn new(input: Vec<lexer::Token>) -> Parser {
        return Parser {
            input: input,
            index: 0,
            curr: 
        }
    }
}

/*
loop through Vec<Tokens>
if no value, replace with string value (EG: SingleHypen -> -)
whitespace not in a string should be a different element in args[]

*/