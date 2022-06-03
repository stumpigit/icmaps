import svelte from "rollup-plugin-svelte";
import resolve from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";
import livereload from "rollup-plugin-livereload";
import { terser } from "rollup-plugin-terser";
import replace from "@rollup/plugin-replace";
import inject from "rollup-plugin-inject";
import json from "@rollup/plugin-json";
// library that helps you import in svelte with
// absolute paths, instead of
// import Component  from "../../../../components/Component.svelte";
// we will be able to say
// import Component from "components/Component.svelte";
import alias from "@rollup/plugin-alias";
import postcss from 'rollup-plugin-postcss'
import fs from "fs";

const production = !process.env.ROLLUP_WATCH;
const path = require("path");

// configure aliases for absolute imports
const aliases = alias({
  resolve: [".svelte", ".js"], //optional, by default this will just look for .js files or folders
  entries: [
    { find: "components", replacement: "src/components" },
    { find: "views", replacement: "src/views" },
    { find: "assets", replacement: "src/assets" },
  ],
});

const indexTemplate = `<!--

=========================================================
* ICMaps - v0.1.0 
=========================================================

* Product Page: https://www.icmaps.org
* Copyright 2022 Christoph Suter (https://www.suter-burri.ch)
* Licensed under MIT (https://github.com/stumpigit/icmaps/blob/main/LICENSE)

* Based on Tailwind Starter Kit by Creative Tim
* Tailwind Starter Kit Page: https://www.creative-tim.com/learning-lab/tailwind-starter-kit/presentation

* Coded by Christoph Suter

=========================================================

* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

-->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />

    <link rel="shortcut icon" href="/favicon.ico" />
    <link rel="apple-touch-icon" sizes="76x76" href="/apple-icon.png" />
    <link rel="stylesheet" href="/build/bundle.css" />
    <link
      rel="stylesheet"
      href="/assets/vendor/@fortawesome/fontawesome-free/css/all.min.css"
    />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.14.1/css/ol.css" type="text/css">
    <link rel="stylesheet" href="/assets/styles/tailwind.css" />
    <title>ICMaps</title>

    <script>
      if (process === undefined) {
        var process = { env: {<<process-env-status>>} };
      }
    </script>
    <script defer src="/build/bundle.js"></script>
  </head>

  <body class="text-blueGray-700 antialiased">
    <noscript>
      <strong
        >We're sorry but notus-svelte doesn't work properly without
        JavaScript enabled. Please enable it to continue.</strong
      >
    </noscript>
    <div id="app"></div>
  </body>
</html>
`;

if (production) {
  fs.writeFileSync(
    "./public/index.html",
    indexTemplate
      .replace("<<process-env-status>>", "PRODUCTION: true")
      .replace(/<<live-preview-link>>/g, "/notus-svelte")
  );
  fs.writeFileSync(
    "./public/200.html",
    indexTemplate
      .replace("<<process-env-status>>", "PRODUCTION: true")
      .replace(/<<live-preview-link>>/g, "/notus-svelte")
  );
  fs.writeFileSync(
    "./public/404.html",
    indexTemplate
      .replace("<<process-env-status>>", "PRODUCTION: true")
      .replace(/<<live-preview-link>>/g, "/notus-svelte")
  );
} else {
  fs.writeFileSync(
    "./public/index.html",
    indexTemplate
      .replace("<<process-env-status>>", "")
      .replace(/<<live-preview-link>>/g, "")
  );
  fs.writeFileSync(
    "./public/200.html",
    indexTemplate
      .replace("<<process-env-status>>", "")
      .replace(/<<live-preview-link>>/g, "")
  );
  fs.writeFileSync(
    "./public/404.html",
    indexTemplate
      .replace("<<process-env-status>>", "")
      .replace(/<<live-preview-link>>/g, "")
  );
}
function initCanisterIds() {
  let localCanisters, localIiCanister, prodCanisters, canisters;
  try {
    localCanisters = require(path.resolve(
      "..",
      "..",
      ".dfx",
      "local",
      "canister_ids.json"
    ));
  } catch (error) {
    console.log("No local canister_ids.json found. Continuing production:" + error);
  }
  try {
    localIiCanister = require(path.resolve(
      "..",
      "..",
      "internet-identity",
      ".dfx",
      "local",
      "canister_ids.json"
    ));
  } catch (error) {
    console.log(
      "No local internet-identity canister_ids.json found. Continuing production"
    );
  }
  try {
    prodCanisters = require(path.resolve("..", "..", "canister_ids.json"));
  } catch (error) {
    console.log("No production canister_ids.json found. Continuing with local");
  }

  const network =
    process.env.DFX_NETWORK ||
    (process.env.NODE_ENV === "production" ? "ic" : "local");

  console.log(network);

  const canisterIds =
    network === "local"
      ? { ...(localCanisters || {}), ...(localIiCanister || {}) }
      : prodCanisters;

  return { canisterIds, network };
}
const { canisterIds, network } = initCanisterIds();
function serve() {
  let server;

  function toExit() {
    if (server) server.kill(0);
  }

  return {
    writeBundle() {
      if (server) return;
      server = require("child_process").spawn(
        "npm",
        ["run", "start", "--", "--dev"],
        {
          stdio: ["ignore", "inherit", "inherit"],
          shell: true,
        }
      );

      process.on("SIGTERM", toExit);
      process.on("exit", toExit);
    },
  };
}

export default {
  input: "src/main.js",
  output: {
    sourcemap: true,
    format: "iife",
    name: "app",
    file: "public/build/bundle.js",
  },
  plugins: [
    svelte({
      // enable run-time checks when not in production
      dev: !production,
      // we'll extract any component CSS out into
      // a separate file - better for performance
      css: (css) => {
        css.write("bundle.css");
      },
    }),
    postcss({
      extract: 'bundle.css',
      sourceMap: true,
      minimize: true,
    }),

    // If you have external dependencies installed from
    // npm, you'll most likely need these plugins. In
    // some cases you'll need additional configuration -
    // consult the documentation for details:
    // https://github.com/rollup/plugins/tree/master/packages/commonjs
    resolve({
      preferBuiltins: false,
      browser: true,
      dedupe: ["svelte"],
    }),
    replace(
      Object.assign(
        {
          "process.env.DFX_NETWORK": JSON.stringify(network),
          "process.env.NODE_ENV": JSON.stringify(
            production ? "production" : "development"
          ),
        },
        ...Object.keys(canisterIds)
          .filter((canisterName) => canisterName !== "__Candid_UI")
          .map((canisterName) => ({
            ["process.env." + canisterName.toUpperCase() + "_CANISTER_ID"]:
              JSON.stringify(canisterIds[canisterName][network]),
          }))
      )
    ),
    commonjs(),
    inject({
      Buffer: ["buffer", "Buffer"],
      process: "process/browser",
    }),
    json(),
    // In dev mode, call `npm run start` once
    // the bundle has been generated
    !production && serve(),

    // Watch the `public` directory and refresh the
    // browser on changes when not in production
    !production && livereload("public"),

    // If we're building for production (npm run build
    // instead of npm run dev), minify
    production && terser(),

    // for absolut imports
    // i.e., instead of
    // import Component  from "../../../../components/Component.svelte";
    // we will be able to say
    // import Component from "components/Component.svelte";
    aliases,
  ],
  watch: {
    clearScreen: false,
  },
};