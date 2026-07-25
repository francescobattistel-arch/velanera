import { useEffect, useState } from 'react'

const APP_URL = 'https://velanera.co/velanera-app/'
const APP_PATH = '/velanera-app/'

const steps = [
  'Open the interactive prototype on your iPhone',
  'Walk through onboarding, then hold the host to talk',
  'Explore Menu, Lounge, Book, Membership, and Profile',
  'Optional: Safari → Share → Add to Home Screen for fullscreen',
]

export default function InstallApp() {
  const [copied, setCopied] = useState(false)

  useEffect(() => {
    if (window.location.hash !== '#app') return
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
      window.prompt('Copy this link:', APP_URL)
    }
  }

  async function shareLink() {
    if (typeof navigator.share === 'function') {
      try {
        await navigator.share({
          title: 'Velanera — App Prototype',
          text: 'Try the Velanera voice-first hospitality experience.',
          url: APP_URL,
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
            iPhone · interactive prototype
          </p>
          <h2 id="app-heading" className="text-4xl md:text-5xl">
            Get the App
          </h2>
          <div className="hairline mx-auto my-7 h-px w-28" />
          <p className="text-cream/65">
            Preview the native Velanera experience — voice Concierge, menu,
            lounge, booking, and membership — in a high-fidelity phone
            prototype. No App Store required.
          </p>
          <p className="mt-5">
            <a
              href={APP_PATH}
              className="inline-block border border-gold bg-gold px-8 py-3 text-sm tracking-[0.22em] text-ink uppercase transition-colors hover:bg-transparent hover:text-gold"
            >
              Open app prototype
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
            className="border border-gold/50 px-8 py-3 text-sm tracking-[0.22em] text-cream uppercase transition-colors hover:border-gold hover:text-gold"
          >
            Share prototype
          </button>
          <button
            type="button"
            onClick={() => void copyLink()}
            className="border border-gold/50 px-8 py-3 text-sm tracking-[0.22em] text-cream uppercase transition-colors hover:border-gold hover:text-gold"
          >
            {copied ? 'Link copied' : 'Copy prototype link'}
          </button>
        </div>

        <p className="fade-up mt-10 text-xs tracking-[0.18em] text-cream/40 uppercase">
          Native SwiftUI build installs later via Xcode / TestFlight
        </p>
      </div>
    </section>
  )
}
