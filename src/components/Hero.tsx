import Logo from './Logo'

export default function Hero() {
  return (
    <section id="home" className="relative flex min-h-screen items-center justify-center overflow-hidden">
      <div className="absolute inset-0 -z-10 bg-ink">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_35%,rgba(201,162,75,0.18),transparent_60%)]" />
        <div className="absolute inset-0 bg-[linear-gradient(180deg,#0a0a0a_0%,#100f0c_55%,#0a0a0a_100%)]" />
      </div>

      <div className="mx-auto max-w-3xl px-6 text-center">
        <h1 className="mb-6 flex justify-center">
          <span className="sr-only">Velanera</span>
          <Logo className="h-52 w-auto sm:h-64 md:h-72" />
        </h1>
        <p className="text-xs tracking-luxe text-gold/80 uppercase">
          Restaurant &middot; Lounge
        </p>
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
