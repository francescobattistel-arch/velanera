import SwiftUI

/// Native SwiftUI recreation of the velanera.co/velanera-app showcase intro.
struct PrototypeShowcaseView: View {
    var onContinue: () -> Void

    private let steps = [
        "Walk through onboarding",
        "Hold the host portrait to talk",
        "Explore tabs below"
    ]

    var body: some View {
        ZStack {
            VelaneraColors.matteBlack.ignoresSafeArea()

            // Soft warm ambient — matches the web stage glow without clutter.
            RadialGradient(
                colors: [
                    Color(hex: 0x2A2318).opacity(0.55),
                    VelaneraColors.matteBlack.opacity(0.2),
                    VelaneraColors.matteBlack
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 520
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 48)

                Text("VELANERA · iOS PROTOTYPE")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(3.2)
                    .foregroundStyle(VelaneraColors.gold)
                    .luxuryAppear()

                Text("Voice-first luxury hospitality")
                    .font(VelaneraTypography.display(36))
                    .foregroundStyle(VelaneraColors.ivory)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 14)
                    .luxuryAppear(delay: 0.06)

                Text("Interactive showcase of the native SwiftUI app — Concierge, Restaurant, Lounge, Booking & Membership. Optimised for iPhone.")
                    .font(VelaneraTypography.body(16))
                    .foregroundStyle(VelaneraColors.secondaryText)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 18)
                    .luxuryAppear(delay: 0.12)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .firstTextBaseline, spacing: 14) {
                            Text("\(index + 1).")
                                .font(.system(size: 16, weight: .medium, design: .serif))
                                .foregroundStyle(VelaneraColors.champagne)
                                .frame(width: 28, alignment: .leading)
                            Text(step)
                                .font(VelaneraTypography.body(16))
                                .foregroundStyle(VelaneraColors.ivory)
                        }
                    }
                }
                .padding(.top, 28)
                .luxuryAppear(delay: 0.18)

                Text("Open this page on your iPhone for the best feel. Native build still requires Xcode later — see MAC_ONLY_CHECKLIST.md.")
                    .font(VelaneraTypography.caption(13))
                    .foregroundStyle(VelaneraColors.tertiaryText)
                    .lineSpacing(3)
                    .padding(.top, 28)
                    .luxuryAppear(delay: 0.24)

                Spacer(minLength: 32)

                LuxuryButton(title: "Begin", systemImage: "waveform") {
                    HapticFeedback.light()
                    onContinue()
                }
                .luxuryAppear(delay: 0.3)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: 520, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .preferredColorScheme(.dark)
        .safeAreaPadding(.bottom, 16)
    }
}

#Preview("Prototype Showcase") {
    PrototypeShowcaseView(onContinue: {})
}
