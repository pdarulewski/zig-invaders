const rl = @import("raylib");
const game = @import("game.zig");

pub fn main() void {
    const screenWidth = 800;
    const screenHeight = 600;

    rl.initWindow(screenWidth, screenHeight, "Zig Invaders");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const gameConfig: game.GameConfig = .{
        .screen_width = 0,
        .screen_height = 0,

        .player_width = 50,
        .player_height = 30,
        .player_start_x = screenWidth / 2 - 25,
        .player_start_y = screenHeight - 60,
        .player_speed = 5.0,

        .max_bullets = 3,
        .bullet_width = 4,
        .bullet_height = 10,
        .bullet_speed = 10,

        .shield_start_x = 0,
        .shield_y = 0,
        .shield_width = 0,
        .shield_height = 0,
        .shield_spacing = 0,

        .invader_start_x = 100,
        .invader_start_y = 50,
        .invader_width = 40,
        .invader_height = 30,
        .invader_speed = 20,

        .invader_spacing_x = 60,
        .invader_spacing_y = 40,
        .invader_cols = 11,
        .invader_rows = 5,
        .invader_move_delay = 30,
        .invader_drop_distance = 20,
    };

    const PlayerType = game.Player(gameConfig);
    var player: PlayerType = PlayerType.init();

    const InvaderType = game.Invader(gameConfig);
    var invaders: [gameConfig.invader_rows][gameConfig.invader_cols]InvaderType = undefined;

    for (&invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x: i32 = gameConfig.invader_start_x + @as(i32, @intCast(j)) * gameConfig.invader_spacing_x;
            const y: i32 = gameConfig.invader_start_y + @as(i32, @intCast(i)) * gameConfig.invader_spacing_y;

            invader.* = InvaderType.init(x, y);
        }
    }

    var move_timer: i32 = 0;
    var invader_direction: i32 = 1;

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        player.update();

        move_timer += 1;
        if (move_timer >= gameConfig.invader_move_delay) {
            move_timer = 0;

            var edge_hit = false;

            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        const next_x = invader.position_x + gameConfig.invader_speed * invader_direction;
                        if (next_x < 0 or next_x + invader.width > screenWidth) {
                            edge_hit = true;
                            break;
                        }
                    }
                }

                if (edge_hit) break;
            }

            if (edge_hit) {
                invader_direction += -1;
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(0, gameConfig.invader_drop_distance);
                    }
                }
            } else {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(gameConfig.invader_speed * invader_direction, 0);
                    }
                }
            }
        }

        player.draw();

        for (&invaders) |*row| {
            for (row) |*invader| {
                invader.draw();
            }
        }

        rl.drawText("Zig Invaders", 300, 250, 40, rl.Color.green);
    }
}
