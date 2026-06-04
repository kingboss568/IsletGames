import SharedCore
import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    var body: some View {
        List {
            Section("AI") {
                Label("AI 功能目前不可用", systemImage: "sparkles")
                    .foregroundStyle(.secondary)
                Text("Foundation Models 可用前，所有遊戲、分數、解鎖與匯出都維持 deterministic Swift service。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("隱私") {
                Text("所有遊戲進度預設存在本機 SwiftData。MVP 不導入 Firebase、Supabase 或自架後端。")
                    .font(.subheadline)
                Text("本 App 不提供法律、醫療、金融、保險、信用判斷或鑑定服務。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("開發") {
                Button("重新顯示 Onboarding") {
                    hasCompletedOnboarding = false
                }
            }
        }
        .navigationTitle("設定")
    }
}

#Preview {
    NavigationStack { SettingsView() }
}