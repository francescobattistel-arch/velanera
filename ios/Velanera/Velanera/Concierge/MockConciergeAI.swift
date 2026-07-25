import Foundation

/// On-device hospitality brain used while the OpenAI Responses API is wired server-side.
enum MockConciergeAI {
    static func respond(to transcript: String, history: [ConciergeMessage]) -> ConciergeResponse {
        let text = transcript.lowercased()
        let special = isSpecialRequest(text)

        if special {
            return ConciergeResponse(
                reply: "A beautiful request. I’ve prepared a concierge note for our team to review personally — we won’t guarantee availability until they’ve confirmed the details with you.",
                shouldCreateStaffRequest: true,
                staffRequestSummary: transcript.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }

        if matches(text, ["restaurant", "dinner", "table", "lunch", "reserve restaurant"]) {
            return ConciergeResponse(
                reply: "Certainly. Our restaurant welcomes guests for refined Mediterranean dining. May I know your preferred date, time, and party size? I can hold a request immediately.",
                shouldCreateStaffRequest: false,
                staffRequestSummary: nil
            )
        }

        if matches(text, ["lounge", "vip", "bottle", "dj", "night"]) {
            return ConciergeResponse(
                reply: "The lounge is available for VIP tables, private areas, and bottle service. For peak evenings I recommend reserving early. Which experience shall we arrange?",
                shouldCreateStaffRequest: false,
                staffRequestSummary: nil
            )
        }

        if matches(text, ["wine", "red", "white", "champagne", "pairing"]) {
            return ConciergeResponse(
                reply: "For a graceful pairing, I suggest our Chablis Premier Cru with seafood, or Barolo Riserva beside the lamb. Would you like a tasting flight arranged for your table?",
                shouldCreateStaffRequest: false,
                staffRequestSummary: nil
            )
        }

        if matches(text, ["cocktail", "drink", "spritz", "old fashioned"]) {
            return ConciergeResponse(
                reply: "Our signatures include the Velanera Spritz and a smoked Old Fashioned. I can have one waiting at your seat when you arrive.",
                shouldCreateStaffRequest: false,
                staffRequestSummary: nil
            )
        }

        if matches(text, ["hours", "open", "closing", "time"]) {
            return ConciergeResponse(
                reply: "The restaurant is open Tuesday to Sunday; the lounge runs from Thursday through Saturday into the early hours. Shall I check a specific evening for you?",
                shouldCreateStaffRequest: false,
                staffRequestSummary: nil
            )
        }

        if matches(text, ["dress", "code", "attire", "wear"]) {
            return ConciergeResponse(
                reply: "We ask for smart elegance — refined, dark, and considered. Sportswear and flip-flops are not permitted in the lounge.",
                shouldCreateStaffRequest: false,
                staffRequestSummary: nil
            )
        }

        if matches(text, ["park", "parking", "valet", "directions", "address", "where"]) {
            return ConciergeResponse(
                reply: "We’re at 12 Harbour Lane, London. Evening valet is available on Friday and Saturday. I can send directions to your maps app whenever you like.",
                shouldCreateStaffRequest: false,
                staffRequestSummary: nil
            )
        }

        if matches(text, ["member", "membership", "loyalty", "vip status"]) {
            return ConciergeResponse(
                reply: "House and Black membership unlock preferred seating, exclusive evenings, and concierge priority. I can outline benefits or arrange an introduction to membership.",
                shouldCreateStaffRequest: false,
                staffRequestSummary: nil
            )
        }

        if matches(text, ["menu", "dish", "chef", "dessert", "allergen"]) {
            return ConciergeResponse(
                reply: "Tonight the chef highlights charcoal lamb cutlets and lobster tagliolini. Allergen details are available for every dish — tell me any preferences and I’ll guide you.",
                shouldCreateStaffRequest: false,
                staffRequestSummary: nil
            )
        }

        if history.isEmpty {
            return ConciergeResponse(
                reply: "Welcome to Velanera. I’m your concierge — for dining, the lounge, membership, or something rather special. How may I look after you?",
                shouldCreateStaffRequest: false,
                staffRequestSummary: nil
            )
        }

        return ConciergeResponse(
            reply: "Of course. I can assist with restaurant reservations, lounge VIP experiences, wine, events, and membership. What would you like to arrange?",
            shouldCreateStaffRequest: false,
            staffRequestSummary: nil
        )
    }

    private static func isSpecialRequest(_ text: String) -> Bool {
        matches(text, [
            "bespoke", "custom menu", "proposal", "anniversary surprise",
            "private chef", "something special", "celebration", "engagement",
            "special seating", "premium experience", "unusual", "one of a kind"
        ])
    }

    private static func matches(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }
}
