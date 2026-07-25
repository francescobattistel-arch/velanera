# Velanera → TestFlight

## Prerequisites

1. Apple Developer Program membership (you have this).
2. App record in [App Store Connect](https://appstoreconnect.apple.com) with bundle ID `co.velanera.app`.
3. App Store Connect API key (Users and Access → Integrations → App Store Connect API) with **App Manager** or **Admin**.
4. macOS with Xcode 16+ **or** GitHub Actions `macos-14` runner.

## Secrets

Add these as GitHub Actions secrets (repo Settings → Secrets) and/or Cursor Cloud Agent secrets:

| Secret | Purpose |
|---|---|
| `APPLE_TEAM_ID` | 10-character Team ID |
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer UUID |
| `APP_STORE_CONNECT_API_KEY` | `.p8` private key contents (PEM text) |

Optional:

| Secret | Purpose |
|---|---|
| `VELANERA_BUNDLE_ID` | Defaults to `co.velanera.app` |
| `TESTFLIGHT_CHANGELOG` | What Testers see |

## One-time App Store Connect setup

1. Certificates, Identifiers & Profiles → Identifiers → register `co.velanera.app`.
2. Enable **Sign in with Apple** on that App ID.
3. App Store Connect → My Apps → **+** → iOS app, SKU e.g. `velanera-ios`, bundle `co.velanera.app`.
4. Create an internal testing group and add yourself.

## Upload via GitHub Actions

Workflow: `.github/workflows/ios-testflight.yml`

- Manual: Actions → **iOS TestFlight** → Run workflow
- Or push a tag: `ios-beta-*`

## Upload from a Mac

```bash
cd ios/Velanera
bundle install   # if using Bundler
export APPLE_TEAM_ID=XXXXXXXXXX
export APP_STORE_CONNECT_API_KEY_ID=...
export APP_STORE_CONNECT_API_ISSUER_ID=...
export APP_STORE_CONNECT_API_KEY="$(cat AuthKey_XXXX.p8)"
fastlane beta
```

Or open `Velanera.xcodeproj`, set Team, Product → Archive → Distribute App → TestFlight.

## This Linux cloud agent

Cannot run `xcodebuild` or upload IPA from this VM. Use:

- a Mac with Xcode / Remote Control (“My Machines”), or
- the GitHub Actions workflow above once secrets are present.
