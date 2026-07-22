import loungeCollage from '../assets/lounge-collage.png'

const features = [
  {
    title: 'The Kitchen',
    text: 'Seasonal Mediterranean plates built around the day&rsquo;s catch, wood-fired and finished with estate olive oil.',
  },
  {
    title: 'The Cocktail Bar',
    text: 'Signature cocktails, rare spirits, and a curated coastal wine list poured until late.',
  },
  {
    title: 'The Lounge',
    text: 'An exclusive priv&eacute; &mdash; champagne, low light, and golden-hour nights reserved for a chosen few.',
  },
]

const menu = [
  { name: 'Amberjack Crudo', note: 'citrus, chili oil, sea salt', price: '18' },
  { name: 'Saffron Seafood Risotto', note: 'prawn, mussel, bottarga', price: '32' },
  { name: 'Wood-Fired Branzino', note: 'herbs, charred lemon', price: '38' },
  { name: 'Velanera Spritz', note: 'bergamot, prosecco, gold leaf', price: '16' },
  { name: 'Smoked Old Fashioned', note: 'barrel-aged bourbon, orange', price: '19' },
  { name: 'Pistachio Semifreddo', note: 'honey, sea salt, olive oil', price: '14' },
]

export default function Lounge() {
  return (
    <section id="lounge" className="relative py-28">
      <div className="mx-auto max-w-6xl px-6">
        <div className="fade-up mx-auto max-w-2xl text-center">
          <p className="mb-4 text-xs tracking-luxe text-gold/80 uppercase">The Experience</p>
          <h2 className="text-4xl md:text-5xl">A lounge that moves with the tide</h2>
          <div className="hairline mx-auto my-7 h-px w-28" />
          <p className="text-cream/70">
            Velanera means &ldquo;sailing ship.&rdquo; Our tables are your harbor for the
            evening &mdash; where slow dinners drift into late-night cocktails, and every
            detail is set in gold against the dark.
          </p>
        </div>

        <div className="mt-16 grid gap-6 md:grid-cols-3">
          {features.map((f) => (
            <article
              key={f.title}
              className="fade-up border border-gold/15 bg-ink-card/60 p-8 transition-colors hover:border-gold/40"
            >
              <h3 className="text-gold text-2xl">{f.title}</h3>
              <p
                className="mt-4 text-sm leading-relaxed text-cream/65"
                dangerouslySetInnerHTML={{ __html: f.text }}
              />
            </article>
          ))}
        </div>

        <div className="fade-up mt-24 grid items-center gap-10 md:grid-cols-2">
          <div className="overflow-hidden border border-gold/15">
            <img
              src={loungeCollage}
              alt="Velanera Lounge — an exclusive privé of champagne and golden-hour nights"
              className="h-full w-full object-cover"
              loading="lazy"
            />
          </div>
          <div>
            <p className="mb-4 text-xs tracking-luxe text-gold/80 uppercase">Exclusive Privé</p>
            <h2 className="text-4xl md:text-5xl">The Lounge</h2>
            <div className="hairline my-7 h-px w-28" />
            <p className="text-cream/70">
              Beyond the kitchen and the cocktail bar lies the Velanera Lounge &mdash; our
              exclusive priv&eacute;. Reserved tables, champagne on ice, and golden light
              against the dark, kept intimate for a chosen few well into the night.
            </p>
          </div>
        </div>

        <div className="fade-up mt-24">
          <div className="mb-10 text-center">
            <p className="mb-3 text-xs tracking-luxe text-gold/80 uppercase">Tasting Selections</p>
            <h2 className="text-4xl md:text-5xl">Signatures</h2>
          </div>
          <ul className="mx-auto max-w-3xl divide-y divide-gold/10">
            {menu.map((item) => (
              <li key={item.name} className="flex items-baseline gap-4 py-4">
                <span className="font-serif text-xl text-cream">{item.name}</span>
                <span className="mx-1 flex-1 translate-y-1 border-b border-dotted border-gold/25" />
                <span className="text-sm text-cream/50">{item.note}</span>
                <span className="text-gold ml-4 font-serif text-xl">&euro;{item.price}</span>
              </li>
            ))}
          </ul>
          <p className="mt-8 text-center text-xs tracking-[0.2em] text-cream/40 uppercase">
            Sample menu &middot; selections rotate with the season
          </p>
        </div>
      </div>
    </section>
  )
}
