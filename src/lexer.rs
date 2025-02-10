#[derive(Debug)]
pub enum TokenType {
    StringLiteral,
    EscapedCharacter,
    Arg,
    SingleHyphen,
    DoubleHyphen,
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
    input: Vec<char>,
    curr: char,
    index: usize
}

impl Tokenizer {
    pub fn init(input: Vec<char>) -> Tokenizer {
        return let tokenizer = Tokenizer {
            curr: input[0],
            input: input,
            index: 0
        };
    }

    pub fn tokenize(&mut self) -> Vec<Token> {
        let mut tokens: Vec<Token> = Vec::new();
        
    }

    fn get_next_token(&mut self) -> Token {
        if is_alphabetic(self.curr) {
            self.get_word();
        }
        else if is_numberic(self.curr) {
            self.get_number();
        }
        else {
            match self.curr {
                "\"" => self.get_string("\"");
                "\'" => self.get_string("\'");

                "!" => self.create_token(TokenType::Bang, None);
                "-" => {
                    if input[index + 1] == "-" {
                        self.get_flag(TokenType::SingleHyphen);
                    }
                    else
                    {
                        self.get_flag(TokenType::DoubleHypen);
                    }
                }
                "\\" => self.create_token(TokenType::EscapedCharacter, self.input[index + 1]);

            }
        }
    }
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