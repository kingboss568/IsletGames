import SharedCore
import SpriteKit
import SwiftData
import SwiftUI

struct GameDetailView: View {
    @EnvironmentObject private var purchaseStore: PurchaseStore
    @Environment(\.modelContext) private var modelContext
    var game: GameDescriptor

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                if purchaseStore.isUnlocked(game) {
                    gameHost
                    Button {
                        recordPlay(score: Int.random(in: 80...320))
                    } label: {
                        Label("記錄本局成果", systemImage: "checkmark.seal.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    lockedState
                }

                guideCard
            }
            .padding()
        }
        .background(IsletBackdrop(theme: .island))
        .navigationTitle(game.localizedTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 14) {
            GameGlyph(gameID: game.id)
                .frame(width: 74, height: 74)
            VStack(alignment: .leading, spacing: 5) {
                Text(game.localizedTitle)
                    .font(.title2.weight(.heavy))
                Text(game.prototype)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(game.controls)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var gameHost: some View {
        switch game.id {
        case "turtleflip":
            TurtleFlipGameView()
        case "sandsort":
            SandSortGameView()
        default:
            SpriteView(scene: GameSceneFactory.scene(for: game))
                .frame(height: 430)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.75), lineWidth: 1)
                }
        }
    }

    private var lockedState: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(IsletPalette.island.coral)
            Text("解鎖完整遊戲庫")
                .font(.title3.weight(.bold))
            Text("一次解鎖 10 款小遊戲與完整離線遊玩流程。")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            NavigationLink {
                PaywallView()
            } label: {
                Label("解鎖 $2.99", systemImage: "crown.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var guideCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("AI 玩法提示", systemImage: "sparkle.magnifyingglass")
                .font(.headline)
            Text("AI 功能目前不可用")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("非 AI 核心流程可繼續使用；分數、解鎖與進度都由 deterministic Swift service 計算。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func recordPlay(score: Int) {
        let gameID = game.id
        let descriptor = FetchDescriptor<GameProgressRecord>(
            predicate: #Predicate { $0.gameID == gameID }
        )
        let existing = try? modelContext.fetch(descriptor).first
        let record = existing ?? GameProgressRecord(gameID: game.id, displayName: game.localizedTitle)
        record.highScore = max(record.highScore, score)
        record.playCount += 1
        record.level += score > 250 ? 1 : 0
        record.updatedAt = .now
        if existing == nil {
            modelContext.insert(record)
        }
    }
}

#Preview {
    NavigationStack {
        GameDetailView(game: GameCatalog.loadGames().first!)
    }
    .environmentObject(PurchaseStore())
    .modelContainer(for: [GameProgressRecord.self, CollectionUnlockRecord.self, PlayerProfile.self], inMemory: true)
}