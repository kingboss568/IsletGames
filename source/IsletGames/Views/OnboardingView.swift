import SharedCore
import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    var body: some View {
        ZStack {
            IsletBackdrop(theme: .island)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 24)

                Image("IslandHero")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 280)
                    .accessibilityHidden(true)

                VStack(spacing: 10) {
                    Text("小島遊戲機")
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(IsletPalette.island.ink)

                    Text("10 款離線療癒小遊戲")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(IsletPalette.island.ink.opacity(0.78))
                }
                .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 14) {
                    FeatureRow(icon: "wifi.slash", title: "核心玩法可離線", body: "搭飛機、旅行、親子共玩都不怕沒網路。")
                    FeatureRow(icon: "lock.open.fill", title: "3 款免費開玩", body: "椰子接接樂、海龜翻翻牌、沙灘排列。")
                    FeatureRow(icon: "paintpalette.fill", title: "主題與收藏", body: "解鎖卡片，替小島換上不同旅行風景。")
                }
                .padding(20)
                .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                Button(action: onFinish) {
                    Label("開始遊玩", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(IsletPalette.island.coral)
                .padding(.horizontal)

                Spacer(minLength: 24)
            }
            .padding()
        }
    }
}

private struct FeatureRow: View {
    var icon: String
    var title: String
    var detail: String

    init(icon: String, title: String, body: String) {
        self.icon = icon
        self.title = title
        self.detail = body
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 28)
                .foregroundStyle(IsletPalette.island.coral)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView {}
}