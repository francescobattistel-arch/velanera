import Foundation

/// In-memory mock backend powering every endpoint until production APIs land.
enum MockBackend {
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
        MenuItem(name: "Citrus Cured Sea Bass", description: "Yuzu, fennel pollen, olive oil.", price: 18, category: .starters, allergens: [.fish], symbolName: "leaf"),
        MenuItem(name: "Burrata & Heirloom Tomato", description: "Aged balsamic, basil oil.", price: 16, category: .starters, allergens: [.dairy], symbolName: "carrot"),
        MenuItem(name: "Charcoal Lamb Cutlets", description: "Smoked aubergine, rosemary jus.", price: 36, category: .mains, allergens: [], isChefRecommendation: true, symbolName: "flame"),
        MenuItem(name: "Lobster Tagliolini", description: "Shell bisque, chilli, lemon.", price: 42, category: .mains, allergens: [.shellfish, .gluten, .dairy], isChefRecommendation: true, symbolName: "fork.knife"),
        MenuItem(name: "Dark Chocolate Nemesis", description: "Olive oil ice cream, sea salt.", price: 14, category: .desserts, allergens: [.dairy, .eggs], symbolName: "birthday.cake"),
        MenuItem(name: "Velanera Spritz", description: "Bergamot, prosecco, bitter orange.", price: 14, category: .cocktails, symbolName: "wineglass"),
        MenuItem(name: "Smoked Old Fashioned", description: "Bourbon, demerara, applewood.", price: 16, category: .cocktails, isChefRecommendation: true, symbolName: "mug.fill"),
        MenuItem(name: "Chablis Premier Cru", description: "Mineral, citrus, precise.", price: 78, category: .wine, symbolName: "waterbottle"),
        MenuItem(name: "Barolo Riserva", description: "Dried cherry, tar, velvet tannin.", price: 140, category: .wine, symbolName: "wineglass.fill"),
        MenuItem(name: "Chef's Tasting Prelude", description: "Five-course seasonal composition.", price: 95, category: .chefSpecials, isChefRecommendation: true, symbolName: "star")
    ]

    static let lounge: [LoungeOffering] = [
        LoungeOffering(name: "Salon Table", summary: "Intimate booth for four with ambient lighting.", kind: .vipTable, startingPrice: 250, capacity: 4),
        LoungeOffering(name: "Terrace VIP", summary: "Elevated seating with skyline aspect.", kind: .vipTable, startingPrice: 450, capacity: 6),
        LoungeOffering(name: "The Library", summary: "Private room with dedicated host.", kind: .privateArea, startingPrice: 1200, capacity: 12),
        LoungeOffering(name: "Founders' Chamber", summary: "Ultra-private celebrations and tastings.", kind: .privateArea, startingPrice: 2500, capacity: 20),
        LoungeOffering(name: "Champagne Ritual", summary: "Magnum presentation with caviar service.", kind: .bottleService, startingPrice: 600, capacity: 6),
        LoungeOffering(name: "Rare Spirits Flight", summary: "Curated whiskies and cognacs tableside.", kind: .bottleService, startingPrice: 850, capacity: 8)
    ]

    static var events: [VenueEvent] {
        let calendar = Calendar.current
        return [
            VenueEvent(title: "Midnight Jazz", subtitle: "Live trio in the lounge.", date: calendar.date(byAdding: .day, value: 3, to: .now) ?? .now, symbolName: "music.mic"),
            VenueEvent(title: "DJ Liora", subtitle: "Deep house until late.", date: calendar.date(byAdding: .day, value: 5, to: .now) ?? .now, symbolName: "headphones"),
            VenueEvent(title: "Members' Harvest Supper", subtitle: "Exclusive seasonal tasting.", date: calendar.date(byAdding: .day, value: 12, to: .now) ?? .now, isMembersOnly: true, symbolName: "leaf.fill"),
            VenueEvent(title: "Sunset Aperitivo", subtitle: "Terrace sparkling hour.", date: calendar.date(byAdding: .day, value: 2, to: .now) ?? .now, symbolName: "sun.horizon")
        ]
    }

    static let membership = Membership(
        memberName: "Guest",
        tier: .house,
        loyaltyPoints: 1840,
        joinedAt: Calendar.current.date(byAdding: .month, value: -8, to: .now) ?? .now,
        qrPayload: "velanera://member/demo-house"
    )

    static let profile = UserProfile(
        displayName: "Guest",
        email: "guest@velanera.co",
        authProvider: .none,
        notificationsEnabled: true
    )

    static func homeFeed() -> HomeFeedResponse {
        HomeFeedResponse(
            featuredDishes: Array(menu.filter { $0.category == .mains || $0.category == .starters }.prefix(4)),
            chefSpecials: menu.filter(\.isChefRecommendation),
            events: events,
            gallerySymbols: ["camera.aperture", "fork.knife.circle", "wineglass", "sparkles", "moon.stars", "leaf"],
            hours: hours
        )
    }
}
