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
        <div className="flex flex-wrap justify-center gap-6 text-xs tracking-[0.2em] text-cream/60 uppercase">
          <a href="#home" className="hover:text-gold">Home</a>
          <a href="#lounge" className="hover:text-gold">Lounge</a>
          <a href="#booking" className="hover:text-gold">Booking</a>
          <a href="#contacts" className="hover:text-gold">Contacts</a>
          <a
            href="#app"
            className="border border-gold/40 px-3 py-1.5 text-gold hover:border-gold hover:text-gold"
          >
            Get the App
          </a>
        </div>
        <p className="max-w-sm text-xs leading-relaxed text-cream/35">
          No App Store download — open{' '}
          <a href="https://velanera.co/#app" className="text-gold/70 hover:text-gold">
            velanera.co/#app
          </a>{' '}
          in Safari and add Velanera to your Home Screen.
        </p>
        <p className="text-xs tracking-[0.2em] text-cream/30 uppercase">
          &copy; {new Date().getFullYear()} Velanera &middot; velanera.co
        </p>
      </div>
    </footer>
  )
}
