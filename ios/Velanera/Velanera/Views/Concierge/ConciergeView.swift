import SwiftUI

/// Luxury voice concierge — press and hold, no chat composer.
struct ConciergeView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var namespace: Namespace.ID

    @State private var viewModel: ConciergeViewModel?

    var body: some View {
        ZStack {
            VelaneraColors.ambientGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                TranscriptHistoryView(messages: viewModel?.messages ?? [])
                Spacer(minLength: VelaneraSpacing.md)
                voiceStage
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ConciergeViewModel(
                    speechRecognizer: environment.speechRecognizer,
                    voicePlayback: environment.voicePlayback,
                    conversationEngine: environment.conversationEngine,
                    permissions: environment.permissionService,
                    analytics: environment.analyticsService
                )
            }
            viewModel?.onAppear()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Concierge")
                    .font(VelaneraTypography.headline(22))
                    .foregroundStyle(VelaneraColors.ivory)
                Text("Hold to speak · Release to send")
                    .font(VelaneraTypography.caption())
                    .foregroundStyle(VelaneraColors.secondaryText)
            }
            Spacer()
            Button {
                environment.voicePlayback.stop()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(VelaneraColors.champagne)
                    .padding(10)
                    .glassBackground(cornerRadius: 20, opacity: 0.05)
            }
            .buttonStyle(.plain)
        }
        .pagePadding()
        .padding(.top, VelaneraSpacing.md)
        .matchedGeometryEffect(id: "concierge-fab", in: namespace)
    }

    private var voiceStage: some View {
        VStack(spacing: VelaneraSpacing.lg) {
            WaveformView(
                levels: viewModel?.audioLevels ?? Array(repeating: 0.12, count: 24),
                isActive: viewModel?.isRecording == true
            )
            .opacity((viewModel?.isRecording == true || viewModel?.isProcessing == true) ? 1 : 0.35)
            .animation(VelaneraTheme.animationSmooth, value: viewModel?.isRecording)

            if let live = viewModel?.liveTranscript, !live.isEmpty {
                Text(live)
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.champagne)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, VelaneraSpacing.xl)
                    .transition(.opacity)
            }

            if let error = viewModel?.errorMessage {
                Text(error)
                    .font(VelaneraTypography.caption())
                    .foregroundStyle(VelaneraColors.danger)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if let request = viewModel?.latestStaffRequest {
                Text("Staff review created · \(request.summary)")
                    .font(VelaneraTypography.label(11))
                    .foregroundStyle(VelaneraColors.gold)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }

            VoiceButton(
                isRecording: viewModel?.isRecording == true,
                isProcessing: viewModel?.isProcessing == true,
                onPressBegan: {
                    Task { await viewModel?.beginHoldToTalk() }
                },
                onPressEnded: {
                    Task { await viewModel?.endHoldToTalk(modelContext: modelContext) }
                }
            )

            Text(
                viewModel?.isRecording == true
                ? "Listening…"
                : viewModel?.isProcessing == true
                ? "Composing reply…"
                : "Press & hold"
            )
            .font(VelaneraTypography.label(11))
            .tracking(2)
            .foregroundStyle(VelaneraColors.tertiaryText)
            .textCase(.uppercase)
        }
        .padding(.bottom, VelaneraSpacing.xxl)
    }
}
