import { useEffect, useState } from 'react'

const APP_URL = 'https://velanera.co/#app'
const SITE_URL = 'https://velanera.co/'

const steps = [
  'Open velanera.co in Safari on your iPhone',
  'Tap the Share button (square with an arrow)',
  'Scroll and tap Add to Home Screen',
  'Tap Add — Velanera appears on your Home Screen',
]

export default function InstallApp() {
  const [copied, setCopied] = useState(false)

  useEffect(() => {
    if (window.location.hash !== '#app') return
    // SPA: #app is not in the DOM until React mounts, so re-scroll after paint.
    requestAnimationFrame(() => {
      document.getElementById('app')?.scrollIntoView({ behavior: 'smooth' })
    })
  }, [])

  async function copyLink() {
    try {
      await navigator.clipboard.writeText(APP_URL)
      setCopied(true)
      window.setTimeout(() => setCopied(false), 2000)
    } catch {
      // Fallback for older Safari
      window.prompt('Copy this link:', APP_URL)
    }
  }

  async function shareLink() {
    if (typeof navigator.share === 'function') {
      try {
        await navigator.share({
          title: 'Velanera — Get the App',
          text: 'Install Velanera on your Home Screen from Safari (no App Store).',
          url: SITE_URL,
        })
        return
      } catch {
        // User cancelled or share failed — fall through to copy
      }
    }
    await copyLink()
  }

  return (
    <section
      id="app"
      className="relative scroll-mt-24 border-t border-gold/10 py-24"
      aria-labelledby="app-heading"
    >
      <div className="mx-auto max-w-2xl px-6 text-center">
        <div className="fade-up">
          <p className="mb-4 text-xs tracking-luxe text-gold/80 uppercase">
            iPhone · Safari
          </p>
          <h2 id="app-heading" className="text-4xl md:text-5xl">
            Get the App
          </h2>
          <div className="hairline mx-auto my-7 h-px w-28" />
          <p className="text-cream/65">
            There is no App Store listing. Velanera installs from this website —
            add it to your Home Screen in Safari for a fullscreen app experience,
            including offline browsing.
          </p>
          <p className="mt-4 text-sm text-cream/45">
            Shareable install page:{' '}
            <a
              href={APP_URL}
              className="text-gold/90 underline decoration-gold/40 underline-offset-4 hover:text-gold"
            >
              velanera.co/#app
            </a>
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

        <div className="fade-up mt-12 flex flex-col items-stretch justify-center gap-3 sm:flex-row sm:items-center">
          <button
            type="button"
            onClick={() => void shareLink()}
            className="border border-gold bg-gold px-8 py-3 text-sm tracking-[0.22em] text-ink uppercase transition-colors hover:bg-transparent hover:text-gold"
          >
            Share velanera.co
          </button>
          <button
            type="button"
            onClick={() => void copyLink()}
            className="border border-gold/50 px-8 py-3 text-sm tracking-[0.22em] text-cream uppercase transition-colors hover:border-gold hover:text-gold"
          >
            {copied ? 'Link copied' : 'Copy install link'}
          </button>
        </div>

        <p className="fade-up mt-10 text-xs tracking-[0.18em] text-cream/40 uppercase">
          Then open Velanera from your Home Screen like any other app
        </p>
      </div>
    </section>
  )
}
