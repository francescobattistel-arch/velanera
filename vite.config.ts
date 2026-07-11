import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// Relative base so the site works both on a custom domain (velanera.co)
// and on the GitHub Pages project URL (/velanera/).
export default defineConfig({
  base: './',
  plugins: [react(), tailwindcss()],
})
