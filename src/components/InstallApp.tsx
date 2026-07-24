const steps = [
  'Open this site in Safari',
  'Tap Share',
  'Tap Add to Home Screen',
  'Confirm Velanera, then Add',
]

export default function InstallApp() {
  return (
    <section id="app" className="relative border-t border-gold/10 py-24">
      <div className="mx-auto max-w-2xl px-6 text-center">
        <div className="fade-up">
          <p className="mb-4 text-xs tracking-luxe text-gold/80 uppercase">On your phone</p>
          <h2 className="text-4xl md:text-5xl">Get the App</h2>
          <div className="hairline mx-auto my-7 h-px w-28" />
          <p className="text-cream/65">
            Install Velanera on your Home Screen for a fullscreen experience —
            reserve and browse even when you are offline.
          </p>
        </div>

        <ol className="fade-up mt-12 space-y-4 text-left">
          {steps.map((step, i) => (
            <li
              key={step}
              className="flex items-baseline gap-4 border-b border-gold/10 pb-4 text-sm tracking-[0.08em] text-cream/75 uppercase last:border-b-0"
            >
              <span className="font-serif text-xl text-gold/90 normal-case tracking-normal">
                {String(i + 1).padStart(2, '0')}
              </span>
              <span>{step}</span>
            </li>
          ))}
        </ol>

        <p className="fade-up mt-10 text-xs tracking-[0.18em] text-cream/40 uppercase">
          Then launch Velanera from your Home Screen
        </p>
      </div>
    </section>
  )
}
