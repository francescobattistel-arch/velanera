(() => {
  "use strict";

  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => [...root.querySelectorAll(sel)];

  const SpeechRecognition =
    window.SpeechRecognition || window.webkitSpeechRecognition || null;

  const ONBOARD = [
    {
      title: "Welcome",
      body: "A luxury restaurant & lounge companion — menus, evenings, membership, and your AI Concierge.",
    },
    {
      title: "Voice-first host",
      body: "Hold the host portrait to speak, or type below. Ask anything — dining, lounge, wine, hours, membership.",
    },
    {
      title: "Your evening",
      body: "Stay in conversation with your host. Open Menu, Lounge, or Book only when you choose.",
    },
  ];

  const SUGGESTIONS = [
    { label: "Book a table" },
    { label: "What’s on the menu?" },
    { label: "Lounge tonight?" },
    { label: "Wine pairing?" },
    { label: "What are your hours?" },
    { label: "Call a staff member" },
  ];

  const MENU = {
    Antipasti: [
      { name: "Burrata & Heirloom Tomato", price: "£18", blurb: "Basil oil, aged balsamic", icon: "I" },
      { name: "Tuna Crudo", price: "£22", blurb: "Citrus, olive, chilli", icon: "II" },
      { name: "Truffle Arancini", price: "£16", blurb: "Parmigiano, black truffle", icon: "III" },
    ],
    Primi: [
      { name: "Cacio e Pepe", price: "£24", blurb: "Tonnarelli, pecorino, pepper", icon: "I" },
      { name: "Lobster Linguine", price: "£38", blurb: "Cherry tomato, brandy", icon: "II" },
      { name: "Risotto al Tartufo", price: "£32", blurb: "Carnaroli, white truffle", icon: "III" },
    ],
    Secondi: [
      { name: "Branzino al Forno", price: "£36", blurb: "Fennel, lemon, olive", icon: "I" },
      { name: "Veal Milanese", price: "£34", blurb: "Rocket, cherry tomato", icon: "II" },
      { name: "Wagyu Tagliata", price: "£58", blurb: "Rosemary, sea salt", icon: "III" },
    ],
    Dolci: [
      { name: "Tiramisu", price: "£14", blurb: "Classic, espresso soak", icon: "I" },
      { name: "Chocolate Fondant", price: "£15", blurb: "Vanilla gelato", icon: "II" },
    ],
  };

  const LOUNGE = [
    { name: "VIP Booth", price: "From £450", blurb: "Curtained seating for six with dedicated host.", icon: "♛" },
    { name: "Private Room", price: "From £1,200", blurb: "Closed-door dining and lounge for twelve.", icon: "⌂" },
    { name: "Bottle Service", price: "From £280", blurb: "Champagne and spirit packages, table-side.", icon: "✦" },
  ];

  const EVENTS = [
    { title: "Friday Late Lounge", date: "Fri · 22:00" },
    { title: "Sommelier Sunday", date: "Sun · 15:00" },
    { title: "Members’ Night", date: "Thu · 20:00" },
  ];

  const SLOTS = ["18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00"];

  const state = {
    onboardStep: 0,
    listening: false,
    processing: false,
    menuCat: "Antipasti",
    selectedSlot: "19:30",
    messages: [
      {
        role: "host",
        text: "Welcome to Velanera. I’m your host — hold my portrait to speak, or type below. How may I look after you?",
      },
    ],
    bookingFlow: null, // null | 'date' | 'guests' | 'time' | 'venue'
    draft: { date: "", guests: "", time: "", venue: "restaurant" },
    reservation: null,
    recognition: null,
    interim: "",
  };

  function escapeHtml(s) {
    return String(s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function has(text, words) {
    return words.some((w) => text.includes(w));
  }

  function showScreen(name) {
    $$(".screen").forEach((s) => s.classList.toggle("active", s.dataset.screen === name));
  }

  function tickClock() {
    const el = $("#clock");
    if (!el) return;
    const d = new Date();
    el.textContent = d.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
  }

  function speak(text) {
    if (!window.speechSynthesis) return;
    try {
      window.speechSynthesis.cancel();
      const u = new SpeechSynthesisUtterance(text);
      u.rate = 0.95;
      u.pitch = 0.95;
      window.speechSynthesis.speak(u);
    } catch {
      /* optional */
    }
  }

  /* ——— Onboarding ——— */
  function paintOnboarding() {
    const step = ONBOARD[state.onboardStep];
    $("#onboardTitle").textContent = step.title;
    $("#onboardBody").textContent = step.body;
    $("#onboardDots").innerHTML = ONBOARD.map((_, i) =>
      `<span class="${i === state.onboardStep ? "on" : ""}"></span>`
    ).join("");
    $("#onboardNext").textContent =
      state.onboardStep === ONBOARD.length - 1 ? "Meet your host" : "Continue";
  }

  function nextOnboard() {
    if (state.onboardStep < ONBOARD.length - 1) {
      state.onboardStep += 1;
      paintOnboarding();
      return;
    }
    sessionStorage.setItem("vel_proto_onboarded", "1");
    openConcierge(true);
  }

  /* ——— Concierge UI ——— */
  function openConcierge(fresh) {
    showScreen("concierge");
    if (fresh) renderTranscript();
  }

  function closeConcierge() {
    showScreen("app");
    setTab("home");
  }

  function renderSuggestions() {
    const box = $("#suggestions");
    box.innerHTML = "";
    SUGGESTIONS.forEach((s) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.textContent = s.label;
      btn.addEventListener("click", () => handleGuestUtterance(s.label));
      box.appendChild(btn);
    });
  }

  function renderTranscript() {
    const box = $("#transcript");
    box.innerHTML = "";
    state.messages.forEach((m) => {
      if (m.role === "guest") {
        box.insertAdjacentHTML(
          "beforeend",
          `<div class="bubble guest"><div class="text">${escapeHtml(m.text)}</div></div>`
        );
      } else {
        const actions = (m.actions || [])
          .map(
            (a) =>
              `<button type="button" data-action="${escapeHtml(a.id)}">${escapeHtml(a.label)}</button>`
          )
          .join("");
        box.insertAdjacentHTML(
          "beforeend",
          `<div class="bubble host">
            <img class="host-mini" src="./assets/concierge-host.png" alt="" />
            <div>
              <div class="who">Concierge</div>
              <div class="text">${escapeHtml(m.text)}</div>
              ${actions ? `<div class="action-chips">${actions}</div>` : ""}
            </div>
          </div>`
        );
      }
    });
    box.scrollTop = box.scrollHeight;
  }

  function pushGuest(text) {
    state.messages.push({ role: "guest", text });
    renderTranscript();
  }

  function pushHost(text, actions = []) {
    state.messages.push({ role: "host", text, actions });
    renderTranscript();
    speak(text);
  }

  function confirmCode() {
    return "VL-" + Math.random().toString(36).slice(2, 6).toUpperCase();
  }

  /* ——— Conversation brain (stays in chat) ——— */
  function respondTo(transcript) {
    const text = transcript.toLowerCase().trim();
    if (!text) {
      return {
        reply: "I didn’t quite catch that. Hold to speak again, or type your request below.",
        actions: [],
      };
    }

    // Active booking dialogue
    if (state.bookingFlow) {
      return continueBooking(text, transcript);
    }

    if (state.reservation && has(text, ["my booking", "my reservation", "confirmation", "what did i book"])) {
      const r = state.reservation;
      return {
        reply: `You have ${r.venue} reserved for ${r.guests} on ${r.date} at ${r.time}. Confirmation ${r.code}. Anything else I can arrange?`,
        actions: [{ id: "open-book", label: "View booking screen" }],
      };
    }

    if (has(text, ["cancel", "change my booking", "modify reservation"]) && state.reservation) {
      const code = state.reservation.code;
      state.reservation = null;
      state.bookingFlow = null;
      return {
        reply: `I’ve released reservation ${code}. Would you like to book again, or shall we talk about the menu or lounge?`,
        actions: [],
      };
    }

    if (has(text, ["book", "reserve", "reservation", "table", "dinner for", "lunch for", "make a booking"])) {
      if (state.reservation) {
        return {
          reply: `You already have ${state.reservation.venue} at ${state.reservation.time} on ${state.reservation.date} (${state.reservation.code}). Would you like to change it, or ask about something else?`,
          actions: [
            { id: "rebook", label: "Book something new" },
            { id: "open-book", label: "Open booking screen" },
          ],
        };
      }
      state.bookingFlow = "venue";
      state.draft = { date: "", guests: "", time: "", venue: "restaurant" };
      return {
        reply: "Gladly. Dining room, lounge VIP, or a private room?",
        actions: [
          { id: "venue-restaurant", label: "Restaurant" },
          { id: "venue-lounge", label: "Lounge" },
          { id: "venue-private", label: "Private room" },
        ],
      };
    }

    if (has(text, ["staff", "waiter", "server", "manager", "help me here", "come over", "call someone"])) {
      return {
        reply: "I’ve notified the floor team. A host will find you shortly. Is there anything else while you wait?",
        actions: [],
      };
    }

    if (has(text, ["lounge", "vip", "bottle", "dj", "after dark", "nightclub"])) {
      return {
        reply: "The lounge opens from 21:00 — VIP booths, private rooms, and bottle service. What would you like to know?",
        actions: [{ id: "open-lounge", label: "Open lounge" }],
      };
    }

    if (has(text, ["wine", "red", "white", "champagne", "pairing", "sommelier"])) {
      return {
        reply: "For seafood, Chablis Premier Cru; with lamb, Barolo Riserva. I can also arrange a tasting flight at your table.",
        actions: [{ id: "open-menu", label: "Browse menu" }],
      };
    }

    if (has(text, ["cocktail", "drink", "spritz", "old fashioned", "bar"])) {
      return {
        reply: "Signatures: the Velanera Spritz and a smoked Old Fashioned. I can have one waiting when you arrive.",
        actions: [],
      };
    }

    if (has(text, ["hours", "open", "closing", "what time", "when do you"])) {
      return {
        reply: "Restaurant: Tuesday–Sunday. Lounge: Thursday–Saturday into the early hours. Which evening are you planning?",
        actions: [],
      };
    }

    if (has(text, ["dress", "code", "attire", "wear", "jacket"])) {
      return {
        reply: "Smart elegance — refined and considered. Sportswear isn’t permitted in the lounge.",
        actions: [],
      };
    }

    if (has(text, ["park", "parking", "valet", "directions", "address", "where are you", "location"])) {
      return {
        reply: "We’re at 12 Harbour Lane, London. Evening valet runs Friday and Saturday. Need a reservation for that night as well?",
        actions: [],
      };
    }

    if (has(text, ["member", "membership", "loyalty", "join"])) {
      return {
        reply: "House and Black membership unlock preferred seating, member nights, and host priority. Shall I outline the tiers?",
        actions: [{ id: "open-member", label: "View membership" }],
      };
    }

    if (has(text, ["menu", "dish", "chef", "dessert", "allergen", "food", "eat", "pasta", "steak"])) {
      return {
        reply: "Tonight’s signatures: Burrata & Heirloom Tomato, Lobster Linguine, and Wagyu Tagliata. Any preferences or allergens I should note?",
        actions: [{ id: "open-menu", label: "Open full menu" }],
      };
    }

    if (has(text, ["event", "jazz", "concert", "rsvp", "music", "tonight"])) {
      return {
        reply: "Ahead: Friday Late Lounge, Sommelier Sunday, and Members’ Night. Which evening interests you?",
        actions: [{ id: "open-lounge", label: "See events" }],
      };
    }

    if (has(text, ["hello", "hi ", "hey", "good evening", "good afternoon", "buonasera"])) {
      return {
        reply: "Good evening. I can help with dining, the lounge, wine, membership, or a quiet word with the team. What would you like?",
        actions: [],
      };
    }

    if (has(text, ["thank", "thanks", "cheers", "perfect", "great"])) {
      return {
        reply: "You’re most welcome. I’m here whenever you need me.",
        actions: [],
      };
    }

    if (has(text, ["special", "anniversary", "engagement", "proposal", "surprise", "celebration", "bespoke"])) {
      return {
        reply: "A beautiful request. I’ve noted this for our team to review personally — they’ll confirm details with you. Anything else for this evening?",
        actions: [],
      };
    }

    return {
      reply: "Of course. I can help with reservations, the menu, lounge VIP, wine, hours, membership, or calling staff — what would you like?",
      actions: [],
    };
  }

  function continueBooking(text, raw) {
    const flow = state.bookingFlow;

    if (has(text, ["cancel", "never mind", "stop", "forget it"])) {
      state.bookingFlow = null;
      return { reply: "No trouble — booking paused. How else may I help?", actions: [] };
    }

    if (flow === "venue") {
      if (has(text, ["lounge", "vip", "booth"])) state.draft.venue = "lounge";
      else if (has(text, ["private", "room"])) state.draft.venue = "private room";
      else state.draft.venue = "restaurant";
      state.bookingFlow = "date";
      return {
        reply: `${capitalize(state.draft.venue)} — lovely. Which date works? You can say “Friday” or “31 July”.`,
        actions: [
          { id: "date-friday", label: "Friday" },
          { id: "date-saturday", label: "Saturday" },
          { id: "date-sunday", label: "Sunday" },
        ],
      };
    }

    if (flow === "date") {
      state.draft.date = extractDate(text, raw);
      state.bookingFlow = "guests";
      return {
        reply: `${state.draft.date} noted. How many guests?`,
        actions: [
          { id: "guests-2", label: "2" },
          { id: "guests-4", label: "4" },
          { id: "guests-6", label: "6" },
        ],
      };
    }

    if (flow === "guests") {
      const n = text.match(/\d{1,2}/)?.[0] || "2";
      state.draft.guests = n;
      state.bookingFlow = "time";
      return {
        reply: `Party of ${n}. What time shall I hold?`,
        actions: [
          { id: "time-1930", label: "19:30" },
          { id: "time-2000", label: "20:00" },
          { id: "time-2100", label: "21:00" },
        ],
      };
    }

    if (flow === "time") {
      state.draft.time = extractTime(text) || "19:30";
      const code = confirmCode();
      state.reservation = { ...state.draft, code };
      state.bookingFlow = null;
      state.selectedSlot = state.draft.time;
      return {
        reply: `Reserved — ${state.draft.venue} for ${state.draft.guests} on ${state.draft.date} at ${state.draft.time}. Confirmation ${code}. Anything else?`,
        actions: [{ id: "open-book", label: "View booking screen" }],
      };
    }

    state.bookingFlow = null;
    return { reply: "Let’s start fresh — would you like to book, or ask about something else?", actions: [] };
  }

  function capitalize(s) {
    return s ? s.charAt(0).toUpperCase() + s.slice(1) : s;
  }

  function extractDate(text, raw) {
    if (has(text, ["friday"])) return "Friday";
    if (has(text, ["saturday"])) return "Saturday";
    if (has(text, ["sunday"])) return "Sunday";
    if (has(text, ["tonight", "today"])) return "Tonight";
    if (has(text, ["tomorrow"])) return "Tomorrow";
    const m = raw.match(/\d{1,2}\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\w*/i);
    if (m) return m[0];
    return raw.trim().slice(0, 40) || "the date you named";
  }

  function extractTime(text) {
    const m = text.match(/\b([01]?\d|2[0-3])([:.][0-5]\d)?\b/);
    if (!m) {
      if (has(text, ["half seven", "seven thirty"])) return "19:30";
      if (has(text, ["eight", "20"])) return "20:00";
      if (has(text, ["nine", "21"])) return "21:00";
      return null;
    }
    let h = parseInt(m[1], 10);
    const mins = m[2] ? m[2].replace(".", ":").slice(1) : "00";
    if (h < 12 && h >= 1 && h <= 11 && !text.includes("am")) h += 12; // evening default
    return `${String(h).padStart(2, "0")}:${mins}`;
  }

  function handleGuestUtterance(text) {
    const cleaned = text.trim();
    if (!cleaned || state.processing) return;
    state.processing = true;
    $("#talkBadge").textContent = "Thinking…";
    $("#holdTalk").classList.add("processing");
    pushGuest(cleaned);

    setTimeout(() => {
      const { reply, actions } = respondTo(cleaned);
      pushHost(reply, actions);
      state.processing = false;
      $("#talkBadge").textContent = SpeechRecognition ? "Hold to Talk" : "Hold or type";
      $("#holdTalk").classList.remove("processing");
    }, 420);
  }

  function runAction(id) {
    if (id === "open-menu") {
      showScreen("app");
      setTab("restaurant");
      return;
    }
    if (id === "open-lounge") {
      showScreen("app");
      setTab("lounge");
      return;
    }
    if (id === "open-book") {
      showScreen("app");
      setTab("book");
      if (state.reservation) {
        const msg = $("#bookConfirm");
        msg.hidden = false;
        msg.textContent = `Reserved · ${capitalize(state.reservation.venue)} · ${state.reservation.time} · ${state.reservation.guests} guests · ${state.reservation.code}`;
      }
      return;
    }
    if (id === "open-member") {
      showScreen("app");
      setTab("membership");
      return;
    }
    if (id === "rebook") {
      state.reservation = null;
      handleGuestUtterance("I’d like to book a table");
      return;
    }
    if (id === "venue-restaurant") handleGuestUtterance("Restaurant");
    if (id === "venue-lounge") handleGuestUtterance("Lounge");
    if (id === "venue-private") handleGuestUtterance("Private room");
    if (id === "date-friday") handleGuestUtterance("Friday");
    if (id === "date-saturday") handleGuestUtterance("Saturday");
    if (id === "date-sunday") handleGuestUtterance("Sunday");
    if (id === "guests-2") handleGuestUtterance("2");
    if (id === "guests-4") handleGuestUtterance("4");
    if (id === "guests-6") handleGuestUtterance("6");
    if (id === "time-1930") handleGuestUtterance("19:30");
    if (id === "time-2000") handleGuestUtterance("20:00");
    if (id === "time-2100") handleGuestUtterance("21:00");
  }

  /* ——— Speech ——— */
  function buildWaveform() {
    const wave = $("#waveform");
    wave.innerHTML = "";
    for (let i = 0; i < 28; i++) {
      const bar = document.createElement("i");
      bar.style.height = `${8 + Math.random() * 28}px`;
      wave.appendChild(bar);
    }
  }

  function animateWave() {
    if (!state.listening) return;
    $$("#waveform i").forEach((bar) => {
      bar.style.height = `${8 + Math.random() * 32}px`;
    });
    setTimeout(() => requestAnimationFrame(animateWave), 90);
  }

  function ensureRecognition() {
    if (!SpeechRecognition) return null;
    if (state.recognition) return state.recognition;
    const rec = new SpeechRecognition();
    rec.lang = "en-GB";
    rec.interimResults = true;
    rec.continuous = true;
    rec.maxAlternatives = 1;

    rec.onresult = (event) => {
      let interim = "";
      let finalText = "";
      for (let i = event.resultIndex; i < event.results.length; i++) {
        const piece = event.results[i][0].transcript;
        if (event.results[i].isFinal) finalText += piece;
        else interim += piece;
      }
      state.interim = (finalText || interim).trim();
      $("#liveText").textContent = state.interim || "Listening…";
    };

    rec.onerror = () => {
      /* fall through on stop */
    };

    state.recognition = rec;
    return rec;
  }

  function startListen(e) {
    e.preventDefault();
    if (state.listening || state.processing) return;
    state.listening = true;
    state.interim = "";
    if (window.speechSynthesis) window.speechSynthesis.cancel();

    const btn = $("#holdTalk");
    btn.classList.add("recording");
    btn.classList.remove("processing");
    $("#talkBadge").textContent = "Listening…";
    $("#liveText").textContent = SpeechRecognition
      ? "Speak now — I’m listening"
      : "Speech not available here — type below, or release for a tip";
    $("#waveform").classList.add("active");
    buildWaveform();
    animateWave();

    const rec = ensureRecognition();
    if (rec) {
      try {
        rec.start();
      } catch {
        /* already started */
      }
    }
  }

  function stopListen(e) {
    e.preventDefault();
    if (!state.listening) return;
    state.listening = false;
    const btn = $("#holdTalk");
    btn.classList.remove("recording");
    $("#waveform").classList.remove("active");

    const rec = state.recognition;
    let heard = state.interim;
    if (rec) {
      try {
        rec.stop();
      } catch {
        /* ignore */
      }
    }

    // Give Safari a brief moment to flush final results
    setTimeout(() => {
      heard = (state.interim || heard || "").trim();
      $("#liveText").textContent = "";
      if (!heard) {
        if (!SpeechRecognition) {
          pushHost(
            "On this device, use the text field below — or try Safari with microphone access. Hold again after allowing the mic.",
            []
          );
        } else {
          pushHost("I didn’t catch that. Hold again and speak clearly, or type below.", []);
        }
        $("#talkBadge").textContent = "Hold to Talk";
        return;
      }
      handleGuestUtterance(heard);
    }, 280);
  }

  /* ——— App tabs ——— */
  function setTab(name) {
    $$(".tab-page").forEach((p) => p.classList.toggle("active", p.dataset.tab === name));
    $$("#tabbar button").forEach((b) => b.classList.toggle("active", b.dataset.tab === name));
  }

  function cardHtml(item) {
    return `<article class="card">
      <div class="thumb" aria-hidden="true">${item.icon || "✦"}</div>
      <div>
        <span class="price">${escapeHtml(item.price)}</span>
        <h4>${escapeHtml(item.name)}</h4>
        <p>${escapeHtml(item.blurb)}</p>
      </div>
    </article>`;
  }

  function paintHome() {
    $("#homeDishes").innerHTML = MENU.Antipasti.slice(0, 2).map(cardHtml).join("");
    $("#homeEvents").innerHTML = EVENTS.map(
      (e) => `<article class="event-card">
        <span class="date">${escapeHtml(e.date)}</span>
        <h4>${escapeHtml(e.title)}</h4>
      </article>`
    ).join("");
  }

  function paintMenu() {
    const cats = Object.keys(MENU);
    $("#menuChips").innerHTML = cats
      .map(
        (c) =>
          `<button type="button" class="${c === state.menuCat ? "on" : ""}" data-cat="${escapeHtml(c)}">${escapeHtml(c)}</button>`
      )
      .join("");
    $("#menuList").innerHTML = MENU[state.menuCat].map(cardHtml).join("");
  }

  function paintLounge() {
    $("#loungeList").innerHTML = LOUNGE.map(cardHtml).join("");
  }

  function paintSlots() {
    $("#bookSlots").innerHTML = SLOTS.map(
      (s) =>
        `<button type="button" class="${s === state.selectedSlot ? "on" : ""}" data-slot="${s}">${s}</button>`
    ).join("");
  }

  function bind() {
    $("#onboardNext").addEventListener("click", nextOnboard);
    $("#closeConcierge").addEventListener("click", closeConcierge);
    $("#fabConcierge").addEventListener("click", () => openConcierge(false));
    $("#openConciergeAgain").addEventListener("click", () => openConcierge(false));

    const hold = $("#holdTalk");
    hold.addEventListener("mousedown", startListen);
    hold.addEventListener("mouseup", stopListen);
    hold.addEventListener("mouseleave", (e) => {
      if (state.listening) stopListen(e);
    });
    hold.addEventListener("touchstart", startListen, { passive: false });
    hold.addEventListener("touchend", stopListen, { passive: false });
    hold.addEventListener("touchcancel", stopListen, { passive: false });

    $("#composer").addEventListener("submit", (ev) => {
      ev.preventDefault();
      const input = $("#composerInput");
      const text = input.value.trim();
      if (!text) return;
      input.value = "";
      handleGuestUtterance(text);
    });

    $("#transcript").addEventListener("click", (ev) => {
      const btn = ev.target.closest("[data-action]");
      if (btn) runAction(btn.dataset.action);
    });

    $$("#tabbar button").forEach((b) => {
      b.addEventListener("click", () => setTab(b.dataset.tab));
    });

    document.addEventListener("click", (ev) => {
      const go = ev.target.closest("[data-go-tab]");
      if (go) setTab(go.dataset.goTab);

      const cat = ev.target.closest("[data-cat]");
      if (cat) {
        state.menuCat = cat.dataset.cat;
        paintMenu();
      }

      const slot = ev.target.closest("[data-slot]");
      if (slot) {
        state.selectedSlot = slot.dataset.slot;
        paintSlots();
      }
    });

    $("#bookSubmit").addEventListener("click", () => {
      const name = $("#bookName").value.trim() || "Guest";
      const guests = $("#bookGuests").value || "2";
      const venue = $("#bookVenue").selectedOptions[0].textContent;
      const code = confirmCode();
      state.reservation = {
        venue: venue.toLowerCase(),
        guests,
        date: "Selected date",
        time: state.selectedSlot,
        code,
      };
      const msg = $("#bookConfirm");
      msg.hidden = false;
      msg.textContent = `Reserved · ${venue} · ${state.selectedSlot} · ${guests} guests · ${name} · ${code}`;
    });
  }

  function boot() {
    tickClock();
    setInterval(tickClock, 30_000);
    bind();
    renderSuggestions();
    paintHome();
    paintMenu();
    paintLounge();
    paintSlots();
    buildWaveform();
    if (!SpeechRecognition) {
      $("#talkBadge").textContent = "Hold or type";
    }

    if (sessionStorage.getItem("vel_proto_onboarded")) {
      openConcierge(true);
    } else {
      paintOnboarding();
      showScreen("onboarding");
    }
  }

  boot();
})();
