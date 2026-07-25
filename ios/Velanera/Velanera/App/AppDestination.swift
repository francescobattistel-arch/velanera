import Foundation

/// Typed navigation destinations shared across tab stacks.
enum AppDestination: Hashable {
    case menuItem(UUID)
    case wineList
    case cocktails
    case desserts
    case chef
    case allergenGuide
    case loungeOffering(UUID)
    case bottleService
    case djDetail(UUID)
    case privateEventRequest
    case eventDetail(UUID)
    case eventsList
    case gallery
    case galleryItem(UUID)
    case reservationDetail(UUID)
    case membershipUpgrade
    case tierComparison
    case editProfile
    case settings
    case staffRequests
    case conciergeArchive
    case openingHours
    case location
    case privacy
    case terms
}
