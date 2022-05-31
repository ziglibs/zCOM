const std = @import("std");
const network = @import("network");

const logger = std.log.scoped(.dhcp);

const IPv4 = std.x.os.IPv4;

const MessageType = enum(u8) {
    Discover = 1,
    Offer = 2,
    Request = 3,
    Ack = 5,
    Nak = 6,
    Release = 7,
    Inform = 8,
};

const OptionTypes = enum(u8) {
    Pad = 0,
    // DHCP options
    SubnetMask = 1,
    TimeOffset = 2,
    Router = 3,
    TimeServer = 4,
    NameServer = 5,
    DomainNameServer = 6,
    LogServer = 7,
    CookieServer = 8,
    LprServer = 9,
    ImpressServer = 10,
    ResourceLocationServer = 11,
    HostName = 12,
    BootFileSize = 13,
    MeritDumpFile = 14,
    DomainName = 15,
    SwapServer = 16,
    RootPath = 17,
    ExtensionsPath = 18,

    // IP layer
    StaticRoute = 33,

    // app layer and service params
    NetworkTimeProtocolServers = 42,

    // DHCP extensions
    RequestedIpAddress = 50,
    IpAddressLeaseTime = 51,
    Overload = 52,
    DhcpMessageType = 53,
    ServerIdentifier = 54,
    ParameterRequestList = 55,
    Message = 56,
    MaximumDhcpMessageSize = 57,
    RenewalTimeValue = 58,
    RebindingTimeValue = 59,
    VendorClassIdentifier = 60,
    ClientIdentifier = 61,

    TFtpServerName = 66,
    BootfileName = 67,

    UserClass = 93,

    TzPosixString = 100,
    TzDatabaseString = 101,

    ClasslessRouteFormat = 121,
    _,
};

const Option = union(OptionTypes) {
    Pad: void,
    // DHCP options
    SubnetMask: IPv4,
    TimeOffset: u32,
    Router: []IPv4,
    TimeServer: []IPv4,
    NameServer: []IPv4,
    DomainNameServer: []IPv4,
    LogServer: []IPv4,
    CookieServer: []IPv4,
    LprServer: []IPv4,
    ImpressServer: []IPv4,
    ResourceLocationServer: []IPv4,
    HostName: []const u8,
    BootFileSize: u16,
    MeritDumpFile: []const u8,
    DomainName: []const u8,
    SwapServer: IPv4,
    RootPath: []const u8,
    ExtensionsPath: []const u8,

    // IP layer
    StaticRoute: Unimplemented,

    // app layer and service params
    NetworkTimeProtocolServers: Unimplemented,

    // DHCP extensions
    RequestedIpAddress: IPv4,
    IpAddressLeaseTime: u32,
    Overload: Unimplemented,
    DhcpMessageType: MessageType,
    ServerIdentifier: []const u8,
    ParameterRequestList: []OptionTypes,
    Message: []const u8,
    MaximumDhcpMessageSize: u16,
    RenewalTimeValue: u32,
    RebindingTimeValue: u32,
    VendorClassIdentifier: []const u8,
    ClientIdentifier: []const u8,

    TFtpServerName: Unimplemented,
    BootfileName: Unimplemented,

    UserClass: Unimplemented,

    TzPosixString: Unimplemented,
    TzDatabaseString: Unimplemented,

    ClasslessRouteFormat: Unimplemented,

    pub const Unimplemented = struct {
        payload: []const u8,
    };

    pub const ParseResult = struct {
        option: Option,
        rest: []const u8,
    };

    pub fn parse(data: []const u8) !?ParseResult {
        @setEvalBranchQuota(200000);
        if (data.len < 1)
            return error.MissingOptionCode;

        if (data[0] == 0)
            return ParseResult{ .option = Option{ .Pad = .{} }, .rest = data[1..] };

        if (data[0] == 0xff)
            return null;

        if (data.len < 2)
            return error.NotEnoghData;

        inline for (std.meta.fields(Option)) |field| {
            const enum_value = comptime std.meta.stringToEnum(OptionTypes, field.name).?;

            if (data[0] == @enumToInt(enum_value)) {
                const length = data[1];
                if (length + 2 > data.len)
                    return error.NotEnoghDataForOption;

                const payload = data[2 .. 2 + length];
                const rest = data[2 + length ..];

                switch (field.field_type) {
                    []const u8 => {
                        return ParseResult{ .option = @unionInit(Option, field.name, payload), .rest = rest };
                    },
                    IPv4 => {
                        const T = IPv4;
                        if (payload.len < @sizeOf(T))
                            return error.NotEnoughDataForOption;

                        if (payload.len > @sizeOf(T))
                            logger.warn("option '{s}' has {} extra bytes", .{ field.name, payload.len - @sizeOf(T) });

                        return ParseResult{ .option = @unionInit(Option, field.name, @bitCast(T, payload[0..@sizeOf(T)].*)), .rest = rest };
                    },
                    []IPv4 => {
                        const T = IPv4;
                        // NOTE: this is a bit hacky
                        const ips: []T = @ptrCast([]T, payload)[0 .. payload.len / @sizeOf(T)];

                        if (payload.len > ips.len * @sizeOf(T))
                            logger.warn("option '{s}' has {} extra bytes", .{ field.name, payload.len - ips.len * @sizeOf(T) });

                        return ParseResult{ .option = @unionInit(Option, field.name, ips), .rest = rest };
                    },
                    u16, u32 => |T| {
                        if (payload.len < @sizeOf(T))
                            return error.NotEnoughDataForOption;

                        if (payload.len > @sizeOf(T))
                            logger.warn("option '{s}' has {} extra bytes", .{ field.name, payload.len - @sizeOf(T) });

                        return ParseResult{ .option = @unionInit(Option, field.name, std.mem.readIntBig(T, payload[0..@sizeOf(T)])), .rest = rest };
                    },
                    []OptionTypes => {
                        return ParseResult{ .option = @unionInit(Option, field.name, @ptrCast([]OptionTypes, payload)), .rest = rest };
                    },
                    MessageType => {
                        const T = MessageType;

                        if (payload.len < @sizeOf(T))
                            return error.NotEnoughDataForOption;

                        if (payload.len > @sizeOf(T))
                            logger.warn("option '{s}' has {} extra bytes", .{ field.name, payload.len - @sizeOf(T) });

                        return ParseResult{ .option = @unionInit(Option, field.name, try std.meta.intToEnum(MessageType, payload[0])), .rest = rest };
                    },
                    Unimplemented => {
                        return ParseResult{ .option = @unionInit(Option, field.name, Unimplemented{ .payload = payload }), .rest = rest };
                    },
                    void => {},
                    else => |t| {
                        @compileError("unimplemnted parser for " ++ @typeName(t));
                    },
                }
            }
        }
        return null;
    }
};

test "parse basic dhcp options" {
    // zig fmt: off
    const data = &[_]u8{
        // SubnetMask - one IPv4 address
        1, 4, 255, 255, 255, 0,
        // Router - multiple IPv4 addresses
        3, 8,
              1, 2, 3, 4,
              5, 6, 7, 8,
        // MessageType = one byte enum
        53, 1, 1,
        // 3 bytes of padding
        0, 0, 0,
        // MaximumDhcpMessageSize - u16
        57, 2, 2, 64,
        // ParameterRequestList - multiple enum of 1 byte
        55, 2, 1, 3,
        // HostName - []u8
        12, 4, 'z', 'C', 'O', 'M',

        // end
        255
    };
    // zig fmt: on

    var rest: []const u8 = data;

    const subnet_mask = blk: {
        const result = (try Option.parse(rest)) orelse return error.MissingData;
        rest = result.rest;
        break :blk result.option.SubnetMask;
    };
    try std.testing.expectEqual(try IPv4.parse("255.255.255.0"), subnet_mask);

    const router = blk: {
        const result = (try Option.parse(rest)) orelse return error.MissingData;
        rest = result.rest;
        break :blk result.option.Router;
    };
    try std.testing.expectEqualSlices(IPv4, &[2]IPv4{ try IPv4.parse("1.2.3.4"), try IPv4.parse("5.6.7.8") }, router);

    const message_type = blk: {
        const result = (try Option.parse(rest)) orelse return error.MissingData;
        rest = result.rest;
        break :blk result.option.DhcpMessageType;
    };
    try std.testing.expectEqual(MessageType.Discover, message_type);

    for ("012") |_| {
        const result = (try Option.parse(rest)) orelse return error.MissingData;
        rest = result.rest;
        _ = result.option.Pad;
    }

    const maximum_dhcp_message_size = blk: {
        const result = (try Option.parse(rest)) orelse return error.MissingData;
        rest = result.rest;
        break :blk result.option.MaximumDhcpMessageSize;
    };
    try std.testing.expectEqual(@as(u16, 576), maximum_dhcp_message_size);

    const parameter_request_list = blk: {
        const result = (try Option.parse(rest)) orelse return error.MissingData;
        rest = result.rest;
        break :blk result.option.ParameterRequestList;
    };
    try std.testing.expectEqualSlices(OptionTypes, &[2]OptionTypes{ OptionTypes.SubnetMask, OptionTypes.Router }, parameter_request_list);

    const hostname = blk: {
        const result = (try Option.parse(rest)) orelse return error.MissingData;
        rest = result.rest;
        break :blk result.option.HostName;
    };
    try std.testing.expectEqualSlices(u8, "zCOM", hostname);

    try std.testing.expectEqual(try Option.parse(rest), null);
}
