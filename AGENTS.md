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

## Deployment runbook (velanera.co)

`velanera.co` is on **GoDaddy Website Builder (Airo)** — a closed platform with
**no cPanel / FTP / SSH**, so the custom React build cannot be hosted on GoDaddy.
Plan: host on **GitHub Pages** (repo is public → free) and point the GoDaddy
domain at it via DNS. GoDaddy browser login is blocked from cloud VMs (Akamai),
so DNS is changed via the **GoDaddy Domains API**.

Expected secrets (added via the Secrets panel; **only visible in a fresh run**):

- `GODADDY_API_KEY`, `GODADDY_API_SECRET` — Production key from
  developer.godaddy.com/keys (base `https://api.godaddy.com`, NOT OTE).
- `GH_PAGES_TOKEN` — GitHub fine-grained token with **Pages: Read/write** on
  `francescobattistel-arch/velanera` (needed because the default Actions token
  cannot *create* a Pages site).

Steps (confirm with the user before the DNS `PUT` — it repoints production):

1. Read-only auth test:
   `curl -sS -H "Authorization: sso-key $GODADDY_API_KEY:$GODADDY_API_SECRET" https://api.godaddy.com/v1/domains/velanera.co/records`
   (A 403 "ACCESS_DENIED" usually means the account has <10 domains — GoDaddy's
   DNS API limit. Fall back to manual DNS entry by the user.)
2. Enable Pages via API, then re-add the custom domain CNAME file:
   `curl -sS -X POST -H "Authorization: Bearer $GH_PAGES_TOKEN" -H "Accept: application/vnd.github+json" https://api.github.com/repos/francescobattistel-arch/velanera/pages -d '{"build_type":"workflow"}'`
   then recreate `public/CNAME` containing `velanera.co`, commit, and push to
   `main` to trigger `.github/workflows/deploy.yml`.
3. Point DNS at GitHub Pages:
   - `PUT https://api.godaddy.com/v1/domains/velanera.co/records/A/@` body:
     `[{"data":"185.199.108.153","ttl":600},{"data":"185.199.109.153","ttl":600},{"data":"185.199.110.153","ttl":600},{"data":"185.199.111.153","ttl":600}]`
   - `PUT https://api.godaddy.com/v1/domains/velanera.co/records/CNAME/www` body:
     `[{"data":"francescobattistel-arch.github.io","ttl":600}]`
   (same `sso-key` auth header; `Content-Type: application/json`)
4. Verify: `curl -I https://velanera.co` (200 from GitHub), then load the page
   and confirm CSS/JS/booking form. DNS + Pages SSL can take up to ~1 hour.
