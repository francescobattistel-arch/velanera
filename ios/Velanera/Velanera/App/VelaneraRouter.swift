import SwiftUI

/// Attaches shared navigation destinations to any feature NavigationStack.
struct VelaneraRouter: ViewModifier {
    @Binding var selectedTab: AppTab

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: AppDestination.self) { destination in
                switch destination {
                case .menuItem(let id):
                    MenuItemDetailView(itemID: id)
                case .wineList:
                    WineListView()
                case .cocktails:
                    CocktailListView()
                case .desserts:
                    DessertListView()
                case .chef:
                    ChefView()
                case .allergenGuide:
                    AllergenGuideView()
                case .loungeOffering(let id):
                    LoungeOfferingDetailView(offeringID: id, selectedTab: $selectedTab)
                case .bottleService:
                    BottleServiceView(selectedTab: $selectedTab)
                case .djDetail(let id):
                    DJDetailView(eventID: id)
                case .privateEventRequest:
                    PrivateEventRequestView(selectedTab: $selectedTab)
                case .eventDetail(let id):
                    EventDetailView(eventID: id)
                case .eventsList:
                    EventsView()
                case .gallery:
                    GalleryView()
                case .galleryItem(let id):
                    GalleryLightboxView(assetID: id)
                case .reservationDetail(let id):
                    ReservationDetailView(reservationID: id)
                case .membershipUpgrade:
                    MembershipUpgradeView()
                case .tierComparison:
                    TierComparisonView()
                case .editProfile:
                    EditProfileView()
                case .settings:
                    SettingsView()
                case .staffRequests:
                    StaffRequestStatusView()
                case .conciergeArchive:
                    ConciergeArchiveView()
                case .openingHours:
                    OpeningHoursView()
                case .location:
                    LocationView()
                case .privacy:
                    LegalDocumentView(document: .privacy)
                case .terms:
                    LegalDocumentView(document: .terms)
                }
            }
    }
}

extension View {
    func velaneraRouter(selectedTab: Binding<AppTab>) -> some View {
        modifier(VelaneraRouter(selectedTab: selectedTab))
    }
}
