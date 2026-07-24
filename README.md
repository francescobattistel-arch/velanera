# Velanera — Restaurant & Lounge

Official website for **Velanera**, a Mediterranean restaurant & lounge.
Single-page site with sections: **Home · Lounge · Booking · Contacts**.

Built with **Vite + React + TypeScript + Tailwind CSS v4**. Installable as a
**Progressive Web App** (standalone / Home Screen).

## Development

```bash
npm install     # install dependencies
npm run dev     # start dev server (http://localhost:5173)
npm run build   # type-check + production build to dist/
npm run preview # preview the production build (required to test the service worker)
npm run lint    # run ESLint
npm run pwa:icons  # regenerate icons/splash from public/favicon.png
```

## Install on iPhone (Add to Home Screen)

1. Open **https://velanera.co** in **Safari** (not Chrome/in-app browsers).
2. Tap the **Share** button.
3. Tap **Add to Home Screen**.
4. Confirm the name **Velanera** and tap **Add**.
5. Launch from the Home Screen icon — the site opens fullscreen (standalone),
   with a black status bar.

Offline: the app shell and critical assets are cached by the service worker.
The booking `mailto:` flow still opens Mail as usual.

## Progressive Web App

- Web app manifest + Workbox service worker via `vite-plugin-pwa`
- Icons: `public/icons/` (192 / 512, any + maskable) and Apple touch icons
- iOS splash screens: `public/splash/`
- Theme / background: `#000000`

### Web Push (optional scaffold)

Push is **scaffolded** but inactive until you configure VAPID keys and a sender:

1. `npx web-push generate-vapid-keys`
2. Copy `.env.example` → `.env` and set `VITE_VAPID_PUBLIC_KEY=<public key>`
3. Keep the **private** key on a server; use that server to call `web-push` and
   store subscriptions from `subscribeToPush()` in `src/lib/push.ts`
4. Service worker push handlers live in `public/push-sw.js`

Without `VITE_VAPID_PUBLIC_KEY`, push helpers no-op. On iOS, Web Push only works
for Home Screen–installed PWAs (iOS 16.4+), not in regular Safari tabs.

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
