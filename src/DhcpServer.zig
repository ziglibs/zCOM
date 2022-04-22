const std = @import("std");

const Socket = @import("Socket.zig");
const Ipv4 = @import("Ipv4.zig");
const MAC = @import("MAC.zig");

const DhcpServer = @This();

allocator: std.mem.Allocator,
socket: Socket,

pub fn init(allocator: std.mem.Allocator, socket: Socket) !DhcpServer {
    return DhcpServer{
        .allocator = allocator,
        .socket = socket,
    };
}

pub fn deinit(self: *DhcpServer) void {
    self.* = undefined;
}

pub fn addDynamicRange(self: *DhcpServer, first: Ipv4, last: Ipv4, mask: Ipv4) !*DhcpRange {
    _ = self;
    _ = first;
    _ = last;
    _ = mask;
    return error.NotImplementedYet;
}

pub fn addStaticLease(self: *DhcpServer, ip: Ipv4, address: MAC) !*Lease {
    _ = self;
    _ = ip;
    _ = address;
    return error.NotImplementedYet;
}

pub fn start(self: *DhcpServer) !void {
    _ = self;
    return error.NotImplementedYet;
}

test "dhcp server init/deinit" {
    var socket = Socket{}; // requires a udp socket bound to port 53

    var server = try DhcpServer.init(std.testing.allocator, socket);
    defer server.deinit();

    const dhcp_range = try server.addDynamicRange(
        Ipv4.new(192, 168, 2, 100),
        Ipv4.new(192, 168, 2, 199),
        Ipv4.createMask(24),
    );
    _ = dhcp_range;

    const lease = try server.addStaticLease(
        Ipv4.new(192, 168, 2, 42),
        try MAC.parse("98:fa:9b:ea:82:7b"),
    );
    _ = lease;

    try server.start();
}

pub const DhcpRange = struct {
    first: Ipv4,
    last: Ipv4,
    mask: Ipv4,
};

pub const Lease = struct {
    created: i64,
    refreshed: i64,
    expires: ?i64,
    owned_by: MAC,
    address: Ipv4,
};
