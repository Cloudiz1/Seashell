#[derive(Debug)]
pub enum TokenType {
    StringLiteral,
    EscapedCharacter,
    Arg,
    OptionFlag,
    BooleanFlag,
    Pipe,
    Bang
}

#[derive(Debug)]
pub struct Token {
    pub token_type: TokenType,
    pub value: Option<String>
}

#[derive(Debug)]
pub struct Tokenizer {
    tokens: Vec<Token>,
    buffer: String,
    curr: char,
    index: usize
}

impl Tokenizer {
    pub fn init(input: String) {
        self
    }
}

pub fn tokenizer(input: String) -> Vec<Token> {
    let mut tokens: Vec<Token> = Vec::new();
    let mut buffer: Vec<&str> = Vec::new();
    for c in input.chars().into_iter().peekable() {
        match c {
            '!' => tokens.push(Token{
                token_type: TokenType::Bang,
                value: None
            }),
            '|' => tokens.push(Token{
                token_type: TokenType::Pipe, 
                value: None
            }),
            _ => {
                panic!("unknown character");
            }
        }
    }
    println!("{:?}", tokens);
    
    return tokens;
}