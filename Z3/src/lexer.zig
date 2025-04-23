const std = @import("std");
const stdout = std.io.getStdOut().writer();
// const stdin = std.io.getStdIn().reader();
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Token = union(enum) {
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
    BangNotEqual, // can be ! (not), != (if not equal), or not then assign

    Literal: []const u8,
    EscapedChar: u8,
};

const Tokenizer = struct {
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

    fn printTokens(input: std.ArrayList(Token)) void {
        for (input.items) |token| {
            switch (token) {
                .Literal => |str| std.debug.print("Literal: {s}\n", .{str}),
                .EscapedChar => |c| std.debug.print("EscapedChar: {s}\n", .{&[1]u8 {c}}),
                else => std.debug.print("{s}\n", .{@tagName(token)})
            }
        }
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

    pub fn tokenize(self: *Tokenizer) !std.ArrayList(Token) {
        while (self.i < self.input.len) {
            var T: ?Token = null;
            switch (self.input[self.i]) {
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
                        // try out.append(Token{.Literal = "\\"});
                        T = Token{.Literal = "\\"};
                    }
                },
                '+' => T = self.xOrxEqual(Token.Plus, Token.PlusEqual),
                '-' => T = self.xOrxEqual(Token.Minus, Token.MinusEqual),
                '*' => T = self.xOrxEqual(Token.Star, Token.StarEqual),
                '/' => T = self.xOrxEqual(Token.Slash, Token.SlashEqual),
                '%' => T = self.xOrxEqual(Token.Mod, Token.ModEqual),
                '&' => T = self.xOrxEqual(Token.Ampersand, Token.ANDEqual),
                '|' => T = self.xOrxEqual(Token.Pipe, Token.OREqual),
                '^' => T = self.xOrxEqual(Token.XOR, Token.XOREqual),
                '!' => T = self.xOrxEqual(Token.NOT, Token.BangNotEqual),
                '=' => T = self.xOrxEqual(Token.Equal, Token.IF_Equal),
                else => {}
            }

            if (T) |token| {
                try self.out.append(token);
            }

            self.i += 1;
        }

        printTokens(self.out);
        return self.out;
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
    // const T: ?Token = null;
    // return T;
    // return tokenizer.out;
}