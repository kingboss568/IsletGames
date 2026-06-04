import Foundation

public struct SourceMetadata: Codable, Hashable, Sendable {
    public var sourceName: String
    public var sourceURL: URL?
    public var fetchedAt: Date
    public var licenseNote: String

    public init(sourceName: String, sourceURL: URL?, fetchedAt: Date, licenseNote: String) {
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.fetchedAt = fetchedAt
        self.licenseNote = licenseNote
    }
}

public enum GameAccess: String, Codable, CaseIterable, Sendable {
    case free
    case premium
}

public struct GameDescriptor: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var localizedTitle: String
    public var subtitle: String
    public var shortDescription: String
    public var access: GameAccess
    public var prototype: String
    public var modes: [String]
    public var controls: String
    public var leaderboardID: String
    public var sourceName: String
    public var sourceURL: URL?
    public var fetchedAt: Date
    public var licenseNote: String

    public init(
        id: String,
        title: String,
        localizedTitle: String,
        subtitle: String,
        shortDescription: String,
        access: GameAccess,
        prototype: String,
        modes: [String],
        controls: String,
        leaderboardID: String,
        sourceName: String,
        sourceURL: URL?,
        fetchedAt: Date,
        licenseNote: String
    ) {
        self.id = id
        self.title = title
        self.localizedTitle = localizedTitle
        self.subtitle = subtitle
        self.shortDescription = shortDescription
        self.access = access
        self.prototype = prototype
        self.modes = modes
        self.controls = controls
        self.leaderboardID = leaderboardID
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.fetchedAt = fetchedAt
        self.licenseNote = licenseNote
    }
}

public struct CollectionCardDescriptor: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var category: String
    public var unlockRule: String
    public var body: String
    public var sourceName: String
    public var sourceURL: URL?
    public var fetchedAt: Date
    public var licenseNote: String
}

public struct GameProgressSnapshot: Codable, Equatable, Sendable {
    public var gameID: String
    public var displayName: String
    public var highScore: Int
    public var level: Int
    public var playCount: Int
    public var updatedAt: Date

    public init(gameID: String, displayName: String, highScore: Int, level: Int, playCount: Int, updatedAt: Date) {
        self.gameID = gameID
        self.displayName = displayName
        self.highScore = highScore
        self.level = level
        self.playCount = playCount
        self.updatedAt = updatedAt
    }
}