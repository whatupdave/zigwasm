import {
  Application,
  BaseTexture,
  Rectangle,
  AnimatedSprite,
  Texture,
  Loader
} from "pixi.js";
import { ZigExports } from "./index";

export function createRenderer() {
  const activeKeys: { [keyCode: number]: boolean } = {};
  const app = new Application();
  let exports: ZigExports = null;
  const registeredSprites: { path: string; sprite: AnimatedSprite }[] = [];

  function getString(ptr: number, len: number) {
    const slice = exports.memory.buffer.slice(ptr, ptr + len);
    const textDecoder = new TextDecoder();
    return textDecoder.decode(slice);
  }

  function handleKey(callback: ZigExports["onKey"], keydown: boolean) {
    return (e: KeyboardEvent) => {
      e.preventDefault();
      // ignore event if we've already handled this key
      if (activeKeys[e.keyCode] !== keydown) {
        activeKeys[e.keyCode] = keydown;
        callback(e.keyCode, keydown);
      }
    };
  }

  // these functions are callable from zig
  return {
    init(zigExports: ZigExports) {
      exports = zigExports;

      document.body.appendChild(app.view);
      app.renderer.autoDensity = true;
      app.renderer.view.style.position = "absolute";
      app.renderer.view.style.display = "block";
      app.renderer.resize(window.innerWidth, window.innerHeight);

      document.addEventListener("keydown", handleKey(exports.onKey, true));
      document.addEventListener("keyup", handleKey(exports.onKey, false));

      console.log(exports.init());
    },

    log(msg_ptr: number, msg_len: number) {
      console.log(getString(msg_ptr, msg_len));
    },

    registerSprite(
      path_ptr: number,
      path_len: number,
      width: number,
      height: number,
      cols: number,
      count: number,
      animationSpeed: number
    ): number {
      const path = getString(path_ptr, path_len);
      let textureArray = [];
      let baseTexture = BaseTexture.from(path);
      for (let i = 0; i < count; i++) {
        let rectangle = new Rectangle(
          (i % cols) * width,
          Math.floor(i / cols) * height,
          width,
          height
        );
        let frame = new Texture(baseTexture, rectangle);
        textureArray.push(frame);
      }
      const sprite = new AnimatedSprite(textureArray);
      sprite.animationSpeed = animationSpeed;
      sprite.anchor.x = 0.5;

      return registeredSprites.push({ path, sprite }) - 1;
    },

    loadRegisteredSprites() {
      Loader.shared
        .add(registeredSprites.map(a => a.path))
        .load(() => exports.spritesLoaded());
    },

    startGameLoop() {
      app.ticker.add(delta => exports.tick(delta));
    },

    addToScene(spriteId: number) {
      app.stage.addChild(registeredSprites[spriteId].sprite);
      registeredSprites[spriteId].sprite.play();
      console.log("added", registeredSprites[spriteId]);
    },

    removeFromScene(spriteId: number) {
      registeredSprites[spriteId].sprite.stop();
      app.stage.removeChild(registeredSprites[spriteId].sprite);
      console.log("removed", registeredSprites[spriteId]);
    },

    updateSprite(spriteId: number, scaleX: number, x: number, y: number) {
      const sprite = registeredSprites[spriteId].sprite;
      sprite.scale.x = scaleX;
      sprite.x = x;
      sprite.y = y;
    }
  };
}
