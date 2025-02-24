const std = @import("std");
const colour = @import("colour.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);

    const img = try std.fs.cwd().createFile("image.ppm", .{ .read = true });
    defer img.close();

    const stdout = bw.writer();
    const imgout = img.writer();
    const r: i32 = 10;

    const ppm = PPMImage{ .img_writer = imgout, .alloc = alloc, .width = 64, .height = 64 };
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
                try stdout.print("x", .{});
                try ppm.write_pixel(colour.Black.into_ppm());
            } else {
                try stdout.print(".", .{});
                try ppm.write_pixel(colour.White.into_ppm());
            }
        }
        try stdout.print("\n", .{});
    }
    try bw.flush();
}

const PPMImage = struct {
    img_writer: std.fs.File.Writer,
    alloc: std.mem.Allocator,
    width: usize,
    height: usize,

    fn center_x(self: PPMImage) i32 {
        return @as(i32, @intCast(@divFloor(self.width, 2)));
    }

    fn center_y(self: PPMImage) i32 {
        return @as(i32, @intCast(@divFloor(self.height, 2)));
    }

    fn header(self: PPMImage) !void {
        const h = try std.fmt.allocPrint(self.alloc, "P3\n{} {}\n255\n", .{ self.width, self.height });
        defer self.alloc.free(h);
        try self.img_writer.writeAll(h);
    }

    fn write_pixel(self: PPMImage, pixel: []u8) !void {
        try self.img_writer.writeAll(pixel);
    }
};
