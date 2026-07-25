import Foundation

/// In-memory mock backend powering every endpoint until production APIs land.
enum MockBackend {
    private static let calendar = Calendar.current

    static let hours = OpeningHours(
        days: [
            .init(day: "Monday", restaurant: "Closed", lounge: "Closed"),
            .init(day: "Tuesday", restaurant: "18:00 – 23:00", lounge: "20:00 – 01:00"),
            .init(day: "Wednesday", restaurant: "18:00 – 23:00", lounge: "20:00 – 01:00"),
            .init(day: "Thursday", restaurant: "18:00 – 23:30", lounge: "20:00 – 02:00"),
            .init(day: "Friday", restaurant: "18:00 – 00:00", lounge: "20:00 – 03:00"),
            .init(day: "Saturday", restaurant: "12:00 – 00:00", lounge: "20:00 – 03:00"),
            .init(day: "Sunday", restaurant: "12:00 – 22:00", lounge: "Closed")
        ],
        address: "12 Harbour Lane, London",
        phone: "+44 20 0000 0000",
        mapQuery: "Velanera Restaurant Lounge London"
    )

    static let menu: [MenuItem] = [
        MenuItem(
            id: StableID.menu(1),
            name: "Citrus Cured Sea Bass",
            description: "Yuzu, fennel pollen, olive oil.",
            longDescription: "Line-caught sea bass cured overnight in citrus and yuzu, finished with fennel pollen and a thread of Ligurian olive oil.",
            price: 18, category: .starters, allergens: [.fish], symbolName: "leaf",
            pairingNote: "Pairs with Chablis Premier Cru.", dietaryTags: ["Pescatarian"]
        ),
        MenuItem(
            id: StableID.menu(2),
            name: "Burrata & Heirloom Tomato",
            description: "Aged balsamic, basil oil.",
            longDescription: "Cream-filled burrata with late-summer heirloom tomatoes, 12-year balsamic, and basil oil.",
            price: 16, category: .starters, allergens: [.dairy], symbolName: "carrot",
            dietaryTags: ["Vegetarian"]
        ),
        MenuItem(
            id: StableID.menu(3),
            name: "Hand-Cut Beef Tartare",
            description: "Caper berry, smoked egg yolk.",
            longDescription: "Aberdeen Angus tartare with smoked egg yolk emulsion, fried caper berries, and rye crisp.",
            price: 19, category: .starters, allergens: [.eggs, .gluten], symbolName: "flame"
        ),
        MenuItem(
            id: StableID.menu(4),
            name: "Charcoal Lamb Cutlets",
            description: "Smoked aubergine, rosemary jus.",
            longDescription: "Welsh lamb cutlets grilled over charcoal, smoked aubergine purée, rosemary jus, and preserved lemon.",
            price: 36, category: .mains, allergens: [], isChefRecommendation: true, symbolName: "flame",
            pairingNote: "Barolo Riserva."
        ),
        MenuItem(
            id: StableID.menu(5),
            name: "Lobster Tagliolini",
            description: "Shell bisque, chilli, lemon.",
            longDescription: "Fresh tagliolini tossed in lobster shell bisque with chilli, lemon zest, and sweet claw meat.",
            price: 42, category: .mains, allergens: [.shellfish, .gluten, .dairy],
            isChefRecommendation: true, symbolName: "fork.knife"
        ),
        MenuItem(
            id: StableID.menu(6),
            name: "Line-Caught Halibut",
            description: "Brown butter, samphire, lemon.",
            longDescription: "Pan-roasted halibut with brown butter, marsh samphire, and confit lemon.",
            price: 38, category: .mains, allergens: [.fish, .dairy], symbolName: "fish",
            dietaryTags: ["Pescatarian"]
        ),
        MenuItem(
            id: StableID.menu(7),
            name: "Charred Hispi Cabbage",
            description: "Miso butter, toasted seeds.",
            longDescription: "Hispi cabbage charred and glazed with white miso butter, sesame, and pumpkin seeds.",
            price: 24, category: .mains, allergens: [.dairy, .sesame, .soy], symbolName: "leaf",
            dietaryTags: ["Vegetarian"]
        ),
        MenuItem(
            id: StableID.menu(8),
            name: "Dark Chocolate Nemesis",
            description: "Olive oil ice cream, sea salt.",
            longDescription: "Intense flourless chocolate with Arbequina olive oil ice cream and Maldon salt.",
            price: 14, category: .desserts, allergens: [.dairy, .eggs], symbolName: "birthday.cake",
            dietaryTags: ["Vegetarian"]
        ),
        MenuItem(
            id: StableID.menu(9),
            name: "Amalfi Lemon Tart",
            description: "Italian meringue, thyme.",
            longDescription: "Burnished lemon tart with Amalfi zest, Italian meringue, and lemon thyme.",
            price: 13, category: .desserts, allergens: [.gluten, .eggs, .dairy], symbolName: "sun.max"
        ),
        MenuItem(
            id: StableID.menu(10),
            name: "Velanera Spritz",
            description: "Bergamot, prosecco, bitter orange.",
            longDescription: "House bergamot cordial, prosecco, bitter orange, and a twist of grapefruit.",
            price: 14, category: .cocktails, symbolName: "wineglass", abv: "11%"
        ),
        MenuItem(
            id: StableID.menu(11),
            name: "Smoked Old Fashioned",
            description: "Bourbon, demerara, applewood.",
            longDescription: "Buffalo Trace, demerara, Angostura, finished under applewood smoke.",
            price: 16, category: .cocktails, isChefRecommendation: true, symbolName: "mug.fill", abv: "32%"
        ),
        MenuItem(
            id: StableID.menu(12),
            name: "Harbour Martini",
            description: "Gin, dry vermouth, olive brine.",
            longDescription: "London dry gin stirred with Dolin dry and a measured olive brine rinse.",
            price: 15, category: .cocktails, symbolName: "wineglass.fill", abv: "28%"
        ),
        MenuItem(
            id: StableID.menu(13),
            name: "Midnight Negroni",
            description: "Gin, cocoa bitter, vermouth.",
            longDescription: "Classic proportions with a cocoa-nib bitter for late hours.",
            price: 15, category: .cocktails, symbolName: "moon.stars", abv: "26%"
        ),
        MenuItem(
            id: StableID.menu(14),
            name: "Chablis Premier Cru",
            description: "Mineral, citrus, precise.",
            longDescription: "Premier Cru Chablis with crushed stone, citrus pith, and a long saline finish.",
            price: 78, category: .wine, symbolName: "waterbottle",
            pairingNote: "Sea bass, oysters, lobster.",
            wineRegion: "Burgundy, France", wineVintage: "2022", wineGrape: "Chardonnay", abv: "13%"
        ),
        MenuItem(
            id: StableID.menu(15),
            name: "Barolo Riserva",
            description: "Dried cherry, tar, velvet tannin.",
            longDescription: "Riserva Nebbiolo — dried cherry, rose, tar, and fine velvet tannin.",
            price: 140, category: .wine, symbolName: "wineglass.fill",
            pairingNote: "Lamb, aged beef, hard cheeses.",
            wineRegion: "Piedmont, Italy", wineVintage: "2016", wineGrape: "Nebbiolo", abv: "14.5%"
        ),
        MenuItem(
            id: StableID.menu(16),
            name: "Sancerre Les Romains",
            description: "Gooseberry, flint, white blossom.",
            longDescription: "Loire Sauvignon Blanc with gooseberry, flint, and white blossom.",
            price: 68, category: .wine, symbolName: "wineglass",
            wineRegion: "Loire, France", wineVintage: "2023", wineGrape: "Sauvignon Blanc", abv: "13%"
        ),
        MenuItem(
            id: StableID.menu(17),
            name: "Champagne Grand Cru",
            description: "Brioche, citrus, fine mousse.",
            longDescription: "Grower Grand Cru with brioche, citrus oil, and a precise mousse.",
            price: 120, category: .wine, symbolName: "sparkles",
            wineRegion: "Champagne, France", wineVintage: "NV", wineGrape: "Pinot Noir / Chardonnay", abv: "12.5%"
        ),
        MenuItem(
            id: StableID.menu(18),
            name: "Chef's Tasting Prelude",
            description: "Five-course seasonal composition.",
            longDescription: "A five-course progression composed each morning from the market — paced, precise, and quietly luxurious.",
            price: 95, category: .chefSpecials, isChefRecommendation: true, symbolName: "star",
            pairingNote: "Optional wine pairing +£65."
        ),
        MenuItem(
            id: StableID.menu(19),
            name: "Truffle Risotto Interlude",
            description: "Carnaroli, black truffle, aged Parmesan.",
            longDescription: "Mid-menu interlude of Carnaroli risotto finished tableside with black truffle.",
            price: 28, category: .chefSpecials, allergens: [.dairy], isChefRecommendation: true,
            symbolName: "sparkles", dietaryTags: ["Vegetarian"]
        )
    ]

    static var chef: ChefProfile {
        ChefProfile(
            name: "Alessandra Moretti",
            title: "Executive Chef",
            biography: "Raised between Liguria and London, Alessandra composes Mediterranean cooking with quiet precision — charcoal, citrus, and restrained luxury.",
            philosophy: "Fewer gestures. Better produce. An evening that feels considered rather than performed.",
            signatureDishIDs: Array(menu.filter(\.isChefRecommendation).prefix(3).map(\.id)),
            tastingMenuSummary: "Five courses, paced for conversation. Market-led, never rigid.",
            tastingMenuPrice: 95
        )
    }

    static let lounge: [LoungeOffering] = [
        LoungeOffering(
            id: StableID.lounge(1),
            name: "Salon Table",
            summary: "Intimate booth for four with ambient lighting.",
            detail: "A low-lit salon booth with dedicated host attention and chilled champagne service on arrival.",
            kind: .vipTable, startingPrice: 250, capacity: 4,
            includes: ["Priority entry", "Welcome champagne", "Dedicated host"],
            minimumSpend: 250
        ),
        LoungeOffering(
            id: StableID.lounge(2),
            name: "Terrace VIP",
            summary: "Elevated seating with skyline aspect.",
            detail: "Open-air terrace seating for six with skyline aspect and bottle service ready.",
            kind: .vipTable, startingPrice: 450, capacity: 6,
            includes: ["Terrace seating", "Bottle presentation", "Coat check"],
            minimumSpend: 450
        ),
        LoungeOffering(
            id: StableID.lounge(3),
            name: "The Library",
            summary: "Private room with dedicated host.",
            detail: "Book-lined private room for twelve — ideal for celebrations requiring discretion.",
            kind: .privateArea, startingPrice: 1200, capacity: 12,
            includes: ["Private host", "Custom playlist", "Bespoke menu options"],
            minimumSpend: 1200
        ),
        LoungeOffering(
            id: StableID.lounge(4),
            name: "Founders' Chamber",
            summary: "Ultra-private celebrations and tastings.",
            detail: "Our most private chamber for twenty guests — founders' dinners, proposals, and rare tastings.",
            kind: .privateArea, startingPrice: 2500, capacity: 20,
            includes: ["Full privacy", "Dedicated sommelier", "Arrival ritual"],
            minimumSpend: 2500
        ),
        LoungeOffering(
            id: StableID.lounge(5),
            name: "Champagne Ritual",
            summary: "Magnum presentation with caviar service.",
            detail: "Tableside magnum presentation with oscietra caviar and crystal service.",
            kind: .bottleService, startingPrice: 600, capacity: 6,
            includes: ["Magnum champagne", "Caviar service", "Tableside ritual"]
        ),
        LoungeOffering(
            id: StableID.lounge(6),
            name: "Rare Spirits Flight",
            summary: "Curated whiskies and cognacs tableside.",
            detail: "A guided flight of rare whiskies and cognacs, paced by our spirits host.",
            kind: .bottleService, startingPrice: 850, capacity: 8,
            includes: ["Guided tasting", "Printed pairing notes", "Water ceremony"]
        ),
        LoungeOffering(
            id: StableID.lounge(7),
            name: "Dom Pérignon Service",
            summary: "Vintage champagne, sabrage on request.",
            detail: "Dom Pérignon served with optional sabrage and gold ice presentation.",
            kind: .bottleService, startingPrice: 980, capacity: 6,
            includes: ["Vintage champagne", "Sabrage option", "Gold ice"]
        )
    ]

    static var events: [VenueEvent] {
        [
            VenueEvent(
                id: StableID.event(1),
                title: "Midnight Jazz",
                subtitle: "Live trio in the lounge.",
                detail: "An intimate midnight set with double bass, piano, and brushed drums in the salon.",
                date: calendar.date(byAdding: .day, value: 3, to: .now) ?? .now,
                endDate: calendar.date(byAdding: .hour, value: 3, to: calendar.date(byAdding: .day, value: 3, to: .now) ?? .now),
                kind: .liveMusic, symbolName: "music.mic", venueLabel: "Lounge Salon",
                capacity: 60, remainingSpaces: 18
            ),
            VenueEvent(
                id: StableID.event(2),
                title: "DJ Liora",
                subtitle: "Deep house until late.",
                detail: "DJ Liora returns with a deep-house journey through the terrace and main room.",
                date: calendar.date(byAdding: .day, value: 5, to: .now) ?? .now,
                kind: .dj, symbolName: "headphones", venueLabel: "Main Lounge",
                capacity: 120, remainingSpaces: 34, dressCode: "Dark elegance"
            ),
            VenueEvent(
                id: StableID.event(3),
                title: "Members' Harvest Supper",
                subtitle: "Exclusive seasonal tasting.",
                detail: "A members-only harvest supper with chef Alessandra — five courses, rare pours.",
                date: calendar.date(byAdding: .day, value: 12, to: .now) ?? .now,
                kind: .membersOnly, isMembersOnly: true, symbolName: "leaf.fill",
                venueLabel: "Restaurant", capacity: 40, remainingSpaces: 8
            ),
            VenueEvent(
                id: StableID.event(4),
                title: "Sunset Aperitivo",
                subtitle: "Terrace sparkling hour.",
                detail: "Golden-hour sparkling service on the terrace with light Mediterranean bites.",
                date: calendar.date(byAdding: .day, value: 2, to: .now) ?? .now,
                kind: .dining, symbolName: "sun.horizon", venueLabel: "Terrace",
                capacity: 50, remainingSpaces: 22
            ),
            VenueEvent(
                id: StableID.event(5),
                title: "DJ Noor",
                subtitle: "Afro-house and late ritual.",
                detail: "DJ Noor brings afro-house energy with a late-night ritual set.",
                date: calendar.date(byAdding: .day, value: 9, to: .now) ?? .now,
                kind: .dj, symbolName: "opticaldisc", venueLabel: "Main Lounge",
                capacity: 120, remainingSpaces: 55
            ),
            VenueEvent(
                id: StableID.event(6),
                title: "Barolo Masterclass",
                subtitle: "Sommelier-led tasting.",
                detail: "A guided flight of Barolo and Nebbiolo with our sommelier.",
                date: calendar.date(byAdding: .day, value: 16, to: .now) ?? .now,
                kind: .tasting, isMembersOnly: true, symbolName: "wineglass",
                venueLabel: "The Library", capacity: 16, remainingSpaces: 4
            )
        ]
    }

    static let gallery: [GalleryAsset] = [
        .init(id: StableID.gallery(1), title: "Salon Light", caption: "Low light, quiet conversation.", symbolName: "lightbulb.max", collection: .restaurant),
        .init(id: StableID.gallery(2), title: "Chef's Pass", caption: "Composition at the pass.", symbolName: "fork.knife.circle", collection: .restaurant),
        .init(id: StableID.gallery(3), title: "Wine Cellar", caption: "Burgundy to Barolo.", symbolName: "wineglass", collection: .restaurant),
        .init(id: StableID.gallery(4), title: "After Dark", caption: "Lounge energy.", symbolName: "moon.stars", collection: .lounge),
        .init(id: StableID.gallery(5), title: "Terrace Midnight", caption: "Skyline aspect.", symbolName: "building.2", collection: .lounge),
        .init(id: StableID.gallery(6), title: "Bottle Ritual", caption: "Tableside ceremony.", symbolName: "sparkles", collection: .lounge),
        .init(id: StableID.gallery(7), title: "Jazz Night", caption: "Midnight trio.", symbolName: "music.mic", collection: .events),
        .init(id: StableID.gallery(8), title: "Members' Table", caption: "Harvest supper.", symbolName: "crown", collection: .membership)
    ]

    static let membership = Membership(
        id: StableID.make("membership", 1),
        memberName: "Guest",
        tier: .house,
        loyaltyPoints: 1840,
        joinedAt: calendar.date(byAdding: .month, value: -8, to: .now) ?? .now,
        qrPayload: "velanera://member/demo-house"
    )

    static let membershipTiers: [MembershipTierInfo] = [
        .init(tier: .house, annualFee: 250, tagline: "Preferred access, considered evenings.", benefits: MembershipTier.house.benefits),
        .init(tier: .black, annualFee: 750, tagline: "VIP priority and exclusive tastings.", benefits: MembershipTier.black.benefits),
        .init(tier: .founder, annualFee: 2000, tagline: "The quietest key to Velanera.", benefits: MembershipTier.founder.benefits)
    ]

    static var profile = UserProfile(
        displayName: "Guest",
        email: "guest@velanera.co",
        phone: "",
        authProvider: .none,
        notificationsEnabled: true
    )

    private static var reservations: [Reservation] = []
    private static var conciergeRequests: [ConciergeRequest] = []
    private static var rsvps: [EventRSVP] = []

    static func homeFeed() -> HomeFeedResponse {
        HomeFeedResponse(
            featuredDishes: Array(menu.filter { $0.category == .mains || $0.category == .starters }.prefix(4)),
            chefSpecials: menu.filter(\.isChefRecommendation),
            events: events,
            gallery: gallery,
            hours: hours
        )
    }

    static func menuItem(id: UUID) -> MenuItem? {
        menu.first { $0.id == id }
    }

    static func loungeOffering(id: UUID) -> LoungeOffering? {
        lounge.first { $0.id == id }
    }

    static func event(id: UUID) -> VenueEvent? {
        events.first { $0.id == id }
    }

    static func availability(for query: AvailabilityQueryDTO) -> [AvailabilitySlot] {
        let base = calendar.startOfDay(for: query.date)
        let hoursOffsets: [(Int, Int, String, Bool)] = [
            (18, 0, "18:00", false),
            (18, 30, "18:30", false),
            (19, 0, "19:00", true),
            (19, 30, "19:30", true),
            (20, 0, "20:00", true),
            (20, 30, "20:30", false),
            (21, 0, "21:00", false),
            (22, 0, "22:00", false)
        ]
        return hoursOffsets.compactMap { hour, minute, label, peak in
            guard let date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) else { return nil }
            let remaining = peak ? max(0, 8 - query.guestCount) : max(2, 16 - query.guestCount)
            return AvailabilitySlot(
                date: date,
                venue: query.venue,
                capacityRemaining: query.venue == .privateEvent ? 1 : remaining,
                label: label,
                isPeak: peak
            )
        }
    }

    static func createReservation(_ request: ReservationRequestDTO) -> Reservation {
        let reservation = Reservation(
            venue: request.venue,
            date: request.date,
            guestCount: request.guestCount,
            specialRequests: request.specialRequests,
            status: request.venue == .privateEvent ? .staffReview : .confirmed,
            contactName: request.contactName,
            contactEmail: request.contactEmail,
            contactPhone: request.contactPhone,
            offeringID: request.offeringID,
            occasion: request.occasion
        )
        reservations.insert(reservation, at: 0)
        return reservation
    }

    static func updateReservation(id: UUID, update: ReservationUpdateDTO) -> Reservation? {
        guard let index = reservations.firstIndex(where: { $0.id == id }) else {
            // Allow updates against a synthetic reservation for offline SwiftData IDs
            var synthetic = Reservation(
                id: id,
                venue: .restaurant,
                date: update.date ?? .now,
                guestCount: update.guestCount ?? 2,
                specialRequests: update.specialRequests ?? "",
                status: update.status ?? .confirmed,
                contactName: profile.displayName,
                contactEmail: profile.email
            )
            if let date = update.date { synthetic.date = date }
            if let guests = update.guestCount { synthetic.guestCount = guests }
            if let requests = update.specialRequests { synthetic.specialRequests = requests }
            if let status = update.status { synthetic.status = status }
            reservations.insert(synthetic, at: 0)
            return synthetic
        }
        if let date = update.date { reservations[index].date = date }
        if let guests = update.guestCount { reservations[index].guestCount = guests }
        if let requests = update.specialRequests { reservations[index].specialRequests = requests }
        if let status = update.status { reservations[index].status = status }
        return reservations[index]
    }

    static func cancelReservation(id: UUID) -> Reservation? {
        updateReservation(id: id, update: ReservationUpdateDTO(status: .cancelled))
    }

    static func updateProfile(_ update: ProfileUpdateDTO) -> UserProfile {
        profile.displayName = update.displayName
        profile.email = update.email
        profile.phone = update.phone ?? profile.phone
        profile.notificationsEnabled = update.notificationsEnabled
        return profile
    }

    static func storeConciergeRequest(_ request: ConciergeRequest) -> ConciergeRequest {
        conciergeRequests.insert(request, at: 0)
        return request
    }

    static func allConciergeRequests() -> [ConciergeRequest] {
        conciergeRequests
    }

    static func rsvp(_ request: EventRSVPRequestDTO) -> EventRSVP {
        let event = event(id: request.eventID)
        let status: EventRSVP.Status = {
            guard let event else { return .requested }
            if event.isSoldOut { return .waitlisted }
            if event.isMembersOnly && membership.tier == .guest { return .requested }
            return .confirmed
        }()
        let rsvp = EventRSVP(
            eventID: request.eventID,
            guestName: request.guestName,
            guestCount: request.guestCount,
            status: status
        )
        rsvps.insert(rsvp, at: 0)
        return rsvp
    }

    static func confirmPayment(_ dto: PaymentConfirmDTO) -> PaymentReceipt {
        let amount = membershipTiers.first { $0.tier == dto.tier }?.annualFee ?? 0
        return PaymentReceipt(
            id: dto.sessionID,
            tier: dto.tier,
            amount: amount,
            currencyCode: "GBP",
            confirmedAt: .now,
            status: "confirmed"
        )
    }
}
