const std = @import("std");
const stdout = std.io.getStdOut().writer();
// const stdin = std.io.getStdIn().reader();
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub const Token = union(enum) {
    // general syntax
    LParen,
    RParen,
    LBracket,
    RBracket,
    LCurly,
    RCurly,
    Dot,
    Comma,
    Hashtag,
    Shebang,
    // Bang,
    Dollar,
    Semicolon,
    DoubleQuote,
    SingleQuote,

    // keywords (will probably end up saving these for a parser)
    // If,
    // Else,
    // Switch,
    // Case,
    // While,
    // Do,
    // For,
    // Break,
    // Return,

    // arithmetic
    Plus,
    Minus,
    Star,
    Slash,
    Mod,

    // assignment and increment
    Equal,
    PlusEqual,
    MinusEqual,
    StarEqual,
    SlashEqual,
    ModEqual,
    PlusPlus, // x++
    MinusMinus,

    // bitwise operations
    AND, // &
    // OR, // |
    XOR, // ^
    NOT, // \!
    LSHIFT, // <<
    // RSHIFT, // >>

    // bitwise assignment
    ANDEqual, // &=
    OREqual, // |=
    XOREqual, // ^=
    LSHIFTEqual, // <<=
    RSHIFTEqual, // >>=

    // conditional logic
    IF_Equal, // ==
    // IF_NotEqual, // !=
    // LessThan,
    // GreaterThan,
    LE, // Less than or equal to
    GE,
    IF_AND, // &&
    IF_OR, // ||

    // ambigous characters
    LeftCarrot, // Less than; read file  (a < b); (Command < file) 
    RightCarrot, // Greater Than; write file (a > b); (Command > file)
    DoubleRightCarrot, // bitshift right; concat to a file 
    Ampersand, // bitwise AND; shell background process (a & b); (command &)
    Pipe, // bitwise or; Piping (a | b), (command | command)
    // Bang, // bang; not (!var), (!command)
    BangEqual, // can be ! (not), != (if not equal), or not then assign

    Literal: []const u8,
    EscapedChar: u8,
    Space,

    EOF,
    Unknown: u8
};

pub const Tokenizer = struct {
    i: u8,
    input: []const u8,
    out: std.ArrayList(Token),

    pub fn init(self: *Tokenizer) void {
        errdefer self.out.deinit();
    }

    fn peek(self: *Tokenizer) ?u8 {
        if (self.i + 1 >= self.input.len) {
            return null;
        }

        return self.input[self.i + 1];
    }

    fn xOrxEqual(self: *Tokenizer, T1: Token, T2: Token) Token {
        var T = T1;
        if (self.peek()) |c| {
            if (c == '=') {
                self.i += 1;
                T = T2;
            }
        }

        return T;
    }

    fn isDouble(self: *Tokenizer, c1: u8) bool {
        if(self.peek()) |c2| {
            if (c1 == c2) {
                self.i += 1;
                return true;
            }
        }

        return false;
    }

    pub fn tokenize(self: *Tokenizer) !std.ArrayList(Token) {
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();

        while (self.i < self.input.len) {
            var T: ?Token = null;
            var scanningLiteral: bool = false;
            const currC = self.input[self.i];

            switch (currC) {
                '(' => T = Token.LParen,
                ')' => T = Token.RParen,
                '[' => T = Token.LBracket,
                ']' => T = Token.RBracket,
                '{' => T = Token.LCurly,
                '}' => T = Token.RCurly,
                '.' => T = Token.Dot,
                ',' => T = Token.Comma,
                '$' => T = Token.Dollar,
                ';' => T = Token.Semicolon,
                '\"' => T = Token.DoubleQuote,
                '\'' => T = Token.SingleQuote,
                '\\' => {
                    if (self.peek()) |c| {
                        T = Token{.EscapedChar = c};
                        self.i += 1;
                    } else {
                        T = Token{.Literal = "\\"};
                    }
                },
                '+' => {
                    T = self.xOrxEqual(Token.Plus, Token.PlusEqual);
                    if (self.isDouble('+')) { T = Token.PlusPlus; }
                },
                '-' => {
                    T = self.xOrxEqual(Token.Minus, Token.MinusEqual);
                    if (self.isDouble('-')) { T = Token.MinusMinus; }
                },
                '*' => T = self.xOrxEqual(Token.Star, Token.StarEqual),
                '/' => T = self.xOrxEqual(Token.Slash, Token.SlashEqual),
                '%' => T = self.xOrxEqual(Token.Mod, Token.ModEqual),
                '&' => {
                    T = self.xOrxEqual(Token.Ampersand, Token.ANDEqual);
                    if (self.isDouble('&')) { T = Token.IF_AND; }
                },
                '|' => {
                    T = self.xOrxEqual(Token.Pipe, Token.ANDEqual);
                    if (self.isDouble('|')) { T = Token.IF_OR; }
                },
                '^' => T = self.xOrxEqual(Token.XOR, Token.XOREqual),
                '!' => T = self.xOrxEqual(Token.NOT, Token.BangEqual),
                '=' => T = self.xOrxEqual(Token.Equal, Token.IF_Equal),
                '<' => { // < <= << <<=
                    T = self.xOrxEqual(Token.LeftCarrot, Token.LE);
                    if (self.isDouble('<')) {
                         T = self.xOrxEqual(Token.LSHIFT, Token.LSHIFTEqual); 
                    }
                },
                '>' => { // > >= >> >>=
                    T = self.xOrxEqual(Token.RightCarrot, Token.GE);
                    if (self.isDouble('>')) {
                         T = self.xOrxEqual(Token.DoubleRightCarrot, Token.RSHIFTEqual); 
                    }
                },
                ' ' => T = Token.Space,
                'a'...'z', '@'...'Z', '0'...'9', '\n', '\r', '\t', '`', '~' => {
                    try buffer.append(currC);

                    if (self.peek()) |c| { // make sure next char fits this case as well
                        scanningLiteral = switch(c) {
                            'a'...'z', '@'...'Z', '0'...'9', '\n', '\r', '\t', '`', '~' => true,
                            else => false
                        };
                    }
                },
                else => T = Token{.Unknown  = currC}
            }

            if (T) |token| {
                try self.out.append(token);
            }

            if (!scanningLiteral and buffer.items.len != 0) {
                try self.out.append(Token{.Literal = try allocator.dupe(u8, buffer.items)});
                buffer.clearAndFree();
            }

            self.i += 1;
        }

        try self.out.append(Token.EOF);
        return self.out;
    }

    pub fn deinit(self: *Tokenizer) void {
        for (self.out.items) |token| {
            switch (token) { // frees strings since i had to heap allocate from a buffer D:
                .Literal => |str| allocator.free(str),
                else => {}
            }
        }

        self.out.deinit();
    }
};

pub fn tokenize(input: []const u8) !std.ArrayList(Token) {
    var tokenizer = Tokenizer{
        .i = 0,
        .input = input,
        .out = std.ArrayList(Token).init(allocator)
    };

    tokenizer.init();
    return tokenizer.tokenize();
}