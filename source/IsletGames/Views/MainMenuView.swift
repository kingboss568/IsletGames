import SharedCore
import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject private var purchaseStore: PurchaseStore
    @AppStorage("currentTheme") private var currentThemeRawValue = IsletThemeType.island.rawValue
    @State private var games = GameCatalog.loadGames()

    private var theme: IsletThemeType {
        IsletThemeType(rawValue: currentThemeRawValue) ?? .island
    }

    private var palette: IsletPalette {
        IsletPalette.palette(for: theme)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero
                themePicker
                gameGrid
            }
            .padding()
        }
        .background(IsletBackdrop(theme: theme))
        .navigationTitle("Islet Games")
        .toolbar {
            NavigationLink {
                PaywallView()
            } label: {
                Image(systemName: "crown.fill")
            }
            .accessibilityLabel("解鎖全部遊戲")
        }
    }

    private var hero: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("小島遊戲機")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(palette.ink)
                Text("挑一款小遊戲，放鬆三分鐘。")
                    .font(.headline)
                    .foregroundStyle(palette.ink.opacity(0.72))
                Text("3 款免費，10 款完整收藏")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(palette.sand, in: Capsule())
            }

            Spacer()

            Image("IslandHero")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .accessibilityHidden(true)
        }
        .padding(18)
        .background(.white.opacity(0.70), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var themePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("主題")
                .font(.headline)
                .foregroundStyle(palette.ink)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(IsletThemeType.allCases) { option in
                        let unlocked = purchaseStore.canUseTheme(option)
                        Button {
                            if unlocked {
                                currentThemeRawValue = option.rawValue
                            }
                        } label: {
                            HStack(spacing: 8) {
                                ThemeSwatch(theme: option)
                                Text(option.displayName)
                                if !unlocked { Image(systemName: "lock.fill") }
                            }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(option == theme ? palette.coral.opacity(0.22) : .white.opacity(0.72), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var gameGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: 14)], spacing: 14) {
            ForEach(games) { game in
                NavigationLink {
                    GameDetailView(game: game)
                } label: {
                    GameCardView(game: game, isUnlocked: purchaseStore.isUnlocked(game), palette: palette)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct GameCardView: View {
    var game: GameDescriptor
    var isUnlocked: Bool
    var palette: IsletPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                GameGlyph(gameID: game.id)
                    .frame(width: 48, height: 48)
                Spacer()
                if game.access == .premium && !isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(palette.coral)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(game.localizedTitle)
                    .font(.headline)
                    .foregroundStyle(palette.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(game.subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(palette.ink.opacity(0.65))
            }

            Text(game.shortDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            Text(game.access == .free ? "免費" : (isUnlocked ? "已解鎖" : "解鎖 $2.99"))
                .font(.caption.weight(.bold))
                .foregroundStyle(game.access == .free || isUnlocked ? palette.palm : palette.coral)
        }
        .frame(minHeight: 190)
        .padding(14)
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(palette.ocean.opacity(0.18), lineWidth: 1)
        }
    }
}

struct ThemeSwatch: View {
    var theme: IsletThemeType
    var body: some View {
        let palette = IsletPalette.palette(for: theme)
        HStack(spacing: 0) {
            palette.ocean
            palette.coral
            palette.palm
        }
        .clipShape(Circle())
        .frame(width: 22, height: 22)
    }
}

struct IsletBackdrop: View {
    var theme: IsletThemeType

    var body: some View {
        let palette = IsletPalette.palette(for: theme)
        LinearGradient(
            colors: [palette.ocean.opacity(0.34), palette.sand.opacity(0.72), .white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct GameGlyph: View {
    var gameID: String

    var body: some View {
        ZStack {
            Circle().fill(.white)
            Image(systemName: symbol)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
        }
        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
    }

    private var symbol: String {
        switch gameID {
        case "coconutcatch": "basket.fill"
        case "turtleflip": "rectangle.on.rectangle.angled"
        case "sandsort": "hourglass"
        case "fishduel": "fish.fill"
        case "fruitslicer": "scissors"
        case "dotconnect": "point.3.connected.trianglepath.dotted"
        case "wordhunt": "textformat.abc"
        case "towerstack": "square.stack.3d.up.fill"
        case "starlink": "sparkles"
        case "pongplus": "circle.grid.cross"
        default: "gamecontroller.fill"
        }
    }

    private var color: Color {
        switch gameID {
        case "coconutcatch", "towerstack": .brown
        case "turtleflip", "fishduel": .teal
        case "sandsort", "fruitslicer": .orange
        case "dotconnect", "starlink": .indigo
        case "wordhunt": .purple
        default: .blue
        }
    }
}

#Preview {
    NavigationStack { MainMenuView() }
        .environmentObject(PurchaseStore())
}