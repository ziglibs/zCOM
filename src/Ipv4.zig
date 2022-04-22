const std = @import("std");

const Ipv4 = @This();

pub const any = new(255, 255, 255, 255);
pub const loopback = new(127, 0, 0, 1);
pub const broadcast = new(255, 255, 255, 255);

bytes: [4]u8,

pub fn new(a: u8, b: u8, c: u8, d: u8) Ipv4 {
    return Ipv4{ .bytes = .{ a, b, c, d } };
}

pub fn eql(a: Ipv4, b: Ipv4) bool {
    return std.mem.eql(u8, &a.bytes, &b.bytes);
}

pub fn createMask(prefix: u6) Ipv4 {
    std.debug.assert(prefix <= 32);
    if (prefix == 0) return new(0, 0, 0, 0);
    if (prefix == 32) return new(255, 255, 255, 255);
    const value = @as(u32, 0xFFFFFFFF) << @truncate(u5, 32 - prefix);
    var ip: Ipv4 = undefined;
    std.mem.writeIntBig(u32, &ip.bytes, value);
    return ip;
}

pub fn parse(string: []const u8) !Ipv4 {
    var items: [4][]const u8 = undefined;
    var item_count: usize = 0;
    {
        var spliterator = std.mem.split(u8, string, ".");
        while (spliterator.next()) |item| {
            if (item_count >= items.len) {
                return error.InvalidFormat;
            }
            items[item_count] = item;
            item_count += 1;
        }
    }

    switch (item_count) {
        1...3 => return error.InvalidFormat,
        4 => return new(
            try std.fmt.parseInt(u8, items[0], 10),
            try std.fmt.parseInt(u8, items[1], 10),
            try std.fmt.parseInt(u8, items[2], 10),
            try std.fmt.parseInt(u8, items[3], 10),
        ),
        else => unreachable,
    }

    return error.InvalidFormat;
}

pub fn format(ip: Ipv4, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    _ = fmt;
    _ = options;
    try writer.print("{d}.{d}.{d}.{d}", .{ ip.bytes[0], ip.bytes[1], ip.bytes[2], ip.bytes[3] });
}

test "eql" {
    try std.testing.expect(eql(new(0, 0, 0, 0), std.mem.zeroes(Ipv4)));
    try std.testing.expect(eql(new(127, 0, 0, 1), .{ .bytes = .{ 127, 0, 0, 1 } }));
    try std.testing.expect(eql(broadcast, new(0xFF, 0xFF, 0xFF, 0xFF)));
}

test "createMask" {
    try std.testing.expect(eql(createMask(0), new(0, 0, 0, 0)));
    try std.testing.expect(eql(createMask(1), new(128, 0, 0, 0)));
    try std.testing.expect(eql(createMask(2), new(192, 0, 0, 0)));
    try std.testing.expect(eql(createMask(3), new(224, 0, 0, 0)));
    try std.testing.expect(eql(createMask(4), new(240, 0, 0, 0)));
    try std.testing.expect(eql(createMask(5), new(248, 0, 0, 0)));
    try std.testing.expect(eql(createMask(6), new(252, 0, 0, 0)));
    try std.testing.expect(eql(createMask(7), new(254, 0, 0, 0)));
    try std.testing.expect(eql(createMask(8), new(255, 0, 0, 0)));
    try std.testing.expect(eql(createMask(9), new(255, 128, 0, 0)));
    try std.testing.expect(eql(createMask(10), new(255, 192, 0, 0)));
    try std.testing.expect(eql(createMask(11), new(255, 224, 0, 0)));
    try std.testing.expect(eql(createMask(12), new(255, 240, 0, 0)));
    try std.testing.expect(eql(createMask(13), new(255, 248, 0, 0)));
    try std.testing.expect(eql(createMask(14), new(255, 252, 0, 0)));
    try std.testing.expect(eql(createMask(15), new(255, 254, 0, 0)));
    try std.testing.expect(eql(createMask(16), new(255, 255, 0, 0)));
    try std.testing.expect(eql(createMask(17), new(255, 255, 128, 0)));
    try std.testing.expect(eql(createMask(18), new(255, 255, 192, 0)));
    try std.testing.expect(eql(createMask(19), new(255, 255, 224, 0)));
    try std.testing.expect(eql(createMask(20), new(255, 255, 240, 0)));
    try std.testing.expect(eql(createMask(21), new(255, 255, 248, 0)));
    try std.testing.expect(eql(createMask(22), new(255, 255, 252, 0)));
    try std.testing.expect(eql(createMask(23), new(255, 255, 254, 0)));
    try std.testing.expect(eql(createMask(24), new(255, 255, 255, 0)));
    try std.testing.expect(eql(createMask(25), new(255, 255, 255, 128)));
    try std.testing.expect(eql(createMask(26), new(255, 255, 255, 192)));
    try std.testing.expect(eql(createMask(27), new(255, 255, 255, 224)));
    try std.testing.expect(eql(createMask(28), new(255, 255, 255, 240)));
    try std.testing.expect(eql(createMask(29), new(255, 255, 255, 248)));
    try std.testing.expect(eql(createMask(30), new(255, 255, 255, 252)));
    try std.testing.expect(eql(createMask(31), new(255, 255, 255, 254)));
    try std.testing.expect(eql(createMask(32), new(255, 255, 255, 255)));
}

test "parse 4-dotted" {
    try std.testing.expectEqual(new(0, 0, 0, 0), try parse("0.0.0.0"));
    try std.testing.expectEqual(new(1, 2, 3, 4), try parse("1.2.3.4"));
    try std.testing.expectEqual(new(255, 255, 255, 0), try parse("255.255.255.0"));
    try std.testing.expectEqual(new(192, 168, 42, 1), try parse("192.168.42.1"));
}
