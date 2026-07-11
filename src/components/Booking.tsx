import { useState, type FormEvent } from 'react'

const RESERVATIONS_EMAIL = 'reservations@velanera.co'

type Form = {
  name: string
  email: string
  phone: string
  date: string
  time: string
  guests: string
  notes: string
}

const empty: Form = {
  name: '',
  email: '',
  phone: '',
  date: '',
  time: '19:30',
  guests: '2',
  notes: '',
}

export default function Booking() {
  const [form, setForm] = useState<Form>(empty)
  const [submitted, setSubmitted] = useState<Form | null>(null)

  const update = (key: keyof Form) => (e: { target: { value: string } }) =>
    setForm((f) => ({ ...f, [key]: e.target.value }))

  const onSubmit = (e: FormEvent) => {
    e.preventDefault()
    setSubmitted(form)
  }

  const mailtoHref = submitted
    ? `mailto:${RESERVATIONS_EMAIL}?subject=${encodeURIComponent(
        `Reservation — ${submitted.name} (${submitted.guests} guests)`,
      )}&body=${encodeURIComponent(
        `Name: ${submitted.name}\nEmail: ${submitted.email}\nPhone: ${submitted.phone}\n` +
          `Date: ${submitted.date}\nTime: ${submitted.time}\nGuests: ${submitted.guests}\n` +
          `Notes: ${submitted.notes || '—'}`,
      )}`
    : '#'

  const field =
    'w-full border border-gold/25 bg-ink px-4 py-3 text-cream placeholder-cream/30 outline-none transition-colors focus:border-gold'

  return (
    <section id="booking" className="relative py-28">
      <div className="absolute inset-0 -z-10 bg-[radial-gradient(circle_at_50%_0%,rgba(201,162,75,0.10),transparent_55%)]" />
      <div className="mx-auto max-w-2xl px-6">
        <div className="fade-up text-center">
          <p className="mb-4 text-xs tracking-luxe text-gold/80 uppercase">Reservations</p>
          <h2 className="text-4xl md:text-5xl">Book your table</h2>
          <div className="hairline mx-auto my-7 h-px w-28" />
          <p className="text-cream/70">
            Reserve online and our team will confirm shortly. For same-day tables,
            please call{' '}
            <a href="tel:+15550100" className="text-gold hover:underline">
              +1 (555) 0100
            </a>
            .
          </p>
        </div>

        {submitted ? (
          <div className="fade-up in mt-12 border border-gold/30 bg-ink-card/70 p-10 text-center">
            <p className="text-gold-gradient font-serif text-3xl">Thank you, {submitted.name}!</p>
            <p className="mt-4 text-cream/75">
              We&rsquo;ve received your request for{' '}
              <span className="text-gold">{submitted.guests}</span> guests on{' '}
              <span className="text-gold">{submitted.date || 'your selected date'}</span> at{' '}
              <span className="text-gold">{submitted.time}</span>.
            </p>
            <p className="mt-2 text-sm text-cream/50">
              A confirmation will be sent to {submitted.email || 'your email'}.
            </p>
            <div className="mt-8 flex flex-col justify-center gap-4 sm:flex-row">
              <a
                href={mailtoHref}
                className="border border-gold bg-gold px-7 py-3 text-sm tracking-[0.2em] text-ink uppercase transition-colors hover:bg-transparent hover:text-gold"
              >
                Send confirmation email
              </a>
              <button
                type="button"
                onClick={() => {
                  setSubmitted(null)
                  setForm(empty)
                }}
                className="border border-gold/40 px-7 py-3 text-sm tracking-[0.2em] text-cream uppercase transition-colors hover:border-gold hover:text-gold"
              >
                New reservation
              </button>
            </div>
          </div>
        ) : (
          <form onSubmit={onSubmit} className="fade-up mt-12 grid gap-5 sm:grid-cols-2">
            <input
              className={field}
              placeholder="Full name"
              required
              value={form.name}
              onChange={update('name')}
            />
            <input
              className={field}
              type="email"
              placeholder="Email"
              required
              value={form.email}
              onChange={update('email')}
            />
            <input
              className={field}
              type="tel"
              placeholder="Phone"
              value={form.phone}
              onChange={update('phone')}
            />
            <select className={field} value={form.guests} onChange={update('guests')}>
              {['1', '2', '3', '4', '5', '6', '7', '8', '9+'].map((n) => (
                <option key={n} value={n} className="bg-ink">
                  {n} {n === '1' ? 'guest' : 'guests'}
                </option>
              ))}
            </select>
            <input
              className={field}
              type="date"
              required
              value={form.date}
              onChange={update('date')}
            />
            <input
              className={field}
              type="time"
              required
              value={form.time}
              onChange={update('time')}
            />
            <textarea
              className={`${field} sm:col-span-2`}
              rows={3}
              placeholder="Special requests (occasion, seating, dietary needs)"
              value={form.notes}
              onChange={update('notes')}
            />
            <button
              type="submit"
              className="border border-gold bg-gold px-8 py-3 text-sm tracking-[0.22em] text-ink uppercase transition-colors hover:bg-transparent hover:text-gold sm:col-span-2"
            >
              Request Reservation
            </button>
          </form>
        )}
      </div>
    </section>
  )
}
