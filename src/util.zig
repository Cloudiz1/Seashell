const std = @import("std");
const lexer = @import("lexer.zig");

pub fn printToken(token: lexer.Token) void {
    switch (token) {
        .StringLiteral => |str| std.debug.print("String Literal: {s}\n", .{str}),
        .Identifier => |str| std.debug.print("Identifier: {s}\n", .{str}),
        .EscapedChar => |c| std.debug.print("EscapedChar: {s}\n", .{&[1]u8{c}}),
        .Int => |n| std.debug.print("Int: {}\n", .{n}),
        .Float => |n| std.debug.print("Float: {}\n", .{n}),
        else => std.debug.print("{s}\n", .{@tagName(token)}),
    }
}

pub fn printTokens(input: std.ArrayList(lexer.Token)) void {
    for (input.items) |token| {
        printToken(token);
    }
}

