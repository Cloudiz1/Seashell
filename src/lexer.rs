#[derive(Debug)]
pub enum TokenType {
    StringLiteral,
    Number,
    EscapedCharacter,
    Arg,
    SingleHyphen,
    DoubleHyphen,
    Apostrophe,
    QuotationMark,
    Pipe,
    Bang,
    EndOfString
}

#[derive(Debug)]
pub struct Token {
    pub token_type: TokenType,
    pub value: Option<String>
}

#[derive(Debug)]
pub struct Tokenizer {
    input: Vec<char>,
    curr: char,
    index: usize
}

impl Tokenizer {
    pub fn new(input: Vec<char>) -> Tokenizer {
        return tokenizer = Tokenizer {
            curr: input[0],
            input: input,
            index: 0
        };
    }

    pub fn tokenize(&mut self) -> Vec<Token> {
        let mut tokens: Vec<Token> = Vec::new();
        

        tokens
    }

    fn get_next_token(&mut self) -> Token {
        if self.curr.is_alphabetic() {
            self.get_string(TokenType::StringLiteral)
        }
        else if self.curr.is_numeric() {
            self.get_number(TokenType::Number)
        }

        else {
            match self.curr {
                '\"' => self.scan_until(TokenType::QuotationMark),
                '\'' => self.scan_until(TokenType::Apostrophe),

                '!' => self.create_token(TokenType::Bang, None),
                '-' => {
                    if self.input[self.index + 1] == '-' {
                        self.get_string(TokenType::DoubleHyphen)
                    }
                    else
                    {
                        self.get_string(TokenType::SingleHyphen)
                    }
                },
                '\\' => {
                    if self.index + 1 == self.input.length {
                        self.create_token(TokenType::EndOfString, None)
                    }
                    
                    self.create_token(TokenType::EscapedCharacter, Some(self.input[self.index + 1].to_string()))
                }
            }
        }
    }

    fn create_token(&mut self, token_type: TokenType, value: Option<String>) -> Token {
        return Token {
            token_type: token_type,
            value: value
        }
    }

    fn get_string(&mut self)
}

// pub fn tokenizer(input: String) -> Vec<Token> {
//     let mut tokens: Vec<Token> = Vec::new();
//     let mut buffer: Vec<&str> = Vec::new();
//     for c in input.chars().into_iter().peekable() {
//         match c {
//             '!' => tokens.push(Token{
//                 token_type: TokenType::Bang,
//                 value: None
//             }),
//             '|' => tokens.push(Token{
//                 token_type: TokenType::Pipe, 
//                 value: None
//             }),
//             _ => {
//                 panic!("unknown character");
//             }
//         }
//     }
//     println!("{:?}", tokens);
    
//     return tokens;
// }