import SharedCore
import SwiftData
import SwiftUI

struct CollectionLibraryView: View {
    @Query private var unlocks: [CollectionUnlockRecord]
    @State private var cards = GameCatalog.loadCards()

    var body: some View {
        ScrollView {
            if cards.isEmpty {
                ContentUnavailableView("尚無收藏卡", systemImage: "sparkles", description: Text("完成 Star Link 與 Sand Sort 指定關卡後會出現收藏。"))
                    .padding(.top, 80)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: 14)], spacing: 14) {
                    ForEach(cards) { card in
                        CollectionCardView(card: card, unlocked: isUnlocked(card))
                    }
                }
                .padding()
            }
        }
        .background(IsletBackdrop(theme: .island))
        .navigationTitle("收藏卡片")
    }

    private func isUnlocked(_ card: CollectionCardDescriptor) -> Bool {
        unlocks.contains { $0.cardID == card.id } || card.id.hasPrefix("starter")
    }
}

private struct CollectionCardView: View {
    var card: CollectionCardDescriptor
    var unlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: unlocked ? "sparkles" : "lock.fill")
                    .foregroundStyle(unlocked ? IsletPalette.island.coral : .secondary)
                Spacer()
                Text(card.category)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            Text(unlocked ? card.title : "未解鎖卡片")
                .font(.headline)
            Text(unlocked ? card.body : card.unlockRule)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(4)
            Spacer()
        }
        .frame(minHeight: 150)
        .padding(14)
        .background(.white.opacity(unlocked ? 0.84 : 0.58), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(unlocked ? IsletPalette.island.ocean.opacity(0.24) : .gray.opacity(0.2), lineWidth: 1)
        }
    }
}

#Preview {
    NavigationStack { CollectionLibraryView() }
        .modelContainer(for: [CollectionUnlockRecord.self], inMemory: true)
}