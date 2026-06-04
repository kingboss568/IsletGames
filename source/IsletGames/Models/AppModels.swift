import Foundation
import SwiftData

@Model
final class PlayerProfile {
    @Attribute(.unique) var id: String
    var displayName: String
    var createdAt: Date
    var currentThemeRawValue: String

    init(id: String = "local-player", displayName: String = "島民玩家", createdAt: Date = .now, currentThemeRawValue: String = "island") {
        self.id = id
        self.displayName = displayName
        self.createdAt = createdAt
        self.currentThemeRawValue = currentThemeRawValue
    }
}

@Model
final class GameProgressRecord {
    @Attribute(.unique) var gameID: String
    var displayName: String
    var highScore: Int
    var level: Int
    var playCount: Int
    var updatedAt: Date

    init(gameID: String, displayName: String, highScore: Int = 0, level: Int = 1, playCount: Int = 0, updatedAt: Date = .now) {
        self.gameID = gameID
        self.displayName = displayName
        self.highScore = highScore
        self.level = level
        self.playCount = playCount
        self.updatedAt = updatedAt
    }
}

@Model
final class CollectionUnlockRecord {
    @Attribute(.unique) var cardID: String
    var unlockedAt: Date

    init(cardID: String, unlockedAt: Date = .now) {
        self.cardID = cardID
        self.unlockedAt = unlockedAt
    }
}