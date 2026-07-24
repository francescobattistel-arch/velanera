/**
 * Web Push scaffolding for Velanera.
 *
 * Graceful no-op when VITE_VAPID_PUBLIC_KEY is unset or the browser lacks
 * PushManager / Notification support (common on iOS Safari historically;
 * Web Push on iOS requires a Home Screen–installed PWA on iOS 16.4+).
 *
 * To enable:
 * 1. Generate VAPID keys: `npx web-push generate-vapid-keys`
 * 2. Set `VITE_VAPID_PUBLIC_KEY` in `.env` (public key only in the client).
 * 3. Keep the private key on a server that calls `web-push` to send messages.
 * 4. POST the subscription JSON from `subscribeToPush()` to your backend.
 */

function urlBase64ToUint8Array(base64String: string): Uint8Array {
  const padding = '='.repeat((4 - (base64String.length % 4)) % 4)
  const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/')
  const raw = atob(base64)
  const output = new Uint8Array(raw.length)
  for (let i = 0; i < raw.length; i += 1) {
    output[i] = raw.charCodeAt(i)
  }
  return output
}

export function isPushConfigured(): boolean {
  return Boolean(import.meta.env.VITE_VAPID_PUBLIC_KEY?.trim())
}

export function isPushSupported(): boolean {
  return (
    typeof window !== 'undefined' &&
    'serviceWorker' in navigator &&
    'PushManager' in window &&
    'Notification' in window
  )
}

export async function requestNotificationPermission(): Promise<NotificationPermission> {
  if (!isPushSupported()) return 'denied'
  if (Notification.permission === 'granted') return 'granted'
  if (Notification.permission === 'denied') return 'denied'
  return Notification.requestPermission()
}

export async function subscribeToPush(): Promise<PushSubscription | null> {
  if (!isPushConfigured() || !isPushSupported()) return null

  const permission = await requestNotificationPermission()
  if (permission !== 'granted') return null

  const registration = await navigator.serviceWorker.ready
  const existing = await registration.pushManager.getSubscription()
  if (existing) return existing

  const key = import.meta.env.VITE_VAPID_PUBLIC_KEY?.trim()
  if (!key) return null

  return registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: urlBase64ToUint8Array(key) as BufferSource,
  })
}

export async function unsubscribeFromPush(): Promise<boolean> {
  if (!isPushSupported()) return false
  const registration = await navigator.serviceWorker.ready
  const subscription = await registration.pushManager.getSubscription()
  if (!subscription) return false
  return subscription.unsubscribe()
}
