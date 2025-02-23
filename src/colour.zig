const std = @import("std");

const RGB = struct {
    r: u16,
    g: u16,
    b: u16,
    repr: [16]u8 = undefined,

    pub fn into_ppm(self: *RGB) []u8 {
        return std.fmt.bufPrint(&self.repr, "{:03} {:03} {:03}\n", .{ self.r, self.g, self.b }) catch &"".*;
    }
};

pub var Black = RGB{ .r = 0, .g = 0, .b = 0 };
pub var White = RGB{ .r = 255, .g = 255, .b = 255 };
