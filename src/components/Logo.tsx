import logoUrl from '../assets/logo-velanera.png'

type LogoProps = {
  className?: string
}

export default function Logo({ className }: LogoProps) {
  return (
    <img
      src={logoUrl}
      alt="Velanera"
      className={`w-auto select-none ${className ?? 'h-12'}`}
      draggable={false}
    />
  )
}
