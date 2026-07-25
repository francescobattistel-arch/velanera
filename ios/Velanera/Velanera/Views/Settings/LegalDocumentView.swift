import SwiftUI

enum LegalDocument: String, Hashable {
    case privacy
    case terms

    var title: String {
        switch self {
        case .privacy: "Privacy Policy"
        case .terms: "Terms of Use"
        }
    }

    var bodyText: String {
        switch self {
        case .privacy:
            """
            Velanera respects your privacy. Profile details, reservations, and voice transcripts stored on this device remain on-device unless you connect a future backend account.

            Microphone and speech recognition are used only for the AI Concierge. Audio is processed by Apple’s on-device / system speech services according to your iOS settings.

            Analytics events in this build are logged locally in DEBUG and are not sold. Push tokens are registered only when you enable notifications.

            Contact: reservations@velanera.co
            """
        case .terms:
            """
            Velanera Restaurant & Lounge provides this guest application for browsing menus, requesting reservations, membership information, and concierge assistance.

            Reservations and bespoke requests are subject to venue confirmation. The AI Concierge may create staff-review notes for unusual requests and does not guarantee availability.

            Membership benefits and pricing shown in mock mode are illustrative until live commerce is enabled.

            By using the app you agree to house policies including dress code and respectful conduct.

            Contact: reservations@velanera.co
            """
        }
    }
}

/// In-app legal copy so Settings does not depend on the website.
struct LegalDocumentView: View {
    let document: LegalDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text(document.title)
                    .font(VelaneraTypography.displayScaled)
                    .foregroundStyle(VelaneraColors.ivory)
                Text(document.bodyText)
                    .font(VelaneraTypography.bodyScaled)
                    .foregroundStyle(VelaneraColors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
