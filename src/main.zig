const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const util = @import("util.zig");
const lexer = @import("lexer.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var buffer: [8192]u8 = undefined;
    try stdout.print("> ", .{});
    const result = stdin.readUntilDelimiter(&buffer, '\n') catch {
        try stdout.print("Input must be less than 8192 characters.\n", .{});
        return; 
    };

    var tokenizer = lexer.Tokenizer.init(result, allocator);
    const tokens = try tokenizer.tokenize();
    util.printTokens(tokens);
    // _ = tokens;

    tokenizer.deinit();
}