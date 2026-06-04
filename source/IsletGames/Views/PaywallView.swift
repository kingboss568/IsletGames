import SharedCore
import StoreKit
import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var purchaseStore: PurchaseStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("完整小島遊戲庫", systemImage: "crown.fill")
                        .font(.title2.weight(.heavy))
                    Text("一次解鎖 10 款小遊戲，保留離線核心流程與本機收藏。")
                        .foregroundStyle(.secondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                ProductButton(productID: ProductID.unlockAll.rawValue, title: "解鎖全部遊戲", systemImage: "lock.open.fill")

                VStack(alignment: .leading, spacing: 12) {
                    Text("主題包")
                        .font(.headline)
                    ProductButton(productID: ProductID.themeJapan.rawValue, title: "日本主題", systemImage: "paintpalette.fill")
                    ProductButton(productID: ProductID.themeKorea.rawValue, title: "韓國主題", systemImage: "paintpalette.fill")
                    ProductButton(productID: ProductID.themeHawaii.rawValue, title: "夏威夷主題", systemImage: "paintpalette.fill")
                }
                .padding(18)
                .background(.white.opacity(0.80), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                Button {
                    Task { await purchaseStore.refreshEntitlements() }
                } label: {
                    Label("恢復購買", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)

                if let message = purchaseStore.lastMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .background(IsletBackdrop(theme: .island))
        .navigationTitle("解鎖")
    }
}

private struct ProductButton: View {
    @EnvironmentObject private var purchaseStore: PurchaseStore
    var productID: String
    var title: String
    var systemImage: String

    var body: some View {
        Button {
            Task { await purchaseStore.purchase(productID: productID) }
        } label: {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer()
                Text(priceText)
                    .font(.subheadline.weight(.bold))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .tint(IsletPalette.island.coral)
    }

    private var priceText: String {
        purchaseStore.products.first(where: { $0.id == productID })?.displayPrice ?? (productID.contains("unlockall") ? "$2.99" : "$0.99")
    }
}

#Preview {
    NavigationStack { PaywallView() }
        .environmentObject(PurchaseStore())
}