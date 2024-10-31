import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: "dist",
    chunkSizeWarningLimit: 1600,
  },
  server: {
    port: 3000,
  },
  esbuild: {
    charset: 'utf8'
  }
});