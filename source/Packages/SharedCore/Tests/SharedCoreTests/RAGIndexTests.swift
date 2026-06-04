import XCTest
@testable import SharedCore

final class RAGIndexTests: XCTestCase {
    func testQueryReturnsMatchingEvidence() {
        let index = LocalRAGIndex(chunks: [
            RAGDocumentChunk(
                id: "sand-tip",
                title: "Sand Sort Tip",
                text: "Use the clear bottle as a temporary buffer.",
                keywords: ["sand", "clear", "bottle"],
                sourceName: "Unit Test",
                sourceURL: nil,
                fetchedAt: Date(timeIntervalSince1970: 0),
                licenseNote: "Test"
            )
        ])

        let result = index.query("sand bottle")

        XCTAssertEqual(result.first?.chunkID, "sand-tip")
    }
}