# Velanera — Restaurant & Lounge

Official website for **Velanera**, a Mediterranean restaurant & lounge.
Single-page site with sections: **Home · Lounge · Booking · Contacts**.

Built with **Vite + React + TypeScript + Tailwind CSS v4**.

## Development

```bash
npm install     # install dependencies
npm run dev     # start dev server (http://localhost:5173)
npm run build   # type-check + production build to dist/
npm run preview # preview the production build
npm run lint    # run ESLint
```

## Deployment (GitHub Pages → velanera.co)

Pushing to `main` triggers `.github/workflows/deploy.yml`, which builds the site
and publishes `dist/` to GitHub Pages. The custom domain is set via `public/CNAME`
(`velanera.co`).

To point the domain in GoDaddy (DNS → Manage DNS for `velanera.co`):

- `A` `@` → `185.199.108.153`
- `A` `@` → `185.199.109.153`
- `A` `@` → `185.199.110.153`
- `A` `@` → `185.199.111.153`
- `CNAME` `www` → `francescobattistel-arch.github.io`

Then enable Pages in the repo settings (Source: GitHub Actions) and set the
custom domain to `velanera.co`.

## Notes

- The booking form is currently client-side only (shows a confirmation and offers
  a pre-filled `mailto:` to `reservations@velanera.co`). Wire it to a form backend
  or reservation provider (e.g. Formspree, OpenTable, Resy) when ready.
- Placeholder content (menu, address, phone, hours) should be replaced with real
  details.
