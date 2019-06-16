// TODO: investigate code generating these stubs
extern "renderer" fn log(msg_ptr: [*]const u8, msg_len: i32) void;
extern "renderer" fn registerSprite(msg_ptr: [*]const u8, msg_len: i32, width: i32, height: i32, cols: i32, count: i32, animationSpeed: f32) i32;
extern "renderer" fn loadRegisteredSprites() void;
extern "renderer" fn startGameLoop() void;
extern "renderer" fn addToScene(id: i32) void;
extern "renderer" fn removeFromScene(id: i32) void;
extern "renderer" fn updateSprite(id: i32, scale_x: f32, x: f32, y: f32) void;

const std = @import("std");
const fmt = std.fmt;

const idle_asset = "npc_bureaucrat_arms_02_glasses_none_hair_02_legs_02_necklace_none_tie_02_torso_02_x1_idle1_png_1354833004.png";
const walk_asset = "npc_bureaucrat_arms_02_glasses_none_hair_02_legs_02_necklace_none_tie_02_torso_02_x1_walk1_png_1354832999.png";

const allocator = std.heap.wasm_allocator;

const player = struct {
    var x: f32 = 300;
    var y: f32 = 0;
    var vx: f32 = 0;
    var vy: f32 = 0;

    var facing: f32 = 1;
    var sprite: i32 = -1;
};

const sprites = struct {
    var idle: i32 = undefined;
    var walk: i32 = undefined;
};

export fn init() i32 {
    var msg = "zig init";
    log(&msg, msg.len);

    sprites.idle = registerSprite(&idle_asset, idle_asset.len, 97, 91, 57, 10, 0.1);
    sprites.walk = registerSprite(&walk_asset, walk_asset.len, 97, 91, 8, 8 * 3, 0.6);

    loadRegisteredSprites();
    return 45;
}

export fn onKey(key_code: c_int, key_down: bool) void {
    switch (key_code) {
        65 => left(key_down), // a
        68 => right(key_down), // d
        32 => jump(key_down), // space
        else => {},
    }
}

fn left(key_down: bool) void {
    if (key_down) {
        player.vx = -5;
        player.facing = -1;
    } else {
        if (player.vx < 0) {
            player.vx = 0;
        }
    }
}

fn right(key_down: bool) void {
    if (key_down) {
        player.vx = 5;
        player.facing = 1;
    } else {
        if (player.vx > 0) {
            player.vx = 0;
        }
    }
}

fn jump(key_down: bool) void {
    if (key_down) {
        player.vy = -10;
    }
}

export fn spritesLoaded() void {
    startGameLoop();
}

export fn tick(delta: f32) void {
    player.x += player.vx;
    player.y += player.vy;
    player.y = if (player.y > 500) 500 else player.y;
    player.vy = player.vy + 0.5 * delta;

    const desiredSprite = if (player.vx == 0) sprites.idle else sprites.walk;

    if (player.sprite != desiredSprite) {
        if (player.sprite != -1) {
            removeFromScene(player.sprite);
        }
        player.sprite = desiredSprite;
        addToScene(player.sprite);
    }

    updateSprite(player.sprite, player.facing, player.x, player.y);
}
