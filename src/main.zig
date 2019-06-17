// TODO: investigate code generating these stubs
extern "renderer" fn addToScene(sprite_id: i32) void;
extern "renderer" fn addAsset(msg_ptr: [*]const u8, msg_len: i32) i32;
extern "renderer" fn loadAssets() void;
extern "renderer" fn log(msg_ptr: [*]const u8, msg_len: i32) void;
extern "renderer" fn registerAnimatedSprite(id: i32, width: i32, height: i32, cols: i32, count: i32, animationSpeed: f32) i32;
extern "renderer" fn registerSprite(id: i32) i32;
extern "renderer" fn removeFromScene(sprite_id: i32) void;
extern "renderer" fn startGameLoop() void;
extern "renderer" fn startAnimation(sprite_id: i32) void;
extern "renderer" fn stopAnimation(sprite_id: i32) void;
extern "renderer" fn updateSpriteTint(id: i32, tint: u32) void;
extern "renderer" fn updateSpriteXY(id: i32, x: f32, y: f32) void;
extern "renderer" fn updateSpriteXYScaleXY(id: i32, x: f32, y: f32, scale_x: f32, scale_y: f32) void;

const std = @import("std");
const fmt = std.fmt;
const math = std.math;
const DefaultPrng = std.rand.DefaultPrng;

const allocator = std.heap.wasm_allocator;

const assetPaths = struct {
    const dirt = "dirt.png";
    const grass_block_side = "grass_block_side.png";
    const sky = "sky.png";
    const idle = "npc_bureaucrat_arms_02_glasses_none_hair_02_legs_02_necklace_none_tie_02_torso_02_x1_idle1_png_1354833004.png";
    const walk = "npc_bureaucrat_arms_02_glasses_none_hair_02_legs_02_necklace_none_tie_02_torso_02_x1_walk1_png_1354832999.png";
};

const assets = struct {
    var dirt: i32 = undefined;
    var grass_block_side: i32 = undefined;
    var sky: i32 = undefined;
    var idle: i32 = undefined;
    var walk: i32 = undefined;
};

const sprites = struct {
    var idle: i32 = undefined;
    var walk: i32 = undefined;
};

var level: [1024][1024]i32 = undefined;
var levelSprites: [1024][1024]i32 = undefined;
const playerWidth = 97;
const playerHeight = 91;

const player = struct {
    const collision_points = [_][2]usize{[_]usize{ 0, playerHeight / 2 }};

    var x: f32 = 300;
    var y: f32 = 0;
    var vx: f32 = 0;
    var vy: f32 = 0;

    var facing: f32 = 1;
    var sprite: i32 = -1;
};

const block_size: usize = 32;
const half_block_size: usize = block_size / 2;
const block_size_f = @intToFloat(f32, block_size);

export fn init() void {
    var msg = "zig init";
    log(&msg, msg.len);

    assets.dirt = addAsset(&assetPaths.dirt, assetPaths.dirt.len);
    assets.grass_block_side = addAsset(&assetPaths.grass_block_side, assetPaths.grass_block_side.len);
    assets.sky = addAsset(&assetPaths.sky, assetPaths.sky.len);
    assets.idle = addAsset(&assetPaths.idle, assetPaths.idle.len);
    assets.walk = addAsset(&assetPaths.walk, assetPaths.walk.len);

    loadAssets();
}

export fn loadAssetsCallback() void {
    sprites.idle = registerAnimatedSprite(assets.idle, playerWidth, playerHeight, 10, 57, 0.1);
    sprites.walk = registerAnimatedSprite(assets.walk, playerWidth, playerHeight, 8, 8 * 3, 0.6);

    const sky_sprite = registerSprite(assets.sky);
    addToScene(sky_sprite);
    updateSpriteXY(sky_sprite, 900, 550);

    buildLevel();

    var x: usize = 0;
    // while (x < 100) : (x += 1) {
    //     const sprite_id = registerSprite(assets.grass_block_side);
    //     addToScene(sprite_id);
    //     updateSpriteXY(sprite_id, x * block_size, 378);
    // }

    var y: usize = 0;
    while (y < 24) : (y += 1) {
        x = 0;
        while (x < 100) : (x += 1) {
            const block = level[y][x];
            if (block > 0) {
                const sprite_id = registerSprite(assets.dirt);
                addToScene(sprite_id);
                levelSprites[y][x] = sprite_id;
                updateSpriteXY(sprite_id, @intToFloat(f32, x) * @intToFloat(f32, block_size), @intToFloat(f32, y) * @intToFloat(f32, block_size));
            }
        }
    }

    startGameLoop();
}

var previousBlockDetection: i32 = 0;

export fn tick(delta: f32) void {
    player.x += player.vx;
    player.y += player.vy;
    player.vy = player.vy + 0.5 * delta;

    player.y = @mod(player.y, 1000);

    // collision detection
    var i: usize = 0;
    while (i < player.collision_points.len) : (i += 1) {
        const pt = player.collision_points[i];
        const ptX = @intToFloat(f32, pt[0]);
        const ptY = @intToFloat(f32, pt[1]);
        const x = @floatToInt(usize, math.floor((player.x + ptX) / block_size_f));
        const y = @floatToInt(usize, math.floor((player.y + ptY) / block_size_f) + 1);

        // if our collision point is inside a block, move the player out
        if (level[y][x] > 0) {
            if (player.vy > 0) {
                // player is falling so raise them up
                player.y = @intToFloat(f32, y * block_size - half_block_size - pt[1] + 1);
            }
            player.vy = 0;
        }
    }

    const desiredSprite = if (player.vx == 0) sprites.idle else sprites.walk;

    if (player.sprite != desiredSprite) {
        if (player.sprite != -1) {
            stopAnimation(player.sprite);
            removeFromScene(player.sprite);
        }
        player.sprite = desiredSprite;
        addToScene(player.sprite);
        startAnimation(player.sprite);
    }

    updateSpriteXYScaleXY(player.sprite, player.x, player.y, player.facing, 1);
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

fn buildLevel() void {
    var r = DefaultPrng.init(42);

    var x: usize = 0;
    while (x < level.len) : (x += 1) {
        var y: usize = 0;
        while (y < level.len) : (y += 1) {
            level[y][x] = 0;

            const s = r.random.float(f32);
            if (s < 0.1) {
                level[y][x] = 1;
            }
        }
    }
}
