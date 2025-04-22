const std = @import("std");
const stdout = std.io.getStdOut().writer();
// const stdin = std.io.getStdIn().reader();
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const TokenType = enum {
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
    Dollar,
    Semicolon,
    DoubleQuote,
    SingleQuote,
    EscapedChar,

    // keywords (will probably end up saving these for a parser)
    If,
    Else,
    Switch,
    Case,
    While,
    Do,
    For,
    Break,
    Return,

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
    // LSHIFT, // <<
    // RSHIFT, // >>

    // bitwise assignment
    ANDEqual, // &=
    OREqual, // |=
    XOREqual, // ^=
    LSHIFTEqual, // <<=
    RSHIFTEqual, // >>=

    // conditional logic
    IF_Equal, // ==
    IF_NotEqual, // !=
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

    Literal
};

const Token = struct {
    TokenType: TokenType,
    Value: []const u8
};

fn createToken(Type: TokenType, Value: []const u8) Token {
    return Token {
        .TokenType = Type,
        .Value = Value
    };
}

fn peek(input: []const u8, i: u32) ?u8 {
    if (i + 1 >= input.len) {
        return null;
    }

    return input[i + 1];
}

fn printTokens(input: std.ArrayList(Token)) void {
    for (input.items) |token| {
        std.debug.print("{s}: {s}\n", .{@tagName(token.TokenType), token.Value});
    }
}

pub fn tokenize(input: []const u8) !std.ArrayList(Token) {
    var outputTokens = std.ArrayList(Token).init(allocator);
    errdefer outputTokens.deinit();

    var i: u32 = 0;
    while (i < input.len) {
        const c = input[i];
        switch (c) {
            '(' => {
                try outputTokens.append(createToken(TokenType.LParen, ""));
            },
            ')' => {
                try outputTokens.append(createToken(TokenType.RParen, ""));
            },
            '[' => {
                try outputTokens.append(createToken(TokenType.LBracket, ""));
            },
            ']' => {
                try outputTokens.append(createToken(TokenType.RBracket, ""));
            },
            '{' => {
                try outputTokens.append(createToken(TokenType.LCurly, ""));
            },
            '}' => {
                try outputTokens.append(createToken(TokenType.RCurly, ""));
            },
            '.' => {
                try outputTokens.append(createToken(TokenType.Dot, ""));
            },
            ',' => {
                try outputTokens.append(createToken(TokenType.Comma, ""));
            },
            '#' => {
                if (i + 1 >= input.len) {
                    try outputTokens.append(createToken(TokenType.Hashtag, ""));
                    break;
                }

                if (input[i + 1] == '!') {
                    try outputTokens.append(createToken(TokenType.Shebang, ""));
                    i += 1;
                }
                else {
                    try outputTokens.append(createToken(TokenType.Hashtag, ""));
                }
            },
            '$' => {
                try outputTokens.append(createToken(TokenType.Dollar, ""));
            },
            ';' => {
                try outputTokens.append(createToken(TokenType.Semicolon, ""));
            },
            '\"' => {
                try outputTokens.append(createToken(TokenType.DoubleQuote, ""));
            },
            '\'' => {
                try outputTokens.append(createToken(TokenType.SingleQuote, ""));
            },
            '|' => {
                try outputTokens.append(createToken(TokenType.Pipe, ""));
            },
            '!' => {
                try outputTokens.append(createToken(TokenType.NOT, ""));
            },
            // ' ' => {
            //     try outputTokens.append(createToken(TokenType.Space, ""));
            // },
            '\\' => {
                if (peek(input, i)) |s| {                    
                    try outputTokens.append(createToken(TokenType.EscapedChar, &[1]u8 {s}));
                    i += 1;
                } else {
                    try outputTokens.append(createToken(TokenType.Literal, "\\"));
                }
            },
            '+' => {
                if (peek(input, i)) |s| {
                    switch (s) {
                        '+' => {
                            try outputTokens.append(createToken(TokenType.PlusPlus, ""));
                            i += 1;
                        },
                        '=' => {
                            try outputTokens.append(createToken(TokenType.PlusEqual, ""));
                            i += 1;
                        },
                        else => {
                            try outputTokens.append(createToken(TokenType.Plus, ""));
                        }
                    }
                }
                else { // lowkey probably just err, why would it end with an operator?
                    try outputTokens.append(createToken(TokenType.Plus, ""));
                }
                // try outputTokens.append(createToken(TokenType.Comma, ""));
            },
            '-' => {
                if (peek(input, i)) |s| {
                    switch (s) {
                        '-' => {
                            try outputTokens.append(createToken(TokenType.MinusMinus, ""));
                            i += 1;
                        },
                        '=' => {
                            try outputTokens.append(createToken(TokenType.MinusEqual, ""));
                            i += 1;
                        },
                        else => {
                            try outputTokens.append(createToken(TokenType.Minus, ""));
                        }
                    }
                }
                else { // lowkey probably just err, why would it end with an operator?
                    try outputTokens.append(createToken(TokenType.Minus, ""));
                }
                // try outputTokens.append(createToken(TokenType.Comma, ""));
            },
            '*' => {
                if (peek(input, i)) |s| {
                    if (s == '=') {
                        try outputTokens.append(createToken(TokenType.StarEqual, ""));
                        i += 1;
                    }
                    else {
                        try outputTokens.append(createToken(TokenType.Star, ""));
                    }
                } else {
                    try outputTokens.append(createToken(TokenType.Star, ""));
                }
            },
            '/' => {
                if (peek(input, i)) |s| {
                    if (s == '=') {
                        try outputTokens.append(createToken(TokenType.SlashEqual, ""));
                        i += 1;
                    }
                    else {
                        try outputTokens.append(createToken(TokenType.Slash, ""));
                    }
                } else {
                    try outputTokens.append(createToken(TokenType.Slash, ""));
                }
            },
            '%' => {
                if (peek(input, i)) |s| {
                    if (s == '=') {
                        try outputTokens.append(createToken(TokenType.ModEqual, ""));
                        i += 1;
                    }
                    else {
                        try outputTokens.append(createToken(TokenType.Mod, ""));
                    }
                } else {
                    try outputTokens.append(createToken(TokenType.Mod, ""));
                }
            },
            else => {
            },
        }

        // std.debug.print("{any}", .{i});
        i += 1;
    }
    
    printTokens(outputTokens);
    return outputTokens;
}