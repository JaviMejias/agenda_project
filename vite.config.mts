import { defineConfig } from "vite";
import ViteRails from "vite-plugin-rails";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [
    tailwindcss(),
    ViteRails({
      fullReload: {
        additionalPaths: [
          "config/routes.rb",
          "app/views/**/*",
          "app/helpers/**/*",
          "app/assets/stylesheets/**/*"
        ],
        delay: 300,
      },
    }),
  ],
});
