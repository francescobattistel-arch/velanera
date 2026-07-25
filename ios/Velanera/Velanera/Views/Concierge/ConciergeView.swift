import SwiftUI

/// Luxury voice concierge — press and hold, no chat composer.
struct ConciergeView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var namespace: Namespace.ID

    @State private var viewModel: ConciergeViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                VelaneraColors.ambientGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                    suggestedPrompts
                    TranscriptHistoryView(messages: viewModel?.messages ?? [])
                    Spacer(minLength: VelaneraSpacing.md)
                    voiceStage
                }
            }
            .velaneraRouter(selectedTab: .constant(.home))
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ConciergeViewModel(
                    speechRecognizer: environment.speechRecognizer,
                    voicePlayback: environment.voicePlayback,
                    conversationEngine: environment.conversationEngine,
                    permissions: environment.permissionService,
                    analytics: environment.analyticsService,
                    apiClient: environment.apiClient,
                    settingsStore: environment.settingsStore
                )
            }
            viewModel?.onAppear(modelContext: modelContext)
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
            Menu {
                NavigationLink(value: AppDestination.staffRequests) {
                    Label("Staff requests", systemImage: "tray.full")
                }
                NavigationLink(value: AppDestination.conciergeArchive) {
                    Label("Archive", systemImage: "waveform")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(VelaneraColors.champagne)
                    .padding(10)
            }
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

    @ViewBuilder
    private var suggestedPrompts: some View {
        if viewModel?.isRecording != true, viewModel?.isProcessing != true {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel?.suggestedPrompts ?? [], id: \.self) { prompt in
                        Button {
                            Task { await viewModel?.sendSuggestion(prompt, modelContext: modelContext) }
                        } label: {
                            Text(prompt)
                                .font(VelaneraTypography.label(11))
                                .foregroundStyle(VelaneraColors.champagne)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(VelaneraColors.elevated)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .pagePadding()
            }
            .padding(.vertical, VelaneraSpacing.sm)
        }
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
                NavigationLink(value: AppDestination.staffRequests) {
                    Text("Staff review created · \(request.summary)")
                        .font(VelaneraTypography.label(11))
                        .foregroundStyle(VelaneraColors.gold)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
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
