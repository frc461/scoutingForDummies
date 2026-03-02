const esbuild = require("esbuild");
const { sassPlugin } = require("esbuild-sass-plugin");

const watch = process.argv.includes("--watch");

/** @type {import("esbuild").BuildOptions} */
const sharedOptions = {
  bundle: true,
  minify: !watch,
  sourcemap: watch ? "inline" : false,
  logLevel: "info",
};

async function build() {
  // ── JavaScript ────────────────────────────────────────────────────────────
  const jsCtx = await esbuild.context({
    ...sharedOptions,
    entryPoints: ["assets/js/index.js"],
    outfile: "public/assets/app.js",
  });

  // ── CSS / SCSS ─────────────────────────────────────────────────────────────
  // The sass plugin resolves bare ~bootstrap/... imports via node_modules.
  const cssCtx = await esbuild.context({
    ...sharedOptions,
    entryPoints: ["assets/css/index.scss"],
    outfile: "public/assets/app.css",
    plugins: [
      sassPlugin({
        // Allow @import "bootstrap/scss/..." to resolve from node_modules
        loadPaths: ["node_modules"],
        // Suppress deprecation warnings that originate inside dependencies
        // (Bootstrap 5 still uses the legacy Sass @import API)
        quietDeps: true,
      }),
    ],
  });

  if (watch) {
    await jsCtx.watch();
    await cssCtx.watch();
    console.log("[esbuild] watching for changes…");
  } else {
    await jsCtx.rebuild();
    await cssCtx.rebuild();
    await jsCtx.dispose();
    await cssCtx.dispose();
    console.log("[esbuild] build complete");
  }
}

build().catch((err) => {
  console.error(err);
  process.exit(1);
});
