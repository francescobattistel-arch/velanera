import SwiftUI

enum AppTab: Hashable {
    case home, restaurant, lounge, book, membership, profile
}

/// Primary tab navigation with voice-first Concierge as the lead experience.
struct RootTabView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var selectedTab: AppTab = .home
    @State private var showConcierge = true
    @Namespace private var conciergeNamespace

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView(selectedTab: $selectedTab)
                }
                .tabItem { Label("Home", systemImage: "house") }
                .tag(AppTab.home)

                NavigationStack {
                    RestaurantView()
                }
                .tabItem { Label("Restaurant", systemImage: "fork.knife") }
                .tag(AppTab.restaurant)

                NavigationStack {
                    LoungeView(selectedTab: $selectedTab)
                }
                .tabItem { Label("Lounge", systemImage: "moon.stars") }
                .tag(AppTab.lounge)

                NavigationStack {
                    BookView()
                }
                .tabItem { Label("Book", systemImage: "calendar") }
                .tag(AppTab.book)

                NavigationStack {
                    MembershipView()
                }
                .tabItem { Label("Membership", systemImage: "crown") }
                .tag(AppTab.membership)

                NavigationStack {
                    ProfileView()
                }
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(AppTab.profile)
            }
            .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)

            if !showConcierge {
                FloatingConciergeButton {
                    withAnimation(ProMotion.spring()) {
                        showConcierge = true
                    }
                }
                .matchedGeometryEffect(id: "concierge-fab", in: conciergeNamespace)
                .padding(.bottom, 58)
                .transition(.scale.combined(with: .opacity))
                .safeAreaPadding(.bottom, DeviceLayout.floatingBottomClearance)
            }
        }
        .background(VelaneraColors.matteBlack.ignoresSafeArea())
        .fullScreenCover(isPresented: $showConcierge) {
            ConciergeView(namespace: conciergeNamespace)
                .presentationBackground(VelaneraColors.matteBlack)
        }
        .onAppear {
            environment.analyticsService.track(event: .screenView("root"))
        }
    }
}
