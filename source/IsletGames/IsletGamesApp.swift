import SwiftData
import SwiftUI

@main
struct IsletGamesApp: App {
    var body: some Scene {
        WindowGroup {
            AppShellView()
        }
        .modelContainer(for: [
            PlayerProfile.self,
            GameProgressRecord.self,
            CollectionUnlockRecord.self
        ])
    }
}