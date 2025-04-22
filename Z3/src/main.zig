const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const lexer = @import("lexer.zig");

pub fn main() !void {
    var buffer: [8192]u8 = undefined;
    try stdout.print("> ", .{});
    const result = stdin.readUntilDelimiter(&buffer, '\n') catch {
        try stdout.print("Input must be less than 8192 characters.\n", .{});
        return; 
    };

    const tokens = try lexer.tokenize(result);
    defer tokens.deinit();
    
    // const input = buffer[0..result.len];
    // try stdout.print("{s}\n", .{result});
}