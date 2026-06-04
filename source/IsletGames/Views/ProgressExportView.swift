import SharedCore
import SwiftData
import SwiftUI

struct ProgressExportView: View {
    @Query(sort: \GameProgressRecord.updatedAt, order: .reverse) private var records: [GameProgressRecord]
    @State private var exportMessage = "尚未產生匯出檔"

    private let exportService = ProgressExportService()

    var body: some View {
        List {
            Section("匯出") {
                Button {
                    exportCSV()
                } label: {
                    Label("產生 CSV", systemImage: "tablecells")
                }
                Button {
                    exportPDF()
                } label: {
                    Label("產生 PDF", systemImage: "doc.richtext")
                }
                Text(exportMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("遊玩紀錄") {
                if records.isEmpty {
                    ContentUnavailableView("還沒有紀錄", systemImage: "chart.bar", description: Text("從任一遊戲按下記錄成果後，這裡會出現本機進度。"))
                } else {
                    ForEach(records) { record in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.displayName)
                                .font(.headline)
                            Text("最高分 \(record.highScore) · Level \(record.level) · \(record.playCount) 次")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("紀錄與匯出")
    }

    private func exportCSV() {
        do {
            let csv = try exportService.makeCSV(snapshots())
            exportMessage = "CSV 已產生，\(csv.utf8.count) bytes。"
        } catch {
            exportMessage = "沒有可匯出的遊玩紀錄。"
        }
    }

    private func exportPDF() {
        do {
            let data = try exportService.makePDFData(snapshots())
            exportMessage = "PDF 已產生，\(data.count) bytes。"
        } catch {
            exportMessage = "沒有可匯出的遊玩紀錄。"
        }
    }

    private func snapshots() -> [GameProgressSnapshot] {
        records.map {
            GameProgressSnapshot(
                gameID: $0.gameID,
                displayName: $0.displayName,
                highScore: $0.highScore,
                level: $0.level,
                playCount: $0.playCount,
                updatedAt: $0.updatedAt
            )
        }
    }
}

#Preview {
    NavigationStack { ProgressExportView() }
        .modelContainer(for: [GameProgressRecord.self], inMemory: true)
}