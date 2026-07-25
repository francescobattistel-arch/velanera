import Foundation

/// Deterministic UUIDs for mock catalogue items so favourites and deep links survive relaunches.
enum StableID {
    static func make(_ namespace: String, _ value: Int) -> UUID {
        let padded = String(format: "%012d", value)
        let hex: String
        switch namespace {
        case "menu": hex = "A1000000-0000-4000-8000-\(padded)"
        case "lounge": hex = "A2000000-0000-4000-8000-\(padded)"
        case "event": hex = "A3000000-0000-4000-8000-\(padded)"
        case "gallery": hex = "A4000000-0000-4000-8000-\(padded)"
        case "membership": hex = "A5000000-0000-4000-8000-\(padded)"
        default: hex = "A9000000-0000-4000-8000-\(padded)"
        }
        return UUID(uuidString: hex) ?? UUID()
    }

    static func menu(_ value: Int) -> UUID { make("menu", value) }
    static func lounge(_ value: Int) -> UUID { make("lounge", value) }
    static func event(_ value: Int) -> UUID { make("event", value) }
    static func gallery(_ value: Int) -> UUID { make("gallery", value) }
}
