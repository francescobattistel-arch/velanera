# AGENTS.md

## Cursor Cloud specific instructions

Velanera is the marketing/booking website for a restaurant & lounge. It is a
single-page **Vite + React + TypeScript + Tailwind CSS v4** app (no backend).
Sections: Home, Lounge, Booking, Contacts.

Standard commands are in `README.md` and `package.json` scripts (`dev`, `build`,
`preview`, `lint`). Notes that aren't obvious:

- **Dev server**: `npm run dev` (Vite, default port 5173). Hot reload is on.
- **Booking form is frontend-only**: it does not send anything server-side; it
  renders a confirmation and builds a `mailto:` to `reservations@velanera.co`.
  Any "make booking work" task needs a real backend/provider (Formspree,
  OpenTable, Resy, etc.).
- **Deployment**: pushing to `main` runs `.github/workflows/deploy.yml`
  (GitHub Pages). Repo Settings → Pages must have Source = "GitHub Actions".
  The custom domain lives in `public/CNAME` (`velanera.co`) — do not delete it or
  Pages drops the custom domain on each deploy.
- **Vite `base` is `'./'`** (relative) so the build works on both the Pages
  project URL and the `velanera.co` custom domain. Don't hardcode absolute asset
  paths.
- **ESLint 10 flat config**: the React Hooks flat preset is referenced as
  `reactHooks.configs.flat['recommended-latest']` (the top-level
  `configs['recommended-latest']` is legacy eslintrc format and will crash lint).
- Menu, address, phone, hours, and socials are placeholders — replace with real
  content before launch.
