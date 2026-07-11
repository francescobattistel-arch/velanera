type LogoProps = {
  className?: string
  showWordmark?: boolean
}

export default function Logo({ className, showWordmark = true }: LogoProps) {
  return (
    <span className={`inline-flex items-center gap-3 ${className ?? ''}`}>
      <svg
        viewBox="0 0 100 100"
        className="h-9 w-9 shrink-0"
        role="img"
        aria-label="Velanera sail emblem"
      >
        <defs>
          <linearGradient id="sail" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#e7c977" />
            <stop offset="60%" stopColor="#c9a24b" />
            <stop offset="100%" stopColor="#a07d2c" />
          </linearGradient>
        </defs>
        <circle cx="50" cy="45" r="31" fill="none" stroke="url(#sail)" stroke-width="3.5" />
        <path
          d="M50 18 C59 32 61 50 56 63 L43 63 C43 49 45 31 50 18 Z"
          fill="url(#sail)"
        />
        <path
          d="M28 60 q11 7 22 0 q11 -7 22 0"
          fill="none"
          stroke="url(#sail)"
          stroke-width="3.5"
          stroke-linecap="round"
        />
      </svg>
      {showWordmark && (
        <span className="text-gold-gradient font-serif text-2xl tracking-[0.3em]">
          VELANERA
        </span>
      )}
    </span>
  )
}
