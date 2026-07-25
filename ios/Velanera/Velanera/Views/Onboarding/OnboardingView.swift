import SwiftUI

/// First-launch orientation for the voice-first iPhone experience.
struct OnboardingView: View {
    var onContinue: () -> Void

    @State private var page = 0

    private let pages: [(title: String, body: String, symbol: String)] = [
        (
            "Welcome to Velanera",
            "A luxury restaurant & lounge companion — menus, evenings, membership, and reservations in one place.",
            "sparkles"
        ),
        (
            "Your AI Concierge",
            "Hold the host portrait to speak. Ask for tables, lounge VIP, wine, dress code, or something bespoke.",
            "waveform"
        ),
        (
            "Explore at your pace",
            "Browse Restaurant and Lounge, book when ready, and keep favourites and reservations on this device.",
            "fork.knife"
        )
    ]

    var body: some View {
        ZStack {
            VelaneraColors.matteBlack.ignoresSafeArea()
            RadialGradient(
                colors: [Color(hex: 0x2A2318).opacity(0.7), VelaneraColors.matteBlack],
                center: .top,
                startRadius: 40,
                endRadius: 480
            )
            .ignoresSafeArea()

            VStack(spacing: VelaneraSpacing.xl) {
                Spacer()

                Image("ConciergeHost")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
                    .overlay {
                        Circle().strokeBorder(VelaneraColors.goldStroke, lineWidth: 1.5)
                    }
                    .shadow(color: VelaneraColors.gold.opacity(0.35), radius: 24, y: 8)
                    .luxuryAppear()

                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                        VStack(spacing: VelaneraSpacing.md) {
                            Image(systemName: item.symbol)
                                .font(.system(size: 28, weight: .ultraLight))
                                .foregroundStyle(VelaneraColors.gold)
                            Text(item.title)
                                .font(VelaneraTypography.titleScaled)
                                .foregroundStyle(VelaneraColors.ivory)
                                .multilineTextAlignment(.center)
                            Text(item.body)
                                .font(VelaneraTypography.bodyScaled)
                                .foregroundStyle(VelaneraColors.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, DeviceLayout.contentInset)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 220)

                Spacer()

                LuxuryButton(
                    title: page < pages.count - 1 ? "Continue" : "Meet the Concierge",
                    systemImage: page < pages.count - 1 ? "arrow.right" : "waveform"
                ) {
                    HapticFeedback.light()
                    if page < pages.count - 1 {
                        withAnimation(ProMotion.spring()) { page += 1 }
                    } else {
                        onContinue()
                    }
                }
                .pagePadding()
                .padding(.bottom, DeviceLayout.floatingBottomClearance + 12)
            }
        }
        .preferredColorScheme(.dark)
    }
}
