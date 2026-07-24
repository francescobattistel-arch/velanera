import { useEffect } from 'react'
import Navbar from './components/Navbar'
import Hero from './components/Hero'
import Lounge from './components/Lounge'
import Booking from './components/Booking'
import Contacts from './components/Contacts'
import InstallApp from './components/InstallApp'
import Footer from './components/Footer'
import { useReveal } from './hooks/useReveal'

export default function App() {
  useReveal()

  // Hash targets (#app, etc.) are missing until React mounts — scroll after paint.
  useEffect(() => {
    const hash = window.location.hash
    if (!hash || hash.length < 2) return
    const id = hash.slice(1)
    const scroll = () => document.getElementById(id)?.scrollIntoView()
    requestAnimationFrame(scroll)
    const t = window.setTimeout(scroll, 100)
    return () => window.clearTimeout(t)
  }, [])

  return (
    <>
      <Navbar />
      <main>
        <Hero />
        <Lounge />
        <Booking />
        <Contacts />
        <InstallApp />
      </main>
      <Footer />
    </>
  )
}
