import Logo from './Logo'

export default function Footer() {
  return (
    <footer className="border-t border-gold/15 bg-ink-soft py-12">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-6 px-6 text-center">
        <Logo className="h-20 w-auto" />
        <p className="max-w-md text-sm text-cream/50">
          Refined Mediterranean dining &amp; cocktails. Join us for an
          unforgettable evening.
        </p>
        <div className="flex flex-wrap items-center justify-center gap-6 text-xs tracking-[0.2em] text-cream/60 uppercase">
          <a href="#home" className="hover:text-gold">Home</a>
          <a href="#lounge" className="hover:text-gold">Lounge</a>
          <a href="#booking" className="hover:text-gold">Booking</a>
          <a href="#contacts" className="hover:text-gold">Contacts</a>
          <a
            href="#app"
            className="border border-gold bg-gold px-4 py-2 text-ink hover:bg-transparent hover:text-gold"
          >
            Get the App
          </a>
        </div>
        <p className="max-w-sm text-xs leading-relaxed text-cream/35">
          Try the interactive prototype at{' '}
          <a
            href="/velanera-app/"
            className="text-gold underline decoration-gold/40 underline-offset-4 hover:text-gold"
          >
            velanera.co/velanera-app
          </a>
          .
        </p>
        <p className="text-xs tracking-[0.2em] text-cream/30 uppercase">
          &copy; {new Date().getFullYear()} Velanera &middot; velanera.co
        </p>
      </div>
    </footer>
  )
}
