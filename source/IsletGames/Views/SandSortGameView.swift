import SharedCore
import SwiftUI

struct SandSortGameView: View {
    @State private var tubes: [SandTube] = [
        SandTube(layers: [.coral, .shell, .coral, .seaGlass]),
        SandTube(layers: [.shell, .seaGlass, .shell, .coral]),
        SandTube(layers: [.seaGlass, .coral, .seaGlass, .shell]),
        SandTube(layers: []),
        SandTube(layers: [], isClearBottle: true)
    ]
    @State private var selectedIndex: Int?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("沙灘排列")
                    .font(.headline)
                Spacer()
                Text(SandSortRules.isSolved(tubes) ? "完成" : "慢慢整理")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SandSortRules.isSolved(tubes) ? .green : .secondary)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                ForEach(tubes.indices, id: \.self) { index in
                    Button {
                        tapTube(index)
                    } label: {
                        SandTubeView(tube: tubes[index], selected: selectedIndex == index)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("點來源瓶，再點目標瓶。同色才能疊加；清水瓶可暫存任意顏色。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func tapTube(_ index: Int) {
        if let selectedIndex {
            guard selectedIndex != index else {
                self.selectedIndex = nil
                return
            }
            var source = tubes[selectedIndex]
            var target = tubes[index]
            if SandSortRules.pour(from: &source, to: &target) {
                tubes[selectedIndex] = source
                tubes[index] = target
            }
            self.selectedIndex = nil
        } else if !tubes[index].layers.isEmpty {
            selectedIndex = index
        }
    }
}

private struct SandTubeView: View {
    var tube: SandTube
    var selected: Bool

    var body: some View {
        VStack(spacing: 3) {
            ForEach((0..<tube.capacity).reversed(), id: \.self) { slot in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(color(for: tube.layers.indices.contains(slot) ? tube.layers[slot] : nil))
                    .frame(height: 28)
            }
        }
        .padding(8)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(selected ? IsletPalette.island.coral : .gray.opacity(0.24), lineWidth: selected ? 3 : 1)
        }
        .overlay(alignment: .topTrailing) {
            if tube.isClearBottle {
                Image(systemName: "drop.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .padding(4)
            }
        }
    }

    private func color(for sand: SandColor?) -> Color {
        switch sand {
        case .coral: .orange
        case .shell: .yellow.opacity(0.8)
        case .seaGlass: .teal
        case .sunset: .pink
        case .palm: .green
        case .lagoon: .blue
        case nil: .clear
        }
    }
}

#Preview {
    SandSortGameView()
}