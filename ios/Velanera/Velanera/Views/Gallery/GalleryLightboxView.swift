import SwiftUI

/// Full-bleed gallery lightbox with caption.
struct GalleryLightboxView: View {
    @Environment(AppEnvironment.self) private var environment
    let assetID: UUID
    @State private var asset: GalleryAsset?
    @State private var appear = false

    var body: some View {
        ZStack {
            VelaneraColors.matteBlack.ignoresSafeArea()
            if let asset {
                VStack(spacing: VelaneraSpacing.lg) {
                    Spacer()
                    Image(systemName: asset.symbolName)
                        .font(.system(size: 72, weight: .ultraLight))
                        .foregroundStyle(VelaneraColors.gold)
                        .scaleEffect(appear ? 1 : 0.92)
                        .opacity(appear ? 1 : 0)
                    Text(asset.title)
                        .font(VelaneraTypography.title(28))
                        .foregroundStyle(VelaneraColors.ivory)
                    Text(asset.caption)
                        .font(VelaneraTypography.body(15))
                        .foregroundStyle(VelaneraColors.secondaryText)
                        .multilineTextAlignment(.center)
                    Text(asset.collection.displayName.uppercased())
                        .font(VelaneraTypography.label(11))
                        .foregroundStyle(VelaneraColors.gold)
                        .tracking(2)
                    Spacer()
                }
                .pagePadding()
            } else {
                ProgressView().tint(VelaneraColors.gold)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let all = (try? await environment.apiClient.fetchGallery()) ?? []
            asset = all.first { $0.id == assetID }
            withAnimation(VelaneraTheme.animationSpring) { appear = true }
        }
    }
}
