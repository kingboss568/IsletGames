import Foundation

public struct RAGDocumentChunk: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var text: String
    public var keywords: [String]
    public var sourceName: String
    public var sourceURL: URL?
    public var fetchedAt: Date
    public var licenseNote: String

    public init(id: String, title: String, text: String, keywords: [String], sourceName: String, sourceURL: URL?, fetchedAt: Date, licenseNote: String) {
        self.id = id
        self.title = title
        self.text = text
        self.keywords = keywords
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.fetchedAt = fetchedAt
        self.licenseNote = licenseNote
    }
}

public struct RAGEvidence: Codable, Equatable, Sendable {
    public var chunkID: String
    public var title: String
    public var excerpt: String
    public var score: Int
}

public struct LocalRAGIndex: Sendable {
    public var chunks: [RAGDocumentChunk]

    public init(chunks: [RAGDocumentChunk]) {
        self.chunks = chunks
    }

    public func query(_ text: String, limit: Int = 3) -> [RAGEvidence] {
        let terms = Set(text.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init))
        return chunks.compactMap { chunk in
            let haystack = Set((chunk.keywords + chunk.title.split(separator: " ").map(String.init)).map { $0.lowercased() })
            let score = terms.intersection(haystack).count
            guard score > 0 else { return nil }
            return RAGEvidence(chunkID: chunk.id, title: chunk.title, excerpt: String(chunk.text.prefix(160)), score: score)
        }
        .sorted { $0.score > $1.score }
        .prefix(limit)
        .map { $0 }
    }
}