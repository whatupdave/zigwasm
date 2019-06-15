let webgl2Supported = typeof WebGL2RenderingContext !== "undefined";
let webgl_fallback = false;
let gl;

let webglOptions = {
  alpha: true,
  antialias: true,
  depth: 32,
  failIfMajorPerformanceCaveat: false,
  powerPreference: "default",
  premultipliedAlpha: true,
  preserveDrawingBuffer: true,
  stencil: true
};

if (webgl2Supported) {
  gl = $webgl.getContext("webgl2", webglOptions);
  if (!gl) {
    throw new Error("The browser supports WebGL2, but initialization failed.");
  }
}
if (!gl) {
  webgl_fallback = true;
  gl = $webgl.getContext("webgl", webglOptions);

  if (!gl) {
    throw new Error("The browser does not support WebGL");
  }

  let vaoExt = gl.getExtension("OES_vertex_array_object");
  if (!ext) {
    throw new Error(
      "The browser supports WebGL, but not the OES_vertex_array_object extension"
    );
  }
  (gl.createVertexArray = vaoExt.createVertexArrayOES),
    (gl.deleteVertexArray = vaoExt.deleteVertexArrayOES),
    (gl.isVertexArray = vaoExt.isVertexArrayOES),
    (gl.bindVertexArray = vaoExt.bindVertexArrayOES),
    (gl.createVertexArray = vaoExt.createVertexArrayOES);
}
if (!gl) {
  throw new Error("The browser supports WebGL, but initialization failed.");
}

var webgl = { gl };
