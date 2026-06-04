import Foundation

public enum ProductID: String, CaseIterable, Sendable {
    case unlockAll = "com.jiang.isletgames.unlockall"
    case themeJapan = "com.jiang.isletgames.theme.japan"
    case themeKorea = "com.jiang.isletgames.theme.korea"
    case themeHawaii = "com.jiang.isletgames.theme.hawaii"
}

public struct EntitlementState: Codable, Equatable, Sendable {
    public var unlockAll: Bool
    public var unlockedThemes: Set<IsletThemeType>

    public init(unlockAll: Bool = false, unlockedThemes: Set<IsletThemeType> = [.island]) {
        self.unlockAll = unlockAll
        self.unlockedThemes = unlockedThemes.union([.island])
    }

    public func canPlay(_ game: GameDescriptor) -> Bool {
        game.access == .free || unlockAll
    }

    public func canUseTheme(_ theme: IsletThemeType) -> Bool {
        theme == .island || unlockedThemes.contains(theme)
    }

    public mutating func apply(productID: String) {
        switch productID {
        case ProductID.unlockAll.rawValue:
            unlockAll = true
        case ProductID.themeJapan.rawValue:
            unlockedThemes.insert(.japan)
        case ProductID.themeKorea.rawValue:
            unlockedThemes.insert(.korea)
        case ProductID.themeHawaii.rawValue:
            unlockedThemes.insert(.hawaii)
        default:
            break
        }
        unlockedThemes.insert(.island)
    }
}