# Velanera Concierge API (OpenAI GPT-5.5)

Cloudflare Worker proxy. The static site and iOS app never hold `OPENAI_API_KEY`.

## Endpoints

- `GET /health` → `{"status":"ok"}`
- `POST /chat` → GPT-5.5 concierge JSON (`reply`, `model`, …)

## Required GitHub Actions secrets

| Secret name | Where to create it | Why it is needed |
|---|---|---|
| `OPENAI_API_KEY` | GitHub → Settings → Secrets and variables → Actions → Secrets (from [platform.openai.com/api-keys](https://platform.openai.com/api-keys)) | Worker calls OpenAI GPT-5.5. Bound into the Worker with `wrangler secret put` — never hardcoded. |
| `CLOUDFLARE_API_TOKEN` | GitHub → Settings → Secrets and variables → Actions → Secrets (from [dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens), permission **Edit Cloudflare Workers**) | Authenticates `wrangler deploy` from GitHub Actions. |
| `CLOUDFLARE_ACCOUNT_ID` | GitHub → Settings → Secrets and variables → Actions → Secrets (Cloudflare dashboard → Workers → Account ID) | Selects which Cloudflare account receives the Worker. |

No API key belongs in the repo, Pages bundle, or iOS binary.

## Deploy

Actions → **Deploy Concierge API** (or push to `main` under `workers/concierge/**`).

The workflow:

1. Puts `OPENAI_API_KEY` into the Worker environment as a secret
2. Deploys the Worker
3. Verifies `GET /health` and `POST /chat`
4. Rebuilds GitHub Pages with `conciergeApiBase` set (removes demo mode)

## Local

```bash
cd workers/concierge
npx wrangler secret put OPENAI_API_KEY
npx wrangler dev
```
