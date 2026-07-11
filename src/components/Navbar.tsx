import { useEffect, useState } from 'react'
import Logo from './Logo'

const links = [
  { href: '#home', label: 'Home' },
  { href: '#lounge', label: 'Lounge' },
  { href: '#booking', label: 'Booking' },
  { href: '#contacts', label: 'Contacts' },
]

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false)
  const [open, setOpen] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <header
      className={`fixed inset-x-0 top-0 z-50 transition-all duration-500 ${
        scrolled
          ? 'border-b border-gold/15 bg-ink/85 backdrop-blur-md'
          : 'border-b border-transparent bg-transparent'
      }`}
    >
      <nav className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
        <a href="#home" aria-label="Velanera home">
          <Logo />
        </a>

        <ul className="hidden items-center gap-10 md:flex">
          {links.map((link) => (
            <li key={link.href}>
              <a
                href={link.href}
                className="text-sm tracking-[0.22em] text-cream/80 uppercase transition-colors hover:text-gold"
              >
                {link.label}
              </a>
            </li>
          ))}
          <li>
            <a
              href="#booking"
              className="border border-gold/60 px-5 py-2 text-xs tracking-[0.22em] text-gold uppercase transition-colors hover:bg-gold hover:text-ink"
            >
              Reserve
            </a>
          </li>
        </ul>

        <button
          type="button"
          className="text-gold md:hidden"
          aria-label="Toggle menu"
          aria-expanded={open}
          onClick={() => setOpen((v) => !v)}
        >
          <span className="block h-0.5 w-7 bg-gold" />
          <span className="mt-1.5 block h-0.5 w-7 bg-gold" />
          <span className="mt-1.5 block h-0.5 w-7 bg-gold" />
        </button>
      </nav>

      {open && (
        <ul className="flex flex-col gap-1 border-t border-gold/15 bg-ink/95 px-6 py-4 md:hidden">
          {links.map((link) => (
            <li key={link.href}>
              <a
                href={link.href}
                onClick={() => setOpen(false)}
                className="block py-2 text-sm tracking-[0.22em] text-cream/80 uppercase hover:text-gold"
              >
                {link.label}
              </a>
            </li>
          ))}
        </ul>
      )}
    </header>
  )
}
