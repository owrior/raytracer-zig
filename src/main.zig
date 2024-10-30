const std = @import("std");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);

    const img = try std.fs.cwd().createFile("image.ppm", .{ .read = true });
    defer img.close();

    const stdout = bw.writer();
    const imgout = img.writer();
    const px: i32 = 64;
    const py: i32 = 64;
    const r: i32 = 10;

    const x_center = px / 2;
    const y_center = py / 2;

    //_ = try std.fmt.formatInt(px, 32, .lower, .{}, imgout);
    _ = try imgout.writeAll("P3\n64 64\n");
    //_ = try std.fmt.formatInt(px, 32, .lower, .{}, imgout);
    //_ = try imgout.writeAll("\n");
    _ = try imgout.writeAll("255\n");

    for (0..py) |_y| {
        const y = @as(i32, @intCast(_y));
        for (0..px) |_x| {
            const x = @as(i32, @intCast(_x));
            const x_adj = x - x_center;
            const y_adj = y - y_center;

            const calculated_r = try std.math.powi(i32, x_adj, 2) + try std.math.powi(i32, y_adj, 2);
            if (calculated_r <= r) {
                try stdout.print("x", .{});
                _ = try imgout.writeAll("  0   0   0\n");
            } else {
                try stdout.print(".", .{});
                _ = try imgout.writeAll("255 255 255\n");
            }
        }
        try stdout.print("\n", .{});
    }
    try bw.flush();
}

const PPMImage = struct {
    width: i32,
    height: i32,

    fn write_header(self: *PPMImage, writer: std.io.Writer) !void {
        _ = try writer.writeAll("P3\n");

        var buf: [9]u8 = undefined;
        const px_format = std.fmt.bufPrint(&buf, "{} {}\n", .{ self.width, self.height });
        _ = try writer.writeAll(px_format);

        _ = try writer.writeAll("255\n");
    }
};
