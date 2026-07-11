import Logo from './Logo'

export default function Footer() {
  return (
    <footer className="border-t border-gold/15 bg-ink-soft py-12">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-6 px-6 text-center">
        <Logo />
        <p className="max-w-md text-sm text-cream/50">
          Refined Mediterranean dining &amp; cocktails. Set sail with us for an
          unforgettable evening.
        </p>
        <div className="flex gap-6 text-xs tracking-[0.2em] text-cream/60 uppercase">
          <a href="#home" className="hover:text-gold">Home</a>
          <a href="#lounge" className="hover:text-gold">Lounge</a>
          <a href="#booking" className="hover:text-gold">Booking</a>
          <a href="#contacts" className="hover:text-gold">Contacts</a>
        </div>
        <p className="text-xs tracking-[0.2em] text-cream/30 uppercase">
          &copy; {new Date().getFullYear()} Velanera &middot; velanera.co
        </p>
      </div>
    </footer>
  )
}
