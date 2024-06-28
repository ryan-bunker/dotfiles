// vite.config.js
import { resolve } from "path";
import { defineConfig } from "vite";

export default defineConfig({
  esbuild: {
    supported: {
      "top-level-await": true,
    },
  },
  build: {
    lib: {
      entry: resolve(__dirname, "main.ts"),
      formats: ["es"],
    },
    cssTarget: "chrome61",
    rollupOptions: {
      // make sure to externalize deps that shouldn't be bundled
      // into your library
      external: [/resource:\/\/.*/, /gi:\/\/.*/],
    },
  },
});
