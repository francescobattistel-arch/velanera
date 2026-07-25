import SwiftUI

/// Elegant vertical history of voice concierge turns — Dynamic Type friendly.
struct TranscriptHistoryView: View {
    let messages: [ConciergeMessage]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: VelaneraSpacing.md) {
                    ForEach(messages) { message in
                        messageRow(message)
                            .id(message.id)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                    }
                }
                .padding(.vertical, VelaneraSpacing.md)
            }
            .scrollIndicators(.hidden)
            .onChange(of: messages.count) { _, _ in
                if let last = messages.last {
                    withAnimation(ProMotion.smooth()) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func messageRow(_ message: ConciergeMessage) -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.role == .guest { Spacer(minLength: 36) }

            if message.role != .guest {
                Image("ConciergeHost")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                    .overlay { Circle().strokeBorder(VelaneraColors.goldStroke, lineWidth: 1) }
                    .accessibilityHidden(true)
            }

            VStack(alignment: message.role == .guest ? .trailing : .leading, spacing: 6) {
                Text(message.role == .guest ? "You" : "Concierge")
                    .font(VelaneraTypography.labelScaled)
                    .tracking(1.1)
                    .foregroundStyle(VelaneraColors.gold)

                Text(message.text)
                    .font(VelaneraTypography.bodyScaled)
                    .foregroundStyle(VelaneraColors.ivory)
                    .multilineTextAlignment(message.role == .guest ? .trailing : .leading)
                    .fixedSize(horizontal: false, vertical: true)

                if message.isSpecialRequest {
                    Text("Sent for staff review")
                        .font(VelaneraTypography.labelScaled)
                        .foregroundStyle(VelaneraColors.softGold)
                }
            }
            .padding(.horizontal, VelaneraSpacing.md)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: VelaneraSpacing.radiusMd, style: .continuous)
                    .fill(message.role == .guest ? VelaneraColors.elevated : VelaneraColors.glassFill)
                    .overlay {
                        RoundedRectangle(cornerRadius: VelaneraSpacing.radiusMd, style: .continuous)
                            .strokeBorder(
                                message.role == .guest ? VelaneraColors.goldStroke : VelaneraColors.glassStroke,
                                lineWidth: 1
                            )
                    }
            }
            .accessibilityElement(children: .combine)

            if message.role != .guest { Spacer(minLength: 36) }
        }
    }
}
