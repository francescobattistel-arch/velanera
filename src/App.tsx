import Navbar from './components/Navbar'
import Hero from './components/Hero'
import Lounge from './components/Lounge'
import Booking from './components/Booking'
import Contacts from './components/Contacts'
import Footer from './components/Footer'
import { useReveal } from './hooks/useReveal'

export default function App() {
  useReveal()

  return (
    <>
      <Navbar />
      <main>
        <Hero />
        <Lounge />
        <Booking />
        <Contacts />
      </main>
      <Footer />
    </>
  )
}
