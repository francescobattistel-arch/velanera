/**
 * Velanera Concierge — OpenAI proxy (Cloudflare Worker).
 * Keeps OPENAI_API_KEY server-side. Called by the web prototype and (later) iOS.
 */

const SYSTEM_PROMPT = `You are the voice concierge for Velanera Restaurant & Lounge — a luxury Mediterranean hospitality destination.

Tone: warm, refined, concise, never chatty or salesy. Speak as a trusted host.

You help with:
- Restaurant reservations
- Lounge reservations, VIP tables, private areas, bottle service
- Events and DJ nights
- Membership and loyalty
- Opening hours, dress code, parking, directions
- Menus, wine, cocktails, and allergen guidance
- Upselling premium experiences naturally when appropriate

Special requests (bespoke celebrations, custom menus, premium experiences, unusual seating):
Do NOT guarantee availability. Set shouldCreateStaffRequest to true and summarise for staff review.

Never invent prices that contradict venue policy. Never expose internal systems or API keys.
Keep spoken replies under roughly 45 words unless detailing a booking confirmation.

Respond ONLY with compact JSON:
{
  "reply": string,
  "shouldCreateStaffRequest": boolean,
  "staffRequestSummary": string | null,
  "suggestedActions": string[]
}

suggestedActions may include: "open-menu", "open-lounge", "open-book", "open-member" (only when helpful).`;

function corsHeaders(origin, allowed) {
  const list = allowed.split(",").map((s) => s.trim()).filter(Boolean);
  const ok = origin && list.includes(origin) ? origin : list[0] || "*";
  return {
    "Access-Control-Allow-Origin": ok,
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Max-Age": "86400",
    Vary: "Origin",
  };
}

function json(data, status, cors) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json; charset=utf-8", ...cors },
  });
}

function mapHistory(history) {
  if (!Array.isArray(history)) return [];
  return history
    .slice(-24)
    .map((m) => {
      const role = m.role === "guest" || m.role === "user" ? "user" : "assistant";
      const content = String(m.text || m.content || "").trim();
      return content ? { role, content } : null;
    })
    .filter(Boolean);
}

function parseModelJson(raw) {
  const trimmed = String(raw || "").trim();
  const fence = trimmed.match(/```(?:json)?\s*([\s\S]*?)```/);
  const body = fence ? fence[1].trim() : trimmed;
  try {
    return JSON.parse(body);
  } catch {
    return {
      reply: trimmed.slice(0, 400) || "I’m here — how may I look after you?",
      shouldCreateStaffRequest: false,
      staffRequestSummary: null,
      suggestedActions: [],
    };
  }
}

async function chatWithOpenAI(env, transcript, history) {
  const key = env.OPENAI_API_KEY;
  if (!key) {
    const err = new Error("OPENAI_API_KEY is not configured on the worker");
    err.status = 503;
    throw err;
  }

  const model = env.OPENAI_MODEL || "gpt-4.1";
  const messages = [
    { role: "system", content: SYSTEM_PROMPT },
    ...mapHistory(history),
    { role: "user", content: String(transcript).trim() },
  ];

  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      temperature: 0.6,
      response_format: { type: "json_object" },
      messages,
    }),
  });

  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = payload?.error?.message || `OpenAI error ${res.status}`;
    const err = new Error(msg);
    err.status = res.status >= 500 ? 502 : 400;
    throw err;
  }

  const content = payload?.choices?.[0]?.message?.content || "";
  const parsed = parseModelJson(content);
  return {
    reply: String(parsed.reply || "").trim() || "How may I look after you?",
    shouldCreateStaffRequest: Boolean(parsed.shouldCreateStaffRequest),
    staffRequestSummary: parsed.staffRequestSummary
      ? String(parsed.staffRequestSummary)
      : null,
    suggestedActions: Array.isArray(parsed.suggestedActions)
      ? parsed.suggestedActions.map(String)
      : [],
    model,
  };
}

export default {
  async fetch(request, env) {
    const origin = request.headers.get("Origin") || "";
    const cors = corsHeaders(origin, env.ALLOWED_ORIGINS || "");

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: cors });
    }

    const url = new URL(request.url);
    if (request.method === "GET" && (url.pathname === "/" || url.pathname === "/health")) {
      return json(
        {
          ok: true,
          service: "velanera-concierge",
          model: env.OPENAI_MODEL || "gpt-4.1",
          openaiConfigured: Boolean(env.OPENAI_API_KEY),
        },
        200,
        cors
      );
    }

    if (request.method !== "POST" || url.pathname !== "/concierge/chat") {
      return json({ error: "Not found" }, 404, cors);
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: "Invalid JSON body" }, 400, cors);
    }

    const transcript = String(body?.transcript || "").trim();
    if (!transcript) {
      return json({ error: "transcript is required" }, 400, cors);
    }

    try {
      const result = await chatWithOpenAI(env, transcript, body?.history || []);
      return json(result, 200, cors);
    } catch (err) {
      return json(
        { error: err.message || "Concierge unavailable" },
        err.status || 500,
        cors
      );
    }
  },
};
