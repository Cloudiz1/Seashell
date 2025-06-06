const std = @import("std");
const util = @import("util.zig");

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

    // keywords
    If,
    Else,
    Switch,
    Case,
    While,
    Do,
    For,
    Break,
    Return,
    True,
    False,

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
    StringLiteral: []const u8,
    Identifier: []const u8,
    Bool: bool,
    EscapedChar: u8,
    Int: i32,
    Float: f32,
    // Space,

    EOF,
    Unknown: u8,
};

pub const Tokenizer = struct {
    i: u8,
    input: []const u8,
    out: std.ArrayList(Token),
    map: std.StringHashMap(Token),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Tokenizer {
        var map = std.StringHashMap(Token).init(allocator);

        try map.put("if", Token.If);
        try map.put("else", Token.Else);
        try map.put("switch", Token.Switch);
        try map.put("case", Token.Case);
        try map.put("while", Token.While);
        try map.put("do", Token.Do);
        try map.put("for", Token.For);
        try map.put("break", Token.Break);
        try map.put("return", Token.Return);
        try map.put("true", Token{ .Bool = true });
        try map.put("false", Token{ .Bool = false });

        const tokenizer = Tokenizer{ .i = 0, .input = "", .out = std.ArrayList(Token).init(allocator), .map = map, .allocator = allocator };

        // errdefer self.deinit();

        return tokenizer;
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
        if (self.peek()) |c2| {
            if (c1 == c2) {
                self.i += 1;
                return true;
            }
        }

        return false;
    }

    fn scanStringLiteral(self: *Tokenizer, delimiter: u8, allocator: std.mem.Allocator) !Token {
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();

        while (self.peek()) |c| {
            // std.debug.print("{}", .{@TypeOf(delimiter)});
            if (c == delimiter) {
                self.i += 1;
                const s = try allocator.dupe(u8, buffer.items);
                return Token{ .StringLiteral = s };
            } else {
                try buffer.append(c);
                self.i += 1;
            }
        }

        return error.missingEndQuote;
    }

    fn scanNumberOrFloat(self: *Tokenizer, currC: u8, allocator: std.mem.Allocator) !Token {
        var float: bool = false;
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();

        try buffer.append(currC);

        while (self.peek()) |c| {
            switch (c) {
                '0'...'9' => {
                    self.i += 1;
                    try buffer.append(c);
                },
                '.' => {
                    if (!float) {
                        self.i += 1;
                        try buffer.append(c);
                        float = true;
                    } else { // two dots in one float which of course is non sensical.
                        return error.ImproperFloatSyntax;
                    }
                },
                else => {
                    break;
                },
            }
        }

        const s = try allocator.dupe(u8, buffer.items);
        defer allocator.free(s);

        if (float) {
            return Token{ .Float = try std.fmt.parseFloat(f32, s) };
        } else {
            return Token{ .Int = try std.fmt.parseInt(i32, s, 10) };
        }
    }

    fn scanIdentifier(self: *Tokenizer, currC: u8, allocator: std.mem.Allocator) !Token {
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();

        try buffer.append(currC);

        while (self.peek()) |c| {
            switch (c) {
                'a'...'z', 'A'...'Z', '0'...'9', '_' => {
                    self.i += 1;
                    try buffer.append(c);
                },
                else => break,
            }
        }

        return Token{ .Identifier = try allocator.dupe(u8, buffer.items) };
    }

    pub fn tokenize(self: *Tokenizer, input: []const u8) !std.ArrayList(Token) {
        self.input = input;

        var buffer = std.ArrayList(u8).init(self.allocator);
        defer buffer.deinit();

        while (self.i < self.input.len) {
            var T: ?Token = null;
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
                '\\' => {
                    if (self.peek()) |c| {
                        T = Token{ .EscapedChar = c };
                        self.i += 1;
                    } else {
                        T = Token{ .StringLiteral = "\\" };
                    }
                },
                '+' => {
                    T = self.xOrxEqual(Token.Plus, Token.PlusEqual);
                    if (self.isDouble('+')) {
                        T = Token.PlusPlus;
                    }
                },
                '-' => {
                    T = self.xOrxEqual(Token.Minus, Token.MinusEqual);
                    if (self.isDouble('-')) {
                        T = Token.MinusMinus;
                    }
                },
                '*' => T = self.xOrxEqual(Token.Star, Token.StarEqual),
                '/' => T = self.xOrxEqual(Token.Slash, Token.SlashEqual),
                '%' => T = self.xOrxEqual(Token.Mod, Token.ModEqual),
                '&' => {
                    T = self.xOrxEqual(Token.Ampersand, Token.ANDEqual);
                    if (self.isDouble('&')) {
                        T = Token.IF_AND;
                    }
                },
                '|' => {
                    T = self.xOrxEqual(Token.Pipe, Token.ANDEqual);
                    if (self.isDouble('|')) {
                        T = Token.IF_OR;
                    }
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
                ' ' => {},
                '\"', '\'' => {
                    T = try self.scanStringLiteral(currC, self.allocator);
                },
                '0'...'9' => {
                    T = try self.scanNumberOrFloat(currC, self.allocator);
                },
                'a'...'z', 'A'...'Z' => {
                    T = try self.scanIdentifier(currC, self.allocator);
                },
                else => T = Token{ .Unknown = currC },
            }

            if (T) |token| {
                switch (token) {
                    .Identifier => |str| {
                        if (self.map.contains(str)) {
                            T = self.map.get(str);
                            self.allocator.free(str); // str was duped, we dont use it anymore, so we free
                        }
                    },
                    else => {},
                }
            }

            if (T) |token| {
                try self.out.append(token);
            }

            self.i += 1;
        }

        try self.out.append(Token.EOF);
        return self.out;
    }

    pub fn deinit(self: *Tokenizer) void {
        for (self.out.items) |token| {
            switch (token) { // frees strings since i had to heap allocate from a buffer D:
                .StringLiteral, .Identifier => |val| self.allocator.free(val),
                else => {},
            }
        }

        self.out.deinit();
        self.map.deinit();
    }
};

fn Token_test(tokens: std.ArrayList(Token), expectedTokens: std.ArrayList(Token)) !void {
    const testing = std.testing;
    try testing.expectEqual(tokens.items.len, expectedTokens.items.len);
    for (tokens.items, expectedTokens.items) |token, expectedToken| {
        switch (token) {
            .Identifier => |val| try testing.expectEqualStrings(val, expectedToken.Identifier),
            .StringLiteral => |val| try testing.expectEqualStrings(val, expectedToken.StringLiteral),
            else => try testing.expectEqual(token, expectedToken),
        }
    }
}

test "single char tokens" {
    const allocator = std.testing.allocator;

    var tokenizer = try Tokenizer.init(allocator);
    const tokens = try tokenizer.tokenize("()[]{}.,$;");
    defer tokenizer.deinit();

    const expectedTokens = [_]Token{ Token.LParen, Token.RParen, Token.LBracket, Token.RBracket, Token.LCurly, Token.RCurly, Token.Dot, Token.Comma, Token.Dollar, Token.Semicolon, Token.EOF };
    var expectedTokensList = std.ArrayList(Token).init(allocator);
    try expectedTokensList.appendSlice(&expectedTokens);
    defer expectedTokensList.deinit();

    try Token_test(tokens, expectedTokensList);
}

test "single, double, or single equal tokens" {
    const allocator = std.testing.allocator;

    var tokenizer = try Tokenizer.init(allocator);
    defer tokenizer.deinit();
    const tokens = try tokenizer.tokenize("+ ++ += * *= == ^ ^= < << <= <<=");

    const expectedTokens = [_]Token{ Token.Plus, Token.PlusPlus, Token.PlusEqual, Token.Star, Token.StarEqual, Token.IF_Equal, Token.XOR, Token.XOREqual, Token.LeftCarrot, Token.LSHIFT, Token.LE, Token.LSHIFTEqual, Token.EOF };
    var expectedTokensList = std.ArrayList(Token).init(allocator);
    try expectedTokensList.appendSlice(&expectedTokens);
    defer expectedTokensList.deinit();

    try Token_test(tokens, expectedTokensList);
}

test "keywords" {
    const allocator = std.testing.allocator;

    var tokenizer = try Tokenizer.init(allocator);
    defer tokenizer.deinit();
    const tokens = try tokenizer.tokenize("if else switch case while do for break return true false");

    const expectedTokens = [_]Token{ Token.If, Token.Else, Token.Switch, Token.Case, Token.While, Token.Do, Token.For, Token.Break, Token.Return, Token{ .Bool = true }, Token{ .Bool = false }, Token.EOF };
    var expectedTokensList = std.ArrayList(Token).init(allocator);
    try expectedTokensList.appendSlice(&expectedTokens);
    defer expectedTokensList.deinit();

    try Token_test(tokens, expectedTokensList);
}

test "identifiers" {
    const allocator = std.testing.allocator;

    var tokenizer = try Tokenizer.init(allocator);
    defer tokenizer.deinit();
    const tokens = try tokenizer.tokenize("abc123 abcdefghijklmnopqrstuvwxyz ABC");

    const expectedTokens = [_]Token{ Token{ .Identifier = "abc123" }, Token{ .Identifier = "abcdefghijklmnopqrstuvwxyz" }, Token{ .Identifier = "ABC" }, Token.EOF };
    var expectedTokensList = std.ArrayList(Token).init(allocator);
    try expectedTokensList.appendSlice(&expectedTokens);
    defer expectedTokensList.deinit();

    try Token_test(tokens, expectedTokensList);
}

test "ints and floats" {
    const allocator = std.testing.allocator;

    var tokenizer = try Tokenizer.init(allocator);
    defer tokenizer.deinit();
    const tokens = try tokenizer.tokenize("123 1.23");

    const expectedTokens = [_]Token{ Token{ .Int = 123 }, Token{ .Float = 1.23 }, Token.EOF };
    var expectedTokensList = std.ArrayList(Token).init(allocator);
    try expectedTokensList.appendSlice(&expectedTokens);
    defer expectedTokensList.deinit();

    try Token_test(tokens, expectedTokensList);
}

test "escaped char" {
    const allocator = std.testing.allocator;

    var tokenizer = try Tokenizer.init(allocator);
    defer tokenizer.deinit();
    const tokens = try tokenizer.tokenize("\\n");

    const expectedTokens = [_]Token{ Token{ .EscapedChar = 'n' }, Token.EOF };
    var expectedTokensList = std.ArrayList(Token).init(allocator);
    try expectedTokensList.appendSlice(&expectedTokens);
    defer expectedTokensList.deinit();

    try Token_test(tokens, expectedTokensList);
}

test "string literals" {
    const allocator = std.testing.allocator;

    var tokenizer = try Tokenizer.init(allocator);
    defer tokenizer.deinit();
    const tokens = try tokenizer.tokenize("abc 123 \"abc 123 \\0\"");

    const expectedTokens = [_]Token{ Token{ .Identifier = "abc" }, Token{ .Int = 123 }, Token{ .StringLiteral = "abc 123 \\0" }, Token.EOF };
    var expectedTokensList = std.ArrayList(Token).init(allocator);
    try expectedTokensList.appendSlice(&expectedTokens);
    defer expectedTokensList.deinit();

    try Token_test(tokens, expectedTokensList);
}
