# Velanera iOS

Native SwiftUI application for **Velanera Restaurant & Lounge**.

This project is completely separate from `ios/VelaneraCMO/`. Do not mix the two codebases.

## Requirements

- macOS with **Xcode 16+**
- iOS **18.0+** deployment target
- Swift 5.10+ / SwiftUI

## Reference device

Optimised first for:

- **iPhone 17**
- **iOS 26.5.2**
- **Portrait** only
- **Dark Mode** by default

iPad and landscape are deferred until the iPhone experience is complete. Voice Concierge is the primary interaction (full-screen on launch).

## Interactive web prototype (no Mac)

A high-fidelity phone showcase of this app lives at:

- Local: `http://localhost:5173/velanera-app/` (with `npm run dev`)
- Production: `https://velanera.co/velanera-app/`

Source: `public/velanera-app/`. Use it to demo Concierge, Menu, Lounge, Booking, and Membership on an iPhone without Xcode.

### GPT / OpenAI Concierge

OpenAI keys must **never** ship in the iOS app or the static Pages site. Production path:

1. Client → Cloudflare Worker `POST /concierge/chat` (`workers/concierge/`)
2. Worker calls OpenAI (`gpt-4.1`) with the Velanera system prompt
3. Client renders the reply

See [`workers/concierge/README.md`](../../workers/concierge/README.md). Until `CONCIERGE_API_BASE` is set, the web prototype uses the on-device mock brain.

## Open (native)

```bash
open ios/Velanera/Velanera.xcodeproj
```

Select a simulator or device, then Run (`⌘R`).

## Architecture

- **SwiftUI** + **MVVM** + **NavigationStack**
- **SwiftData** for local reservations, favourites, transcripts, profile cache
- **Async/Await** + single **APIClient** (mock by default)
- **Speech** + **AVSpeechSynthesizer** for the voice AI Concierge
- Dark luxury design system (matte black / gold / glass)

### Folders

| Folder | Responsibility |
|---|---|
| `App/` | Composition root, tab shell |
| `Theme/` | Colours, type, spacing, glass |
| `Components/` | Reusable luxury UI |
| `Models/` | Domain + SwiftData models |
| `Views/` | Feature screens |
| `ViewModels/` | Presentation logic |
| `Networking/` | APIClient, mocks, configuration |
| `Speech/` | Recognition + playback |
| `Concierge/` | Conversation engine + persona |
| `Services/` | Auth, permissions, notifications, analytics, payments |

## Configuration

`Velanera/Info.plist`:

- `VELANERA_API_BASE_URL` — backend base URL
- `VELANERA_USE_MOCK_API` — `true` until production APIs are live

API keys must never be embedded in the app. OpenAI Responses API integration belongs on the server; see `Networking/OpenAIIntegrationNotes.swift`.

## Regenerate Xcode project

If you add/remove Swift files:

```bash
python3 ios/Velanera/Scripts/generate_xcodeproj.py
```

## Permissions

- Microphone — voice concierge
- Speech Recognition — live transcription
- Sign in with Apple — profile identity

## Build

```bash
xcodebuild -project ios/Velanera/Velanera.xcodeproj \
  -scheme Velanera \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

## TestFlight

See [`TESTFLIGHT.md`](./TESTFLIGHT.md). Summary:

1. Create App ID + App Store Connect app for `co.velanera.app` (enable Sign in with Apple).
2. Add ASC API key secrets to GitHub (`APPLE_TEAM_ID`, `APP_STORE_CONNECT_API_*`).
3. Run Actions → **iOS TestFlight**, or on a Mac: `cd ios/Velanera && fastlane beta`.
