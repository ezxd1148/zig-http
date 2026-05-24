const std = @import("std");
const linux = std.os.linux;

pub const unix_af = linux.AF.INET;
pub const stream_sock = linux.SOCK.STREAM;

const sockaddr_in = linux.sockaddr.in{
    .family = linux.AF.INET,
    .port = std.mem.nativeToBig(u16, 8080),
    .addr = 0,
    .zero = [_]u8{0} ** 8,
};

pub fn main() !void {
    var buf = std.mem.zeroes([1028]u8);
    const sendbuf = "HTTP/1.1 200 OK\r\nContent-Length: 5\r\n\r\nHello";

    // init socket
    const currentSocket = linux.socket(unix_af, stream_sock, 0);
    defer _ = linux.close(@as(i32, @intCast(currentSocket)));

    //bind
    _ = linux.bind(@as(i32, @intCast(currentSocket)), @ptrCast(&sockaddr_in), @sizeOf(linux.sockaddr.in));
    _ = linux.listen(@as(i32, @intCast(currentSocket)), 5);

    var address_accept = std.mem.zeroes(linux.sockaddr);
    var address_len_accept: linux.socklen_t = @sizeOf(linux.sockaddr);
    const accept_connection = linux.accept(@as(i32, @intCast(currentSocket)), &address_accept, &address_len_accept);
    defer _ = linux.close(@as(i32, @intCast(accept_connection)));

    // receive
    _ = linux.recvfrom(@as(i32, @intCast(accept_connection)), &buf, buf.len, 0, null, null);
    std.debug.print("{s}\n", .{buf[0..]});

    // send
    const buflen = sendbuf.len; //before being turned to [*]const u8
    _ = linux.sendto(@as(i32, @intCast(accept_connection)), sendbuf, buflen, 0, null, 0);
}
