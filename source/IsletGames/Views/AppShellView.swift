import SharedCore
import SwiftUI

struct AppShellView: View {
    @StateObject private var purchaseStore = PurchaseStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        TabView {
            NavigationStack {
                MainMenuView()
            }
            .tabItem { Label("遊戲", systemImage: "gamecontroller.fill") }

            NavigationStack {
                CollectionLibraryView()
            }
            .tabItem { Label("收藏", systemImage: "sparkles") }

            NavigationStack {
                ProgressExportView()
            }
            .tabItem { Label("紀錄", systemImage: "chart.bar.doc.horizontal") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("設定", systemImage: "gearshape.fill") }
        }
        .environmentObject(purchaseStore)
        .task { await purchaseStore.bootstrap() }
        .fullScreenCover(
            isPresented: Binding(
                get: { !hasCompletedOnboarding },
                set: { presented in
                    if !presented { hasCompletedOnboarding = true }
                }
            )
        ) {
            OnboardingView {
                hasCompletedOnboarding = true
            }
        }
    }
}

#Preview {
    AppShellView()
        .modelContainer(for: [PlayerProfile.self, GameProgressRecord.self, CollectionUnlockRecord.self], inMemory: true)
}