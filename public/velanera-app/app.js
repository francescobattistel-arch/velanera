(() => {
  "use strict";

  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => [...root.querySelectorAll(sel)];

  const ONBOARD = [
    {
      title: "Welcome",
      body: "A luxury restaurant & lounge companion — menus, evenings, membership, and your AI Concierge.",
    },
    {
      title: "Voice-first host",
      body: "Hold the host portrait to speak. Ask for a table, the menu, lounge access, or a staff member.",
    },
    {
      title: "Your evening",
      body: "Browse the menu, reserve dining or VIP, carry your membership card — then return to Concierge anytime.",
    },
  ];

  const SUGGESTIONS = [
    { key: "book", label: "Book a table" },
    { key: "menu", label: "What’s on the menu?" },
    { key: "lounge", label: "Lounge tonight?" },
    { key: "staff", label: "Call a staff member" },
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

  const REPLIES = {
    book: "I can hold a table for you. Prefer the dining room or lounge VIP?",
    menu: "Tonight’s signatures: Burrata & Heirloom Tomato, Lobster Linguine, and Wagyu Tagliata. Opening the menu for you.",
    lounge: "The lounge opens at 21:00. VIP booths and bottle service are available — I’ll take you there.",
    staff: "I’ll notify the floor team. A host will find you shortly.",
    default: "Understood. I can help with tables, the menu, lounge access, or staff — what would you like?",
  };

  const state = {
    onboardStep: 0,
    listening: false,
    processing: false,
    menuCat: "Antipasti",
    selectedSlot: "19:30",
    messages: [
      {
        role: "host",
        text: "Welcome to Velanera. I’m your host — hold my portrait to speak, or choose a suggestion below.",
      },
    ],
  };

  function escapeHtml(s) {
    return String(s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
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

  /* ——— Onboarding ——— */
  function paintOnboarding() {
    const step = ONBOARD[state.onboardStep];
    $("#onboardTitle").textContent = step.title;
    $("#onboardBody").textContent = step.body;
    const dots = $("#onboardDots");
    dots.innerHTML = ONBOARD.map((_, i) =>
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

  /* ——— Concierge ——— */
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
      btn.addEventListener("click", () => {
        pushMessage("guest", s.label);
        reply(s.key);
      });
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
        box.insertAdjacentHTML(
          "beforeend",
          `<div class="bubble host">
            <img class="host-mini" src="./assets/concierge-host.png" alt="" />
            <div>
              <div class="who">Concierge</div>
              <div class="text">${escapeHtml(m.text)}</div>
            </div>
          </div>`
        );
      }
    });
    box.scrollTop = box.scrollHeight;
  }

  function pushMessage(role, text) {
    state.messages.push({ role, text });
    renderTranscript();
  }

  function reply(key) {
    const text = REPLIES[key] || REPLIES.default;
    setTimeout(() => {
      pushMessage("host", text);
      if (key === "menu") {
        setTimeout(() => {
          showScreen("app");
          setTab("restaurant");
        }, 900);
      } else if (key === "lounge") {
        setTimeout(() => {
          showScreen("app");
          setTab("lounge");
        }, 900);
      } else if (key === "book") {
        setTimeout(() => {
          showScreen("app");
          setTab("book");
        }, 900);
      }
    }, 520);
  }

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
    requestAnimationFrame(() => {
      setTimeout(animateWave, 90);
    });
  }

  function startListen(e) {
    e.preventDefault();
    if (state.listening || state.processing) return;
    state.listening = true;
    const btn = $("#holdTalk");
    btn.classList.add("recording");
    btn.classList.remove("processing");
    $("#talkBadge").textContent = "Listening…";
    $("#liveText").textContent = "I’m listening — ask for a table or the menu";
    $("#waveform").classList.add("active");
    buildWaveform();
    animateWave();
  }

  function stopListen(e) {
    e.preventDefault();
    if (!state.listening) return;
    state.listening = false;
    state.processing = true;
    const btn = $("#holdTalk");
    btn.classList.remove("recording");
    btn.classList.add("processing");
    $("#talkBadge").textContent = "Thinking…";
    $("#liveText").textContent = "";
    $("#waveform").classList.remove("active");

    const heard = "I’d like to book a table for Friday evening";
    setTimeout(() => {
      state.processing = false;
      btn.classList.remove("processing");
      $("#talkBadge").textContent = "Hold to Talk";
      pushMessage("guest", heard);
      reply("book");
    }, 650);
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
      const code = "VL-" + Math.random().toString(36).slice(2, 6).toUpperCase();
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

    if (sessionStorage.getItem("vel_proto_onboarded")) {
      openConcierge(true);
    } else {
      paintOnboarding();
      showScreen("onboarding");
    }
  }

  boot();
})();
