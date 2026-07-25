import SwiftUI

/// Elegant vertical history of voice concierge turns.
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
                .pagePadding()
                .padding(.vertical, VelaneraSpacing.md)
            }
            .onChange(of: messages.count) { _, _ in
                if let last = messages.last {
                    withAnimation(VelaneraTheme.animationSmooth) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func messageRow(_ message: ConciergeMessage) -> some View {
        HStack {
            if message.role == .guest { Spacer(minLength: 48) }

            VStack(alignment: message.role == .guest ? .trailing : .leading, spacing: 6) {
                Text(message.role == .guest ? "You" : "Velanera")
                    .font(VelaneraTypography.label(10))
                    .tracking(1.2)
                    .foregroundStyle(VelaneraColors.gold)

                Text(message.text)
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.ivory)
                    .multilineTextAlignment(message.role == .guest ? .trailing : .leading)

                if message.isSpecialRequest {
                    Text("Sent for staff review")
                        .font(VelaneraTypography.label(10))
                        .foregroundStyle(VelaneraColors.softGold)
                }
            }
            .padding(VelaneraSpacing.md)
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

            if message.role != .guest { Spacer(minLength: 48) }
        }
    }
}
