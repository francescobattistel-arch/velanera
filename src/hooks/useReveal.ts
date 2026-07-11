import { useEffect } from 'react'

// Adds an `in` class to any `.fade-up` element as it scrolls into view.
export function useReveal() {
  useEffect(() => {
    const els = Array.from(document.querySelectorAll<HTMLElement>('.fade-up'))
    if (!('IntersectionObserver' in window)) {
      els.forEach((el) => el.classList.add('in'))
      return
    }

    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            entry.target.classList.add('in')
            observer.unobserve(entry.target)
          }
        }
      },
      { threshold: 0.15 },
    )

    els.forEach((el) => observer.observe(el))
    return () => observer.disconnect()
  }, [])
}
