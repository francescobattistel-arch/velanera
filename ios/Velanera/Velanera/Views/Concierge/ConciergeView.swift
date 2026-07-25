import SwiftUI

/// Voice-first AI Concierge — primary interaction for iPhone 17 portrait.
struct ConciergeView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var namespace: Namespace.ID

    @State private var viewModel: ConciergeViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                background

                VStack(spacing: 0) {
                    header
                        .padding(.top, 8)

                    suggestedPrompts
                        .padding(.top, 8)

                    TranscriptHistoryView(messages: viewModel?.messages ?? [])
                        .frame(maxHeight: .infinity)

                    voiceStage
                        .padding(.bottom, DeviceLayout.floatingBottomClearance)
                }
                .safeAreaPadding(.horizontal, DeviceLayout.contentInset)
            }
            .toolbar(.hidden, for: .navigationBar)
            .velaneraRouter(selectedTab: .constant(.home))
            .statusBarHidden(false)
        }
        .persistentSystemOverlays(.automatic)
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

    private var background: some View {
        ZStack {
            VelaneraColors.matteBlack.ignoresSafeArea()
            RadialGradient(
                colors: [
                    Color(hex: 0x2A2318).opacity(0.55),
                    VelaneraColors.matteBlack,
                    VelaneraColors.matteBlack
                ],
                center: .top,
                startRadius: 20,
                endRadius: 520
            )
            .ignoresSafeArea()

            if viewModel?.isRecording == true {
                Circle()
                    .fill(VelaneraColors.gold.opacity(0.08))
                    .frame(width: 340, height: 340)
                    .blur(radius: 50)
                    .offset(y: 180)
                    .allowsHitTesting(false)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Velanera")
                    .font(VelaneraTypography.brand(28))
                    .foregroundStyle(VelaneraColors.ivory)
                    .tracking(6)
                Text("Your concierge is listening")
                    .font(VelaneraTypography.captionScaled)
                    .foregroundStyle(VelaneraColors.secondaryText)
            }
            .accessibilityElement(children: .combine)

            Spacer(minLength: 8)

            Menu {
                NavigationLink(value: AppDestination.staffRequests) {
                    Label("Staff requests", systemImage: "tray.full")
                }
                NavigationLink(value: AppDestination.conciergeArchive) {
                    Label("Archive", systemImage: "waveform")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(VelaneraColors.champagne)
                    .frame(width: DeviceLayout.minTouchTarget, height: DeviceLayout.minTouchTarget)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Concierge options")

            Button {
                HapticFeedback.light()
                environment.voicePlayback.stop()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(VelaneraColors.champagne)
                    .frame(width: DeviceLayout.minTouchTarget, height: DeviceLayout.minTouchTarget)
                    .glassBackground(cornerRadius: 24, opacity: 0.05)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close concierge")
        }
        .matchedGeometryEffect(id: "concierge-fab", in: namespace)
    }

    @ViewBuilder
    private var suggestedPrompts: some View {
        if viewModel?.isRecording != true, viewModel?.isProcessing != true {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel?.suggestedPrompts ?? [], id: \.self) { prompt in
                        Button {
                            HapticFeedback.light()
                            Task { await viewModel?.sendSuggestion(prompt, modelContext: modelContext) }
                        } label: {
                            Text(prompt)
                                .font(VelaneraTypography.captionScaled)
                                .foregroundStyle(VelaneraColors.champagne)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .frame(minHeight: DeviceLayout.minTouchTarget)
                                .background(VelaneraColors.elevated.opacity(0.9))
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule().strokeBorder(VelaneraColors.glassStroke, lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private var voiceStage: some View {
        VStack(spacing: VelaneraSpacing.md) {
            WaveformView(
                levels: viewModel?.audioLevels ?? Array(repeating: 0.12, count: 28),
                isActive: viewModel?.isRecording == true
            )
            .frame(height: 56)
            .opacity((viewModel?.isRecording == true || viewModel?.isProcessing == true) ? 1 : 0.3)
            .animation(reduceMotion ? nil : ProMotion.smooth(duration: 0.25), value: viewModel?.isRecording)

            if let live = viewModel?.liveTranscript, !live.isEmpty {
                Text(live)
                    .font(VelaneraTypography.bodyScaled)
                    .foregroundStyle(VelaneraColors.champagne)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .transition(.opacity)
                    .accessibilityLabel("Live transcription")
            }

            if let error = viewModel?.errorMessage {
                Text(error)
                    .font(VelaneraTypography.captionScaled)
                    .foregroundStyle(VelaneraColors.danger)
                    .multilineTextAlignment(.center)
            }

            if let request = viewModel?.latestStaffRequest {
                NavigationLink(value: AppDestination.staffRequests) {
                    Text("Staff review · \(request.summary)")
                        .font(VelaneraTypography.labelScaled)
                        .foregroundStyle(VelaneraColors.gold)
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 44)
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
            .padding(.top, 4)
        }
    }
}
