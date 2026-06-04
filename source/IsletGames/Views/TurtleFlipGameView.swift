import SharedCore
import SwiftUI

private struct TurtleCard: Identifiable {
    let id = UUID()
    let symbol: String
    var isFaceUp = false
    var isMatched = false
}

struct TurtleFlipGameView: View {
    @State private var cards = TurtleFlipRules.makeDeck(
        pairs: 8,
        symbols: ["tortoise.fill", "fish.fill", "star.fill", "water.waves", "sailboat.fill", "leaf.fill", "sun.max.fill", "moon.stars.fill"]
    ).map { TurtleCard(symbol: $0) }
    @State private var selected: UUID?
    @State private var mistakes = 0

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Label("配對 \(cards.filter { $0.isMatched }.count / 2)/8", systemImage: "checkmark.circle.fill")
                Spacer()
                Label("失誤 \(mistakes)", systemImage: "waveform.path.ecg")
            }
            .font(.subheadline.weight(.semibold))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                ForEach(cards) { card in
                    Button {
                        flip(card)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(card.isFaceUp || card.isMatched ? IsletPalette.island.sand : IsletPalette.island.ocean)
                            Image(systemName: card.isFaceUp || card.isMatched ? card.symbol : "questionmark")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(card.isFaceUp || card.isMatched ? IsletPalette.island.ink : .white)
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                    .buttonStyle(.plain)
                    .disabled(card.isMatched)
                }
            }
        }
        .padding(16)
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func flip(_ card: TurtleCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard !cards[index].isFaceUp, !cards[index].isMatched else { return }

        cards[index].isFaceUp = true

        if let selected, let previousIndex = cards.firstIndex(where: { $0.id == selected }) {
            if cards[previousIndex].symbol == cards[index].symbol {
                cards[previousIndex].isMatched = true
                cards[index].isMatched = true
            } else {
                mistakes += 1
                let current = cards[index].id
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 550_000_000)
                    if let a = cards.firstIndex(where: { $0.id == selected }) { cards[a].isFaceUp = false }
                    if let b = cards.firstIndex(where: { $0.id == current }) { cards[b].isFaceUp = false }
                }
            }
            self.selected = nil
        } else {
            selected = card.id
        }
    }
}

#Preview {
    TurtleFlipGameView()
}