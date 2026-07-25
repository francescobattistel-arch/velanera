import Foundation
import SwiftUI

enum VenueType: String, Codable, CaseIterable, Sendable {
    case restaurant
    case lounge
    case privateEvent

    var displayName: String {
        switch self {
        case .restaurant: "Restaurant"
        case .lounge: "Lounge"
        case .privateEvent: "Private Event"
        }
    }
}

enum ReservationStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case confirmed
    case cancelled
    case completed
    case staffReview

    var displayName: String {
        switch self {
        case .pending: "Pending"
        case .confirmed: "Confirmed"
        case .cancelled: "Cancelled"
        case .completed: "Completed"
        case .staffReview: "Staff Review"
        }
    }

    var color: Color {
        switch self {
        case .pending: VelaneraColors.softGold
        case .confirmed: VelaneraColors.success
        case .cancelled: VelaneraColors.danger
        case .completed: VelaneraColors.secondaryText
        case .staffReview: VelaneraColors.champagne
        }
    }
}

/// Guest reservation or private-event request.
struct Reservation: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var venue: VenueType
    var date: Date
    var guestCount: Int
    var specialRequests: String
    var status: ReservationStatus
    var contactName: String
    var contactEmail: String

    var displayTitle: String {
        switch venue {
        case .restaurant: "Restaurant Table"
        case .lounge: "Lounge Experience"
        case .privateEvent: "Private Event Request"
        }
    }

    init(
        id: UUID = UUID(),
        venue: VenueType,
        date: Date,
        guestCount: Int,
        specialRequests: String = "",
        status: ReservationStatus = .pending,
        contactName: String,
        contactEmail: String
    ) {
        self.id = id
        self.venue = venue
        self.date = date
        self.guestCount = guestCount
        self.specialRequests = specialRequests
        self.status = status
        self.contactName = contactName
        self.contactEmail = contactEmail
    }
}
