# Velanera Concierge API (OpenAI)

GitHub Pages is static — the browser **must not** hold an OpenAI key. This Cloudflare Worker is the server-side proxy that calls GPT and returns concierge replies.

## Why this exists

- Web prototype + future iOS app → `POST /concierge/chat`
- Worker attaches `OPENAI_API_KEY` and calls OpenAI (`gpt-4.1` by default)
- Matches `ios/Velanera/.../OpenAIIntegrationNotes.swift`

## Checklist (GPT will stay in demo mode until all of these are done)

### A. GitHub Actions secrets
Repo → **Settings → Secrets and variables → Actions → Secrets**:

| Secret | Where to get it |
|---|---|
| `OPENAI_API_KEY` | platform.openai.com → API keys |
| `CLOUDFLARE_API_TOKEN` | dash.cloudflare.com → My Profile → API Tokens (Workers Edit) |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare dashboard → Workers → right sidebar Account ID |

### B. Deploy the worker
Actions → **Deploy Concierge API** → Run workflow.  
Copy the worker URL from the log (e.g. `https://velanera-concierge.<account>.workers.dev`).

### C. Point the website at it
Repo → **Settings → Secrets and variables → Actions → Variables**:

- `CONCIERGE_API_BASE` = worker URL (**no** trailing slash)

Then Actions → **Deploy to GitHub Pages** → Run workflow.

### D. Verify on iPhone
Open https://velanera.co/velanera-app/ — subtitle should say **GPT concierge**, not Demo mode.

### Manual deploy (optional)

```bash
cd workers/concierge
npx wrangler login
npx wrangler secret put OPENAI_API_KEY
npx wrangler deploy
```

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
