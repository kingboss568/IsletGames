import Foundation
import StoreKit
import SharedCore

@MainActor
final class PurchaseStore: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var entitlement = EntitlementState()
    @Published var lastMessage: String?

    func bootstrap() async {
        await loadProducts()
        await refreshEntitlements()
    }

    func isUnlocked(_ game: GameDescriptor) -> Bool {
        entitlement.canPlay(game)
    }

    func canUseTheme(_ theme: IsletThemeType) -> Bool {
        entitlement.canUseTheme(theme)
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: ProductID.allCases.map(\.rawValue))
        } catch {
            lastMessage = "商店目前無法連線，核心遊戲仍可離線遊玩。"
        }
    }

    func purchase(productID: String) async {
        guard let product = products.first(where: { $0.id == productID }) else {
            lastMessage = "找不到商品，請在 App Store Connect 確認 product id。"
            return
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    entitlement.apply(productID: transaction.productID)
                    await transaction.finish()
                    lastMessage = "已解鎖完成。"
                } else {
                    lastMessage = "交易未通過驗證。"
                }
            case .pending:
                lastMessage = "交易等待核准。"
            case .userCancelled:
                lastMessage = "已取消購買。"
            @unknown default:
                lastMessage = "購買狀態未知。"
            }
        } catch {
            lastMessage = "購買失敗：\(error.localizedDescription)"
        }
    }

    func refreshEntitlements() async {
        var state = EntitlementState()
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                state.apply(productID: transaction.productID)
            }
        }
        entitlement = state
    }
}