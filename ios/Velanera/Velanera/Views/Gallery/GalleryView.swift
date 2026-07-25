import SwiftUI

/// Curated photography gallery across restaurant, lounge, and events.
struct GalleryView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var assets: [GalleryAsset] = []
    @State private var filter: GalleryAsset.Collection?

    var filtered: [GalleryAsset] {
        guard let filter else { return assets }
        return assets.filter { $0.collection == filter }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Gallery")
                    .font(VelaneraTypography.title(34))
                    .foregroundStyle(VelaneraColors.ivory)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        chip("All", selected: filter == nil) { filter = nil }
                        ForEach(GalleryAsset.Collection.allCases, id: \.self) { collection in
                            chip(collection.displayName, selected: filter == collection) {
                                filter = collection
                            }
                        }
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(filtered) { asset in
                        NavigationLink(value: AppDestination.galleryItem(asset.id)) {
                            ZStack(alignment: .bottomLeading) {
                                RoundedRectangle(cornerRadius: VelaneraSpacing.radiusMd, style: .continuous)
                                    .fill(VelaneraColors.elevated)
                                    .frame(height: 150)
                                    .overlay {
                                        Image(systemName: asset.symbolName)
                                            .font(.title)
                                            .foregroundStyle(VelaneraColors.gold.opacity(0.7))
                                    }
                                Text(asset.title)
                                    .font(VelaneraTypography.label(11))
                                    .foregroundStyle(VelaneraColors.ivory)
                                    .padding(10)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Gallery")
        .task {
            assets = (try? await environment.apiClient.fetchGallery()) ?? []
        }
    }

    private func chip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(VelaneraTypography.label(11))
                .foregroundStyle(selected ? VelaneraColors.matteBlack : VelaneraColors.champagne)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(selected ? VelaneraColors.gold : VelaneraColors.elevated))
        }
        .buttonStyle(.plain)
    }
}
