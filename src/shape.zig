const std = @import("std");

const Rectangle = struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,

    pub fn intersects(self: @This(), other: @This()) bool {
        return self.x < other.x + other.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + self.height > other.y;
    }
};

test "overlaps" {
    const rect1: Rectangle = .{
        .x = 0,
        .y = 0,
        .width = 10,
        .height = 10,
    };

    const rect2: Rectangle = .{
        .x = 0,
        .y = 0,
        .width = 10,
        .height = 10,
    };

    try std.testing.expect(rect1.intersects(rect2));
}

test "disjoint" {
    const rect1: Rectangle = .{
        .x = 0,
        .y = 0,
        .width = 10,
        .height = 10,
    };

    const rect2: Rectangle = .{
        .x = 11,
        .y = 11,
        .width = 10,
        .height = 10,
    };

    try std.testing.expect(!rect1.intersects(rect2));
}

test "touch" {
    const rect1: Rectangle = .{
        .x = 0,
        .y = 0,
        .width = 10,
        .height = 10,
    };

    const rect2: Rectangle = .{
        .x = 10,
        .y = 10,
        .width = 10,
        .height = 10,
    };

    try std.testing.expect(!rect1.intersects(rect2));
}
