# Velanera iOS — Implementation Phases

## Phase 1 — Foundation ✅

Design system, navigation shell, reusable components, theme, assets, Xcode project.

## Phase 2 — Voice Concierge ✅

Speech recognition, voice playback, conversation engine, mock AI, press-and-hold UX, transcript history.

## Phase 3 — Guest Features ✅

Home, Restaurant menu, Lounge, Booking, Membership card/QR, Profile with Apple Sign In + Google placeholder.

## Phase 4 — Platform Scaffolding ✅

Configurable APIClient, mock backend, auth/notifications/payments/analytics services, OpenAI integration notes (server-side keys only).

## Next (post-scaffold)

1. Open on macOS Xcode, set Development Team, run on simulator.
2. Replace placeholder venue content (address, phone, photography assets).
3. Point `VELANERA_USE_MOCK_API` to `false` when backend is ready.
4. Wire real Google Sign-In SDK if required.
5. Add App Store screenshots / privacy nutrition labels.
