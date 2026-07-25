# Velanera Concierge API (OpenAI)

GitHub Pages is static — the browser **must not** hold an OpenAI key. This Cloudflare Worker is the server-side proxy that calls GPT and returns concierge replies.

## Why this exists

- Web prototype + future iOS app → `POST /concierge/chat`
- Worker attaches `OPENAI_API_KEY` and calls OpenAI (`gpt-4.1` by default)
- Matches `ios/Velanera/.../OpenAIIntegrationNotes.swift`

## One-time setup

1. Create a free [Cloudflare](https://dash.cloudflare.com) account.
2. Install Wrangler and log in:

```bash
cd workers/concierge
npx wrangler login
npx wrangler secret put OPENAI_API_KEY
npx wrangler deploy
```

3. Copy the worker URL (e.g. `https://velanera-concierge.<account>.workers.dev`).
4. In the GitHub repo → **Settings → Secrets and variables → Actions → Variables**:
   - `CONCIERGE_API_BASE` = that URL (no trailing slash)
5. Optional GitHub **Secrets** for CI deploy:
   - `CLOUDFLARE_API_TOKEN`
   - `CLOUDFLARE_ACCOUNT_ID`
   - `OPENAI_API_KEY`

Push to `main` (or re-run **Deploy Concierge API**) so Pages picks up the base URL.

## Local

```bash
cd workers/concierge
npx wrangler dev
```

Point the prototype at `http://127.0.0.1:8787` via `public/velanera-app/config.js`.

## Request

```http
POST /concierge/chat
Content-Type: application/json

{
  "transcript": "What’s on the menu tonight?",
  "history": [
    { "role": "host", "text": "Welcome to Velanera…" },
    { "role": "guest", "text": "Hello" }
  ]
}
```
