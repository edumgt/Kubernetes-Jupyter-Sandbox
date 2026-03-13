import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import { quasar, transformAssetUrls } from "@quasar/vite-plugin";

export default defineConfig({
  plugins: [
    vue({
      template: { transformAssetUrls },
    }),
    quasar({
      sassVariables: "src/quasar-variables.sass",
    }),
  ],
  server: {
    host: "0.0.0.0",
    port: 9000,
  },
  preview: {
    host: "0.0.0.0",
    port: 4173,
  },
});
