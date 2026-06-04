import XCTest
@testable import SharedCore

final class ExportServiceTests: XCTestCase {
    func testCSVExportIncludesHeaderAndRows() throws {
        let csv = try ProgressExportService().makeCSV([.fixture])

        XCTAssertTrue(csv.contains("gameID,displayName,highScore"))
        XCTAssertTrue(csv.contains("coconutcatch"))
    }

    func testPDFExportProducesPDFBytes() throws {
        let data = try ProgressExportService().makePDFData([.fixture])
        let prefix = String(data: data.prefix(4), encoding: .ascii)

        XCTAssertEqual(prefix, "%PDF")
    }

    func testEmptyExportThrows() {
        XCTAssertThrowsError(try ProgressExportService().makeCSV([]))
    }
}

private extension GameProgressSnapshot {
    static let fixture = GameProgressSnapshot(
        gameID: "coconutcatch",
        displayName: "Coconut Catch",
        highScore: 120,
        level: 3,
        playCount: 5,
        updatedAt: Date(timeIntervalSince1970: 0)
    )
}