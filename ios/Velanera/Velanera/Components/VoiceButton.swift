import SwiftUI

/// Large press-and-hold concierge control — elegant host portrait as the voice affordance.
struct VoiceButton: View {
    var isRecording: Bool
    var isProcessing: Bool
    var onPressBegan: () -> Void
    var onPressEnded: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false
    @State private var pressed = false

    private var hostSize: CGFloat { DeviceLayout.conciergeHostSize }
    private var pulseSize: CGFloat { DeviceLayout.conciergePulseSize }

    var body: some View {
        ZStack {
            if isRecording {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                VelaneraColors.gold.opacity(0.15),
                                VelaneraColors.champagne.opacity(0.55),
                                VelaneraColors.gold.opacity(0.15)
                            ],
                            center: .center
                        ),
                        lineWidth: 2
                    )
                    .frame(width: pulseSize, height: pulseSize)
                    .scaleEffect(pulse ? 1.08 : 0.96)
                    .opacity(pulse ? 0.35 : 0.85)
            }

            Circle()
                .fill(VelaneraColors.gold.opacity(isRecording ? 0.22 : 0.08))
                .frame(width: hostSize + 18, height: hostSize + 18)
                .blur(radius: isRecording ? 10 : 4)

            hostPortrait
                .frame(width: hostSize, height: hostSize)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    VelaneraColors.champagne.opacity(0.95),
                                    VelaneraColors.gold.opacity(0.35),
                                    VelaneraColors.champagne.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isRecording ? 3 : 1.5
                        )
                }
                .shadow(color: VelaneraColors.gold.opacity(isRecording ? 0.45 : 0.18), radius: isRecording ? 28 : 16, y: 8)
                .scaleEffect(pressed || isRecording ? 1.04 : 1)
                .overlay {
                    if isProcessing {
                        Circle()
                            .fill(VelaneraColors.matteBlack.opacity(0.45))
                        ProgressView()
                            .tint(VelaneraColors.champagne)
                            .scaleEffect(1.35)
                    }
                }
                .overlay(alignment: .bottom) {
                    statusBadge
                        .offset(y: 18)
                }

            if isRecording {
                Image(systemName: "waveform")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(VelaneraColors.champagne)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
                    .offset(x: hostSize * 0.38, y: -hostSize * 0.38)
                    .symbolEffect(.variableColor.iterative, isActive: true)
            }
        }
        .frame(width: pulseSize + 24, height: pulseSize + 36)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !pressed {
                        pressed = true
                        HapticFeedback.medium()
                    }
                    if !isRecording && !isProcessing {
                        onPressBegan()
                    }
                }
                .onEnded { _ in
                    pressed = false
                    if isRecording {
                        HapticFeedback.light()
                        onPressEnded()
                    }
                }
        )
        .animation(reduceMotion ? nil : ProMotion.spring(), value: isRecording)
        .animation(reduceMotion ? nil : ProMotion.spring(), value: pressed)
        .onChange(of: isRecording) { _, recording in
            guard !reduceMotion else { return }
            if recording {
                withAnimation(ProMotion.recordingPulse()) { pulse = true }
            } else {
                pulse = false
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isRecording ? "Release to send your request" : "Hold to talk to the Velanera concierge")
        .accessibilityAddTraits(.startsMediaSession)
        .accessibilityHint("Press and hold, speak your request, then release.")
    }

    private var hostPortrait: some View {
        Image("ConciergeHost")
            .resizable()
            .scaledToFill()
            .overlay {
                LinearGradient(
                    colors: [
                        .clear,
                        VelaneraColors.matteBlack.opacity(isRecording ? 0.15 : 0.28)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
    }

    private var statusBadge: some View {
        Text(isProcessing ? "Thinking" : isRecording ? "Listening" : "Hold to Talk")
            .font(VelaneraTypography.labelScaled)
            .tracking(1.4)
            .textCase(.uppercase)
            .foregroundStyle(isRecording || isProcessing ? VelaneraColors.matteBlack : VelaneraColors.champagne)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if isRecording || isProcessing {
                    Capsule().fill(
                        LinearGradient(
                            colors: [VelaneraColors.champagne, VelaneraColors.gold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                } else {
                    Capsule().fill(VelaneraColors.elevated.opacity(0.92))
                }
            }
            .overlay {
                Capsule().strokeBorder(VelaneraColors.goldStroke, lineWidth: 1)
            }
            .minimumScaleFactor(0.8)
    }
}
