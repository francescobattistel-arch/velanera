import SwiftUI

/// Press-and-hold microphone control for the AI Concierge.
struct VoiceButton: View {
    var isRecording: Bool
    var isProcessing: Bool
    var onPressBegan: () -> Void
    var onPressEnded: () -> Void

    @State private var pulse = false

    var body: some View {
        ZStack {
            if isRecording {
                Circle()
                    .stroke(VelaneraColors.gold.opacity(0.35), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulse ? 1.18 : 1)
                    .opacity(pulse ? 0.2 : 0.7)
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            isRecording ? VelaneraColors.gold : VelaneraColors.elevated,
                            isRecording ? VelaneraColors.softGold : VelaneraColors.nearBlack
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 60
                    )
                )
                .frame(width: 96, height: 96)
                .overlay {
                    Circle()
                        .strokeBorder(VelaneraColors.goldStroke, lineWidth: 1.5)
                }
                .shadow(color: VelaneraColors.gold.opacity(isRecording ? 0.35 : 0.12), radius: 18, y: 4)
                .overlay {
                    Group {
                        if isProcessing {
                            ProgressView()
                                .tint(VelaneraColors.matteBlack)
                        } else {
                            Image(systemName: isRecording ? "waveform" : "mic.fill")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(isRecording ? VelaneraColors.matteBlack : VelaneraColors.champagne)
                                .symbolEffect(.variableColor.iterative, isActive: isRecording)
                        }
                    }
                }
                .scaleEffect(isRecording ? 1.06 : 1)
                .animation(VelaneraTheme.animationSpring, value: isRecording)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isRecording && !isProcessing {
                        onPressBegan()
                    }
                }
                .onEnded { _ in
                    if isRecording {
                        onPressEnded()
                    }
                }
        )
        .onChange(of: isRecording) { _, recording in
            if recording {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            } else {
                pulse = false
            }
        }
        .accessibilityLabel(isRecording ? "Release to send" : "Hold to speak")
    }
}
