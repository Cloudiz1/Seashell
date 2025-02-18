#[derive(Debug, Clone, PartialEq)]
pub enum TokenType {
    DoubleQuote,
    SingleQuote,
    Bang, 
    Pipe,
    // SingleHyphen,
    // DoubleHyphen,
    Space,
    EscapedCharacter,
    StringLiteral
}

#[derive(Debug, Clone)]
pub struct Token {
    pub token_type: TokenType,
    pub value: Option<String>
}

#[derive(Debug)]
pub struct Tokenizer {
    input: Vec<char>,
    index: usize,
    curr: char,
    input_len: usize
}

impl Tokenizer {
    pub fn new(input: String) -> Tokenizer {
        let chars: Vec<char> = input.chars().collect();

        let mut tokenizer =  Tokenizer {
            input_len: chars.len(),
            input: chars,
            index: 0,
            curr: '\0'
        };

        if tokenizer.input_len != 0 {
            tokenizer.curr = tokenizer.input[0];
        }

        tokenizer
    }

    pub fn tokenize(&mut self) -> Vec<Token> {
        let mut tokens: Vec<Token> = Vec::new();
        
        if self.curr == '\0' {
            return tokens
        }

        loop {
            match self.curr {
                //* I don't think I need to parse flags into tokens? I could be wrong so I'm going to keep this here just in case
                // '-' => {
                //     if self.at_eol() {
                //         tokens.push(self.create_token(TokenType::SingleHyphen, None));
                //     }
                //     else if self.peek(1).unwrap() == '-' {
                //         tokens.push(self.create_token(TokenType::DoubleHyphen, None));
                //         self.skip(1);
                //     }
                //     else {
                //         tokens.push(self.create_token(TokenType::SingleHyphen, None));
                //     }
                // },
                '\\' => {
                    if self.at_eol() {
                        tokens.push(self.create_token(TokenType::EscapedCharacter, None)); //* Maybe just make this a backslash token?
                    } 
                    else {
                        let val = self.get_next();
                        tokens.push(self.create_token(TokenType::EscapedCharacter, Some(val.to_string())));
                    }
                }
                '!' => tokens.push(self.create_token(TokenType::Bang, None)),
                '|' => tokens.push(self.create_token(TokenType::Pipe, None)),
                '\''=> tokens.push(self.create_token(TokenType::SingleQuote, None)),
                '\"'=> tokens.push(self.create_token(TokenType::DoubleQuote, None)),
                ' ' => tokens.push(self.create_token(TokenType::Space, None)),

                _ => {
                    let value = Some(self.get_string());
                    let token = self.create_token(TokenType::StringLiteral, value);
                    tokens.push(token);
                }
            }
            
            if self.at_eol() {
                return tokens;
            }

            self.get_next();
        }
    }

    fn get_next(&mut self) -> char {
        self.index += 1;
        self.curr = self.input[self.index];
        self.curr
    }

    fn get_string(&mut self) -> String {
        let stop: Vec<char> = vec!['\'', '\"', ' '];
        let mut out: String = String::new();

        out.push(self.curr);

        loop {
            if self.at_eol() || stop.contains(&self.peek(1).unwrap()) {
                return out;
            }

            out.push(self.get_next());
        }
    }

    fn create_token(&mut self, token_type: TokenType, value: Option<String>) -> Token {
        return Token {
            token_type: token_type,
            value: value
        }
    }

    fn in_bounds(&mut self, index: usize) -> bool {
        if index < self.input_len {
            return true;
        }

        return false;
    }

    fn at_eol(&mut self) -> bool { // end of line
        if self.index + 1 == self.input_len {
            return true;
        }

        return false;
    }

    fn peek(&mut self, index: usize) -> Option<char> {
        if !self.in_bounds(self.index + index) {
            return None;
        }
        
        return Some(self.input[self.index + index]);
    }

    fn skip(&mut self, index: usize) -> bool {
        if !self.in_bounds(self.index + index) {
            return false;
        }

        self.index += index;
        self.curr = self.input[self.index];
        return true;
    }
}