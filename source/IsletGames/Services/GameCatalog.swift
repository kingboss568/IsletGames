import Foundation
import SharedCore

enum GameCatalogError: Error {
    case missingResource(String)
}

struct GameCatalog {
    static func loadGames() -> [GameDescriptor] {
        decode([GameDescriptor].self, resource: "SeedGames", fallback: [])
    }

    static func loadCards() -> [CollectionCardDescriptor] {
        decode([CollectionCardDescriptor].self, resource: "SeedCollectionCards", fallback: [])
    }

    static func loadRAGIndex() -> LocalRAGIndex {
        let chunks = decode([RAGDocumentChunk].self, resource: "LocalRAGIndex", fallback: [])
        return LocalRAGIndex(chunks: chunks)
    }

    private static func decode<T: Decodable>(_ type: T.Type, resource: String, fallback: T) -> T {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            return fallback
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            assertionFailure("Failed to decode \(resource): \(error)")
            return fallback
        }
    }
}