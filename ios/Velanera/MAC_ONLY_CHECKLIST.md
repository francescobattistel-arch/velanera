# Mac-only steps (after the app is feature-complete)

You do **not** need a Mac to keep developing in Cursor.  
When you later want the app on your iPhone, complete **only** these steps on any Mac with Xcode:

1. Install **Xcode** (Mac App Store) and open it once to finish setup / accept license.
2. Connect or select your **iPhone** (Developer Mode on if prompted).
3. Clone or pull this repo and open:
   ```bash
   open ios/Velanera/Velanera.xcodeproj
   ```
4. In **Signing & Capabilities**, choose your Apple Developer **Team** for target `Velanera`.
5. Confirm bundle ID `co.velanera.app` (or change it to one you own in the Developer portal).
6. Enable **Sign in with Apple** for that App ID in the Apple Developer portal (already declared in entitlements).
7. Select your iPhone as the run destination → **Run** (`⌘R`).
8. On the iPhone, trust the developer certificate if asked:  
   **Settings → General → VPN & Device Management**.

Optional later (not required to finish the app itself):

- Create the App Store Connect record and upload via Archive / TestFlight.
- Replace placeholder photography and real venue contact details.
- Point `VELANERA_USE_MOCK_API` to `false` when a real backend exists.

Nothing else in the Velanera feature set requires a Mac.
