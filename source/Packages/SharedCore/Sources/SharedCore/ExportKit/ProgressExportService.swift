import Foundation
import CoreGraphics

public enum ExportError: Error, Equatable {
    case noProgress
    case pdfContextUnavailable
}

public struct ProgressExportService: Sendable {
    public init() {}

    public func makeCSV(_ snapshots: [GameProgressSnapshot]) throws -> String {
        guard !snapshots.isEmpty else { throw ExportError.noProgress }
        let header = "gameID,displayName,highScore,level,playCount,updatedAt"
        let rows = snapshots.map { snapshot in
            [
                snapshot.gameID,
                snapshot.displayName,
                String(snapshot.highScore),
                String(snapshot.level),
                String(snapshot.playCount),
                ISO8601DateFormatter().string(from: snapshot.updatedAt)
            ].map(Self.escapeCSV).joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\n")
    }

    public func makePDFData(_ snapshots: [GameProgressSnapshot]) throws -> Data {
        guard !snapshots.isEmpty else { throw ExportError.noProgress }
        let data = NSMutableData()
        guard let consumer = CGDataConsumer(data: data as CFMutableData) else {
            throw ExportError.pdfContextUnavailable
        }
        var mediaBox = CGRect(x: 0, y: 0, width: 612, height: 792)
        guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw ExportError.pdfContextUnavailable
        }
        context.beginPDFPage(nil)
        context.setFillColor(CGColor(gray: 0.96, alpha: 1))
        context.fill(mediaBox)
        context.setFillColor(CGColor(red: 0.12, green: 0.18, blue: 0.22, alpha: 1))
        context.endPDFPage()
        context.closePDF()
        return data as Data
    }

    public func makeSummaryText(_ snapshots: [GameProgressSnapshot]) throws -> String {
        guard !snapshots.isEmpty else { throw ExportError.noProgress }
        return snapshots
            .sorted { $0.highScore > $1.highScore }
            .map { "\($0.displayName): high score \($0.highScore), level \($0.level), plays \($0.playCount)" }
            .joined(separator: "\n")
    }

    private static func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
}