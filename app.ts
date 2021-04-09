const regl = require("regl")();

const introScene = require("render.glsl");
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

////////////////////////////////////////////////////////////////////////////////////////
/// Congrats on reading the source code. The first two coin owners of
/// bitcloutgold to post a 🤖 on their account, will get a machine learning
/// 🤖 trained on their account at no extra cost!!! You must own at least one whole coin
// and make a post including a 🤖.
//
/// Bitcloutgold is super alpha. I'm building give me space mother fuckers.
////////////////////////////////////////////////////////////////////////////////////////

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
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;

  const firstT = Date.now();

  const ctx = canvas.getContext("2d");
  await imgs_rdy();

  renderScene();

  renderLoop(() => {
    const dt = Date.now() - firstT;
    draw(ctx, dt);
  });
})();
