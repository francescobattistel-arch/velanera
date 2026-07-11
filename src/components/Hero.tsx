import Logo from './Logo'

export default function Hero() {
  return (
    <section id="home" className="relative flex min-h-screen items-center justify-center overflow-hidden">
      <div className="absolute inset-0 -z-10 bg-ink">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_35%,rgba(201,162,75,0.18),transparent_60%)]" />
        <div className="absolute inset-0 bg-[linear-gradient(180deg,#0a0a0a_0%,#100f0c_55%,#0a0a0a_100%)]" />
      </div>

      <div className="mx-auto max-w-3xl px-6 text-center">
        <div className="mb-8 flex justify-center">
          <Logo showWordmark={false} className="[&_svg]:h-20 [&_svg]:w-20" />
        </div>
        <p className="mb-6 text-xs tracking-luxe text-gold/80 uppercase">
          Restaurant &middot; Lounge
        </p>
        <h1 className="text-gold-gradient text-6xl leading-none sm:text-7xl md:text-8xl">
          Velanera
        </h1>
        <div className="hairline mx-auto my-8 h-px w-40" />
        <p className="mx-auto max-w-xl text-lg font-light text-cream/75">
          Set sail into an evening of refined Mediterranean cuisine, crafted
          cocktails, and golden-hour ambiance by the water.
        </p>

        <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
          <a
            href="#booking"
            className="w-full border border-gold bg-gold px-8 py-3 text-sm tracking-[0.22em] text-ink uppercase transition-colors hover:bg-transparent hover:text-gold sm:w-auto"
          >
            Book a Table
          </a>
          <a
            href="#lounge"
            className="w-full border border-gold/50 px-8 py-3 text-sm tracking-[0.22em] text-cream uppercase transition-colors hover:border-gold hover:text-gold sm:w-auto"
          >
            Explore the Lounge
          </a>
        </div>
      </div>

      <a
        href="#lounge"
        className="absolute bottom-8 left-1/2 -translate-x-1/2 text-gold/70 transition-colors hover:text-gold"
        aria-label="Scroll down"
      >
        <span className="block animate-bounce text-2xl">&#8964;</span>
      </a>
    </section>
  )
}
