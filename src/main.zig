const std = @import("std");
const colour = @import("colour.zig");

pub fn main() !void {
    const r: i32 = 10;

    var ppm = PPMImage{ .width = 64, .height = 64 };
    const x_center = ppm.center_x();
    const y_center = ppm.center_y();
    try ppm.header();

    for (0..ppm.height) |_y| {
        const y = @as(i32, @intCast(_y));
        for (0..ppm.width) |_x| {
            const x = @as(i32, @intCast(_x));
            const x_adj = x - x_center;
            const y_adj = y - y_center;

            const calculated_r = try std.math.powi(i32, x_adj, 2) + try std.math.powi(i32, y_adj, 2);

            if (calculated_r <= r) {
                try ppm.write_pixel(colour.Black.into_ppm());
            } else {
                try ppm.write_pixel(colour.White.into_ppm());
            }
        }
    }
    try ppm.deinit();
}

const PPMImage = struct {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    width: usize,
    height: usize,
    _header: [16]u8 = undefined,

    fn center_x(self: PPMImage) i32 {
        return @as(i32, @intCast(@divFloor(self.width, 2)));
    }

    fn center_y(self: PPMImage) i32 {
        return @as(i32, @intCast(@divFloor(self.height, 2)));
    }

    fn header(self: *PPMImage) !void {
        try stdout.writeAll(std.fmt.bufPrint(&self._header, "P3\n{} {}\n255\n", .{ self.width, self.height }) catch "");
    }

    fn write_pixel(self: PPMImage, pixel: []u8) !void {
        _ = self;
        try stdout.writeAll(pixel);
    }

    fn deinit(self: PPMImage) !void {
        _ = self;
        try bw.flush();
    }
};
