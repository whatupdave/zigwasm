import {
  Application,
  BaseTexture,
  Rectangle,
  AnimatedSprite,
  Texture,
  Loader,
  Sprite
} from "pixi.js";
import { ZigExports } from "./index";

export function createRenderer() {
  const activeKeys: { [keyCode: number]: boolean } = {};
  const app = new Application();
  let exports: ZigExports = null;

  // keeps track of path strings so assets can be referenced by number
  const registeredAssets: string[] = [];

  // keeps track of created sprites so they can be referenced by number
  const registeredSprites: Array<Sprite | AnimatedSprite> = [];

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

      exports.init();
    },

    log(msg_ptr: number, msg_len: number) {
      console.log(getString(msg_ptr, msg_len));
    },

    addAsset(ptr: number, len: number): number {
      const path = getString(ptr, len);
      const assetId = registeredAssets.push(path) - 1;
      Loader.shared.add(path);
      return assetId;
    },

    loadAssets() {
      Loader.shared.load(exports.loadAssetsCallback);
    },

    registerAnimatedSprite(
      assetId: number,
      width: number,
      height: number,
      cols: number,
      count: number,
      animationSpeed: number
    ): number {
      let textureArray = [];
      let baseTexture =
        Loader.shared.resources[registeredAssets[assetId]].texture.baseTexture;
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

      return registeredSprites.push(sprite) - 1;
    },

    registerSprite(assetId: number, width: number, height: number): number {
      const sprite = new Sprite(
        Loader.shared.resources[registeredAssets[assetId]].texture
      );

      return registeredSprites.push(sprite) - 1;
    },

    startGameLoop() {
      app.ticker.add(delta => exports.tick(delta));
    },

    addToScene(spriteId: number) {
      app.stage.addChild(registeredSprites[spriteId]);
    },

    removeFromScene(spriteId: number) {
      app.stage.removeChild(registeredSprites[spriteId]);
    },

    startAnimation(spriteId: number) {
      (registeredSprites[spriteId] as AnimatedSprite).play();
    },

    stopAnimation(spriteId: number) {
      (registeredSprites[spriteId] as AnimatedSprite).stop();
    },

    updateSpriteXY(spriteId: number, x: number, y: number) {
      const sprite = registeredSprites[spriteId];
      sprite.x = x;
      sprite.y = y;
    },
    updateSpriteXYScaleXY(
      spriteId: number,
      x: number,
      y: number,
      scaleX: number,
      scaleY: number
    ) {
      const sprite = registeredSprites[spriteId];
      sprite.scale.x = scaleX;
      sprite.scale.y = scaleY;
      sprite.x = x;
      sprite.y = y;
    }
  };
}
