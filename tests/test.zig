const std = @import("std");
const testing = std.testing;

const lexer = @import("../src/lexer.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

test "lexer" {
    var tokenizer = try lexer.Tokenizer.init(allocator);
    testing.expectEqaul(tokenizer.tokenize("."), lexer.token.Dot);
}
