const std = @import("std");

const MAC = @This();

bytes: [6]u8,

pub fn new(a0: u8, a1: u8, a2: u8, a3: u8, a4: u8, a5: u8) MAC {
    return MAC{
        .bytes = .{ a0, a1, a2, a3, a4, a5 },
    };
}

pub fn parse(str: []const u8) !MAC {
    _ = str;
    return error.InvalidFormat;
}
