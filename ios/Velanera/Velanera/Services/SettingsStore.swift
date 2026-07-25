import Foundation
import Observation

protocol SettingsStoreProtocol: AnyObject {
    @MainActor var settings: AppSettings { get }
    @MainActor func update(_ transform: (inout AppSettings) -> Void)
    @MainActor func reset()
}

/// Local preferences store — syncs to backend when profile update ships.
@Observable
@MainActor
public final class SettingsStore: SettingsStoreProtocol {
    private let defaults: UserDefaults
    private let key = "velanera.appSettings"

    private(set) public var settings: AppSettings

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        } else {
            settings = .default
        }
    }

    public func update(_ transform: (inout AppSettings) -> Void) {
        var next = settings
        transform(&next)
        settings = next
        if let data = try? JSONEncoder().encode(next) {
            defaults.set(data, forKey: key)
        }
    }

    public func reset() {
        settings = .default
        defaults.removeObject(forKey: key)
    }
}
