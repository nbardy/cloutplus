import regl from "regl";
const pyramid = require("./pyramid.glsl");

// NOTE: I use camelcase for functions
//  add undercore for values
function loadImage(url): Promise<HTMLImageElement> {
  const image = new Image();
  return new Promise((resolve) => {
    image.addEventListener("load", () => {
      resolve(image);
    });
    image.src = url;
  });
}

const clamp = (x, [low, high]) => {
  return Math.min(Math.max(x, low), high);
};

const nclamp = (x) => clamp(x, [0, 1]);

const smoothstep = (x) => {
  if (x <= 0) {
    return 1;
  } else if (x >= 1) {
    return 1;
  }

  return 3 * x * x - 2 * x * x * x;
};

const imgs_rdy = async () => {
  return true;
};

// 1000 MS
const S = 1000;

const w = window.innerWidth;
const h = window.innerHeight;

const PI = 3.14159265;

const sin = Math.sin;
const cos = Math.cos;
const pow = Math.pow;
const max = Math.max;
const min = Math.min;

// Draws image default centered at 0.5,0.5 anchor point,
// {args: x, y, r}
const drawImage = (ctx, img, args) => {
  const x = args.x;
  const y = args.y;
  const r = args.r;
  const anchor = args.anchor;

  const img_w = img.height;
  const img_h = img.width;

  // translate for anchor
  ctx.translate(x, y);
  if (r != null) {
    ctx.rotate(r);
  }
  const a_x = anchor ? anchor.x : 0.5;
  const a_y = anchor ? anchor.y : 0.5;

  // for trace
  // ctx.drawImage(bitclout_img, -img_w * a_x, -img_h * a_y);

  if (r != null) {
    ctx.rotate(-r);
  }
  ctx.translate(-x, -y);
};

const E = (tag, opts) => {
  const element = document.createElement(tag);
  Object.keys(opts).forEach((k) => {
    const v = opts[k].toString();
    element.setAttribute(k, v);
  });

  return element;
};

const renderLoop = (f) => {
  let running = true;
  let currentFrame = null;

  const loopf = () => {
    if (running === true) {
      f();
      currentFrame = requestAnimationFrame(loopf);
    }
  };
  loopf();

  const cancel = () => {
    if (currentFrame != null) {
      window.cancelAnimationFrame(currentFrame);
    }

    // relinquish control so that the render thread can complete and
    return currentFrame;
  };
  return { cancel };
};

(async () => {
  const canvas = document.getElementById("plate") as HTMLCanvasElement;
  const setSize = () => {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  };
  setSize();
  const stillT = 2.11;
  window.addEventListener("resize", setSize);

  // reglLib._refresh();
  // reglLib.poll();

  const reglLib = regl({ canvas });

  const firstT = Date.now();

  const ctx = canvas.getContext("2d");

  const drawTriangle = reglLib({
    // Shaders in regl are just strings.  You can use glslify or whatever you want
    // to define them.  No need to manually create shader objects.
    frag: pyramid,
    vert: `
    precision mediump float;
    attribute vec2 position;
    void main() {
      gl_Position = vec4(position, 0, 1);
    }`,

    attributes: {
      // Draw the whole screen
      position: reglLib.buffer([
        [1, 1],
        [1, -3],
        [-3, 1],
      ]),
    },

    uniforms: {
      // This defines the color of the triangle to be a dynamic variable
      stillT,
      iTime: () => {
        let to = (Date.now() - firstT) * 0.001;
        // to = 1.8;
        return to;
      },
      iMouse: reglLib.prop("mouse" as never),
      iResolution: [
        reglLib.context("drawingBufferWidth"),
        reglLib.context("drawingBufferHeight"),
      ],
      Dmax: 2,
    },

    // This tells regl the number of vertices to draw in this command
    count: 3,
  });

  let mouse = [0, 0];

  document.body.addEventListener("mousemove", (e) => {
    mouse = [e.pageX, e.pageY];
    e.pageX;
    e.pageY;
  });

  reglLib.frame(({ time }) => {
    // clear contents of the drawing buffer
    reglLib.clear({
      color: [0, 0, 0, 0],
      depth: 1,
    });

    // draw a triangle using the command defined above
    drawTriangle({ mouse });
  });

  // renderLoop(() => {
  //   const dt = Date.now() - firstT;
  //   console.log(dt);
  // });
})();
