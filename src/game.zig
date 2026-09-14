const rl = @import("raylib");
const shape = @import("shape.zig");
const std = @import("std");

pub const GameConfig = struct {
    screen_width: i32,
    screen_height: i32,

    player_width: i32,
    player_height: i32,
    player_start_x: i32,
    player_start_y: i32,
    player_speed: i32,

    max_bullets: i32,
    bullet_width: i32,
    bullet_height: i32,
    bullet_speed: i32,

    shield_start_x: i32,
    shield_y: i32,
    shield_width: i32,
    shield_height: i32,
    shield_spacing: i32,

    invader_start_x: i32,
    invader_start_y: i32,
    invader_width: i32,
    invader_height: i32,
    invader_speed: i32,

    invader_spacing_x: i32,
    invader_spacing_y: i32,
    invader_cols: i32,
    invader_rows: i32,
    invader_move_delay: i32,
    invader_drop_distance: i32,
};

pub fn Player(comptime config: GameConfig) type {
    return struct {
        position_x: i32,
        position_y: i32,
        width: i32,
        height: i32,
        speed: i32,
        bullets: [config.max_bullets]Bullet(config),

        pub fn init() @This() {
            var i: i32 = 0;

            const BulletType = Bullet(config);
            var bullets: [config.max_bullets]BulletType = undefined;

            for (&bullets) |*bullet| {
                bullet.* = BulletType.init(
                    i,
                    0,
                    0,
                );
                i += 1;
            }

            return .{
                .position_x = config.player_start_x,
                .position_y = config.player_start_y,
                .width = config.player_width,
                .height = config.player_height,
                .speed = config.player_speed,
                .bullets = bullets,
            };
        }

        pub fn update(self: *@This()) void {
            self.move();
            self.shoot();

            for (&self.bullets) |*bullet| {
                bullet.update();
            }
        }

        pub fn move(self: *@This()) void {
            if (rl.isKeyDown(rl.KeyboardKey.right)) {
                self.position_x += self.speed;
                std.log.debug("player pos: x: {} y: {}", .{ self.position_x, self.position_y });
            }

            if (rl.isKeyDown(rl.KeyboardKey.left)) {
                self.position_x -= self.speed;
                std.log.debug("player pos: x: {} y: {}", .{ self.position_x, self.position_y });
            }

            if (self.position_x < 0) {
                self.position_x = 0;
            }

            if (self.position_x + self.width > rl.getScreenWidth()) {
                self.position_x = rl.getScreenWidth() - self.width;
            }
        }

        pub fn shoot(self: *@This()) void {
            if (rl.isKeyPressed(rl.KeyboardKey.space)) {
                for (&self.bullets) |*bullet| {
                    if (bullet.active) {
                        continue;
                    }

                    bullet.position_x = self.position_x + @divTrunc(self.width, 2) - @divTrunc(bullet.width, 2);
                    bullet.position_y = self.position_y;
                    bullet.active = true;

                    std.log.debug("bullet {}: shot", .{bullet.id});
                    break;
                }
            }
        }

        pub fn getRectangle(self: @This()) shape.Rectangle {
            return .{
                .x = self.position_x,
                .y = self.position_y,
                .width = self.width,
                .height = self.height,
            };
        }

        pub fn draw(self: @This()) void {
            rl.drawRectangle(
                (self.position_x),
                (self.position_y),
                (self.width),
                (self.height),
                rl.Color.blue,
            );

            for (&self.bullets) |*bullet| {
                bullet.draw();
            }
        }
    };
}

pub fn Bullet(comptime config: GameConfig) type {
    return struct {
        id: i32,
        position_x: i32,
        position_y: i32,
        width: i32,
        height: i32,
        speed: i32,
        active: bool,

        pub fn init(id: i32, position_x: i32, position_y: i32) @This() {
            return .{
                .id = id,
                .position_x = position_x,
                .position_y = position_y,
                .width = config.bullet_width,
                .height = config.bullet_height,
                .speed = config.bullet_speed,
                .active = false,
            };
        }

        pub fn update(self: *@This()) void {
            if (!self.active) {
                return;
            }

            self.position_y -= self.speed;
            if (self.position_y < 0) {
                self.active = false;
            }
        }

        pub fn draw(self: @This()) void {
            if (!self.active) {
                return;
            }

            rl.drawRectangle(
                self.position_x,
                self.position_y,
                self.width,
                self.height,
                rl.Color.yellow,
            );
        }
    };
}

pub fn Invader(comptime config: GameConfig) type {
    return struct {
        position_x: i32,
        position_y: i32,
        width: i32,
        height: i32,
        speed: i32,
        alive: bool,

        pub fn init(position_x: i32, position_y: i32) @This() {
            return .{
                .position_x = position_x,
                .position_y = position_y,
                .width = config.invader_width,
                .height = config.invader_height,
                .speed = config.invader_speed,
                .alive = true,
            };
        }

        pub fn draw(self: @This()) void {
            if (!self.alive) {
                return;
            }

            rl.drawRectangle(
                self.position_x,
                self.position_y,
                self.width,
                self.height,
                rl.Color.purple,
            );
        }

        pub fn update(self: *@This(), x: i32, y: i32) void {
            self.position_x += x;
            self.position_y += y;
        }
    };
}
