pub usingnamespace @cImport({
    @cInclude("SDL2/SDL.h");
});

const std = @import("std");
const warn = std.debug.warn;

pub fn main() u8 {
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) != 0) {
        SDL_Log("failed to initialized SDL\n");
        return 1;
    }
    defer SDL_Quit();

    const win = SDL_CreateWindow("Hello World!", 100, 100, 640, 480, SDL_WINDOW_SHOWN);
    if (win == null) {
        SDL_Log("SDL_CreateWindow Error: ", SDL_GetError());
        SDL_Quit();
        return 1;
    }

    const ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (ren == null) {
        SDL_DestroyWindow(win);
        SDL_Log("SDL_CreateRenderer Error: ", SDL_GetError());
        SDL_Quit();
        return 1;
    }

    const imagePath = "/Users/dnewman/code/zig/wasm-test/assets/sky.bmp";
    const bmp = SDL_LoadBMP_RW(SDL_RWFromFile(imagePath, "rb"), 1);
    if (bmp == null) {
        SDL_DestroyRenderer(ren);
        SDL_DestroyWindow(win);
        SDL_Log("SDL_LoadBMP Error: ", SDL_GetError());
        SDL_Quit();
        return 1;
    }

    warn("hi\n", .{});
    SDL_Delay(3000);
    warn("bye\n", .{});

    return 0;
}
