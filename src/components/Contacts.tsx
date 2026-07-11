const hours = [
  { day: 'Monday — Thursday', time: '17:00 — 00:00' },
  { day: 'Friday — Saturday', time: '17:00 — 02:00' },
  { day: 'Sunday', time: '13:00 — 23:00' },
]

export default function Contacts() {
  return (
    <section id="contacts" className="relative py-28">
      <div className="mx-auto max-w-6xl px-6">
        <div className="fade-up text-center">
          <p className="mb-4 text-xs tracking-luxe text-gold/80 uppercase">Find Us</p>
          <h2 className="text-4xl md:text-5xl">Contacts &amp; Hours</h2>
          <div className="hairline mx-auto my-7 h-px w-28" />
        </div>

        <div className="mt-14 grid gap-10 md:grid-cols-3">
          <div className="fade-up border border-gold/15 bg-ink-card/50 p-8">
            <h3 className="text-gold text-2xl">Visit</h3>
            <p className="mt-4 text-cream/70">
              1 Harbour Promenade
              <br />
              Marina District
              <br />
              Open-air terrace &amp; indoor lounge
            </p>
          </div>

          <div className="fade-up border border-gold/15 bg-ink-card/50 p-8">
            <h3 className="text-gold text-2xl">Reach Us</h3>
            <p className="mt-4 space-y-2 text-cream/70">
              <a href="tel:+15550100" className="block hover:text-gold">
                +1 (555) 0100
              </a>
              <a href="mailto:reservations@velanera.co" className="block hover:text-gold">
                reservations@velanera.co
              </a>
              <a
                href="https://instagram.com"
                target="_blank"
                rel="noreferrer"
                className="block hover:text-gold"
              >
                @velanera
              </a>
            </p>
          </div>

          <div className="fade-up border border-gold/15 bg-ink-card/50 p-8">
            <h3 className="text-gold text-2xl">Hours</h3>
            <ul className="mt-4 space-y-2 text-sm text-cream/70">
              {hours.map((h) => (
                <li key={h.day} className="flex justify-between gap-4">
                  <span>{h.day}</span>
                  <span className="text-cream/90">{h.time}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="fade-up mt-12 text-center">
          <a
            href="#booking"
            className="inline-block border border-gold bg-gold px-10 py-4 text-sm tracking-[0.22em] text-ink uppercase transition-colors hover:bg-transparent hover:text-gold"
          >
            Reserve a Table
          </a>
        </div>
      </div>
    </section>
  )
}
