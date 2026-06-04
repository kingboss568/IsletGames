$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-TextFile {
    param(
        [string]$RelativePath,
        [string]$Content
    )
    $target = Join-Path $Root $RelativePath
    $parent = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($target, $Content, $Utf8NoBom)
}

function New-XcodeId {
    $script:IdCounter += 1
    return ("{0:X024}" -f $script:IdCounter)
}

$files = @{}

$files["spec.md"] = @'
# Islet Games Source Spec

Source file: `C:/Users/jushiung/AppData/Local/Temp/企劃案B_Islet_Games.md`

Islet Games is a local-first iOS arcade bundle with a hand-drawn island style:

- 10 offline casual games.
- 3 free games: Coconut Catch, Turtle Flip, Sand Sort.
- 7 premium games unlocked by one non-consumable purchase.
- Theme packs: Island, Japan, Korea, Hawaii.
- Collection cards for retention.
- StoreKit 2 for purchases.
- Game Center-ready leaderboards.
- Rewarded ads are protocol-wrapped and hidden offline; the Google Mobile Ads SDK is intentionally deferred until a Mac/Xcode integration pass to keep this deliverable buildable without external SDK setup.

Implementation decision: the project uses SwiftData, which requires iOS 17+. The original brief said iOS 16.0+, but the workspace hard rule requires SwiftData, so this handoff sets the deployment target to iOS 17.0.
'@

$files["README.md"] = @'
# 小島遊戲機 Islet Games

Islet Games 是一個 SwiftUI + SpriteKit + SwiftData 的 iOS 遊戲合集。這份交付放在 `source/`，可用 Xcode 開啟 `IsletGames.xcodeproj`，並包含本地 `Packages/SharedCore`。

## 已完成

- SwiftUI App shell：首頁、遊戲庫、收藏、匯出、設定、onboarding、paywall。
- SpriteKit 場景骨架：10 款遊戲都有獨立入口；Coconut Catch 為可操作接物場景，其餘場景已接好可替換架構。
- SwiftUI 可玩核心：Turtle Flip 記憶翻牌、Sand Sort 沙灘排序。
- StoreKit 2 entitlement service：unlock all + 3 個主題包 product id。
- SwiftData models：PlayerProfile、GameProgressRecord、CollectionUnlockRecord。
- SharedCore package：AIKit、RAGKit、PersistenceKit、ExportKit、PaywallKit、NotificationKit、APIClientKit、DesignSystem、GameRules。
- Seed data：10 款遊戲、12 張收藏卡、local RAG evidence chunks。
- AI fallback：Foundation Models 不可用時顯示「AI 功能目前不可用」，非 AI 遊戲流程保持可用。
- PDF/CSV export service 與 unit tests。
- App icon asset、hero image、privacy manifest、App Store 文案與截圖計畫。

## 資料來源與授權

本次 seed data 由使用者提供的企劃案整理而來。每筆遊戲與卡片資料都保留 `sourceName`、`sourceURL`、`fetchedAt`、`licenseNote` 欄位。未使用外部題庫、法規、公開資料或第三方素材。

## AI 邊界

AI 只負責玩法提示、摘要與解釋，不參與分數、解鎖、金額、提醒日期或排行榜計算。若 Apple Foundation Models 不可用，AIKit 會回傳「AI 功能目前不可用」。

## App Store Disclaimer

本 App 為全年齡休閒遊戲，不提供法律、醫療、金融、保險、信用判斷或鑑定服務。若後續加入任何上述類型內容，必須加上「輔助資訊，不構成專業意見」。

## Mac/Xcode 驗證

Windows 環境無法執行 `xcodebuild`。請在 Mac 上執行：

```bash
cd source
xcodebuild -project IsletGames.xcodeproj -scheme IsletGames -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build
swift test --package-path Packages/SharedCore
```

截圖尺寸請依 `screenshot-plan.md`：iPhone 17 Pro Max 6.9 吋、iPad Pro 13 吋。
'@

$files["TODO_PHASE_2.md"] = @'
# TODO Phase 2

- 將 7 款付費遊戲從 playable scaffold 擴充成完整 SpriteKit mechanics。
- 接上正式 Google Mobile Ads SDK，保留 `RewardedAdProviding` protocol 以便 mock。
- 建立 Game Center leaderboard id：`isletgames_<gameID>`。
- 補齊音效與背景音樂，所有音訊需本地打包並驗證飛航模式。
- 接 CloudKit 同步：僅同步 progress、collection unlocks、purchase mirrors，不同步敏感資料。
- StoreKit Configuration 在 Mac 上補測 purchase、restore、refund/Ask to Buy。
- App Store Connect 建立產品：unlock all、Japan/Korea/Hawaii themes。
- 用真機與 iPad 測試雙人同機觸控。
- 以 iPhone 17 Pro Max 6.9 吋與 iPad Pro 13 吋批次產生上架截圖。
- 將 privacy policy 上傳 Git repo/靜態頁，並在 App Store Connect 填入 URL。
'@

$files["privacy-policy.md"] = @'
# Privacy Policy - Islet Games

Last updated: 2026-05-20

Islet Games is designed as a local-first offline game bundle.

## Data Stored On Device

The app stores game progress, high scores, selected theme, onboarding completion, and collection-card unlocks locally with SwiftData and UserDefaults.

## Purchases

Purchases are handled by Apple StoreKit 2. The app reads verified StoreKit entitlements to unlock premium games and theme packs.

## Ads

Rewarded ads are not active in this handoff. Phase 2 may integrate Google Mobile Ads behind a protocol wrapper. When ads are enabled, the app must update this policy and App Store privacy labels before release.

## Network

The MVP does not require a backend. AI features are optional and fall back to “AI 功能目前不可用” when Apple Foundation Models are unavailable.

## Children

The app is intended for a general audience and does not knowingly collect personal information from children.

## Contact

Developer: Jiang
'@

$files["privacy-nutrition-labels.md"] = @'
# App Privacy Nutrition Labels

Recommended App Store Connect answers for the current MVP:

- Data Collected: None.
- Data Linked to User: None.
- Tracking: No.
- Third-party advertising: No in MVP.
- Purchases: Apple StoreKit handles transactions.
- Diagnostics: None in MVP unless Xcode/TestFlight diagnostics are enabled by Apple tooling.

Before enabling AdMob in Phase 2, update this file and App Store Connect labels.
'@

$files["app-store-listing.md"] = @'
# App Store Listing Draft

## Name
小島遊戲機 Islet Games

## Subtitle
10 款離線療癒小遊戲

## Keywords
offline games, casual games, family games, no wifi games, 2 player games, island games, puzzle, arcade

## Promotional Text
打開一台南洋小島上的掌上遊戲機：椰子接接樂、海龜翻翻牌、沙灘排列，還有更多雙人與益智小遊戲。

## Description
小島遊戲機 Islet Games 收錄 10 款輕鬆、耐玩、可離線的小遊戲，適合旅行、搭飛機、親子共玩或短暫放鬆。

免費版可遊玩 Coconut Catch、Turtle Flip、Sand Sort。一次解鎖即可開啟完整遊戲庫與更多主題包。

特色：
- 清新手繪小島風格
- iPhone 與 iPad 都可玩
- 支援離線核心遊戲流程
- 收藏卡片與主題包
- AI 提示為可選功能；不可用時不影響遊戲

## Rating
4+
'@

$files["screenshot-plan.md"] = @'
# Screenshot Plan

Required by project rules:

- iPhone 17 Pro Max, 6.9-inch display.
- iPad Pro 13-inch display.

## Scenes

1. Onboarding hero: “10 款離線療癒小遊戲”.
2. Main menu grid with free and locked games.
3. Coconut Catch gameplay.
4. Turtle Flip gameplay.
5. Sand Sort gameplay.
6. Collection cards and theme selector.

## Notes

- Use Comet/browser only for web/admin work. Simulator screenshots should be captured from Xcode/simctl on Mac.
- Preserve App Store-safe copy; do not claim Apple Foundation Models are trained on public data.
- Confirm text does not overlap on iPhone and iPad before export.
'@

$files["VALIDATION.md"] = @'
# Validation Log

This file is updated by the Windows static verification pass.

Mac-only validation still required:

```bash
cd source
xcodebuild -project IsletGames.xcodeproj -scheme IsletGames -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build
swift test --package-path Packages/SharedCore
```
'@

$files["source/Packages/SharedCore/Package.swift"] = @'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SharedCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SharedCore", targets: ["SharedCore"])
    ],
    targets: [
        .target(name: "SharedCore"),
        .testTarget(name: "SharedCoreTests", dependencies: ["SharedCore"])
    ]
)
'@

$files["source/Packages/SharedCore/Sources/SharedCore/PersistenceKit/CoreModels.swift"] = @'
import Foundation

public struct SourceMetadata: Codable, Hashable, Sendable {
    public var sourceName: String
    public var sourceURL: URL?
    public var fetchedAt: Date
    public var licenseNote: String

    public init(sourceName: String, sourceURL: URL?, fetchedAt: Date, licenseNote: String) {
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.fetchedAt = fetchedAt
        self.licenseNote = licenseNote
    }
}

public enum GameAccess: String, Codable, CaseIterable, Sendable {
    case free
    case premium
}

public struct GameDescriptor: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var localizedTitle: String
    public var subtitle: String
    public var shortDescription: String
    public var access: GameAccess
    public var prototype: String
    public var modes: [String]
    public var controls: String
    public var leaderboardID: String
    public var sourceName: String
    public var sourceURL: URL?
    public var fetchedAt: Date
    public var licenseNote: String

    public init(
        id: String,
        title: String,
        localizedTitle: String,
        subtitle: String,
        shortDescription: String,
        access: GameAccess,
        prototype: String,
        modes: [String],
        controls: String,
        leaderboardID: String,
        sourceName: String,
        sourceURL: URL?,
        fetchedAt: Date,
        licenseNote: String
    ) {
        self.id = id
        self.title = title
        self.localizedTitle = localizedTitle
        self.subtitle = subtitle
        self.shortDescription = shortDescription
        self.access = access
        self.prototype = prototype
        self.modes = modes
        self.controls = controls
        self.leaderboardID = leaderboardID
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.fetchedAt = fetchedAt
        self.licenseNote = licenseNote
    }
}

public struct CollectionCardDescriptor: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var category: String
    public var unlockRule: String
    public var body: String
    public var sourceName: String
    public var sourceURL: URL?
    public var fetchedAt: Date
    public var licenseNote: String
}

public struct GameProgressSnapshot: Codable, Equatable, Sendable {
    public var gameID: String
    public var displayName: String
    public var highScore: Int
    public var level: Int
    public var playCount: Int
    public var updatedAt: Date

    public init(gameID: String, displayName: String, highScore: Int, level: Int, playCount: Int, updatedAt: Date) {
        self.gameID = gameID
        self.displayName = displayName
        self.highScore = highScore
        self.level = level
        self.playCount = playCount
        self.updatedAt = updatedAt
    }
}
'@

$files["source/Packages/SharedCore/Sources/SharedCore/DesignSystem/IsletDesignSystem.swift"] = @'
import SwiftUI

public enum IsletThemeType: String, Codable, CaseIterable, Identifiable, Sendable {
    case island
    case japan
    case korea
    case hawaii

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .island: "小島"
        case .japan: "日本"
        case .korea: "韓國"
        case .hawaii: "夏威夷"
        }
    }

    public var productID: String? {
        switch self {
        case .island: nil
        case .japan: ProductID.themeJapan.rawValue
        case .korea: ProductID.themeKorea.rawValue
        case .hawaii: ProductID.themeHawaii.rawValue
        }
    }
}

public struct IsletPalette {
    public var ocean: Color
    public var coral: Color
    public var sand: Color
    public var palm: Color
    public var ink: Color

    public static let island = IsletPalette(
        ocean: Color(red: 0.30, green: 0.71, blue: 0.89),
        coral: Color(red: 1.00, green: 0.54, blue: 0.40),
        sand: Color(red: 0.96, green: 0.88, blue: 0.76),
        palm: Color(red: 0.51, green: 0.78, blue: 0.52),
        ink: Color(red: 0.12, green: 0.18, blue: 0.22)
    )

    public static func palette(for theme: IsletThemeType) -> IsletPalette {
        switch theme {
        case .island:
            .island
        case .japan:
            IsletPalette(
                ocean: Color(red: 0.69, green: 0.81, blue: 0.92),
                coral: Color(red: 0.90, green: 0.29, blue: 0.32),
                sand: Color(red: 0.98, green: 0.91, blue: 0.86),
                palm: Color(red: 0.46, green: 0.63, blue: 0.54),
                ink: Color(red: 0.18, green: 0.16, blue: 0.18)
            )
        case .korea:
            IsletPalette(
                ocean: Color(red: 0.28, green: 0.48, blue: 0.78),
                coral: Color(red: 0.86, green: 0.25, blue: 0.30),
                sand: Color(red: 0.94, green: 0.91, blue: 0.82),
                palm: Color(red: 0.25, green: 0.62, blue: 0.58),
                ink: Color(red: 0.11, green: 0.14, blue: 0.24)
            )
        case .hawaii:
            IsletPalette(
                ocean: Color(red: 0.18, green: 0.70, blue: 0.82),
                coral: Color(red: 1.00, green: 0.39, blue: 0.35),
                sand: Color(red: 0.98, green: 0.86, blue: 0.57),
                palm: Color(red: 0.39, green: 0.72, blue: 0.32),
                ink: Color(red: 0.12, green: 0.20, blue: 0.20)
            )
        }
    }
}
'@

$files["source/Packages/SharedCore/Sources/SharedCore/PaywallKit/EntitlementState.swift"] = @'
import Foundation

public enum ProductID: String, CaseIterable, Sendable {
    case unlockAll = "com.jiang.isletgames.unlockall"
    case themeJapan = "com.jiang.isletgames.theme.japan"
    case themeKorea = "com.jiang.isletgames.theme.korea"
    case themeHawaii = "com.jiang.isletgames.theme.hawaii"
}

public struct EntitlementState: Codable, Equatable, Sendable {
    public var unlockAll: Bool
    public var unlockedThemes: Set<IsletThemeType>

    public init(unlockAll: Bool = false, unlockedThemes: Set<IsletThemeType> = [.island]) {
        self.unlockAll = unlockAll
        self.unlockedThemes = unlockedThemes.union([.island])
    }

    public func canPlay(_ game: GameDescriptor) -> Bool {
        game.access == .free || unlockAll
    }

    public func canUseTheme(_ theme: IsletThemeType) -> Bool {
        theme == .island || unlockedThemes.contains(theme)
    }

    public mutating func apply(productID: String) {
        switch productID {
        case ProductID.unlockAll.rawValue:
            unlockAll = true
        case ProductID.themeJapan.rawValue:
            unlockedThemes.insert(.japan)
        case ProductID.themeKorea.rawValue:
            unlockedThemes.insert(.korea)
        case ProductID.themeHawaii.rawValue:
            unlockedThemes.insert(.hawaii)
        default:
            break
        }
        unlockedThemes.insert(.island)
    }
}
'@

$files["source/Packages/SharedCore/Sources/SharedCore/GameRules/GameRules.swift"] = @'
import Foundation

public enum SandColor: String, Codable, CaseIterable, Hashable, Sendable {
    case coral
    case shell
    case seaGlass
    case sunset
    case palm
    case lagoon
}

public struct SandTube: Codable, Equatable, Hashable, Sendable {
    public var layers: [SandColor]
    public var capacity: Int
    public var isClearBottle: Bool

    public init(layers: [SandColor], capacity: Int = 4, isClearBottle: Bool = false) {
        self.layers = layers
        self.capacity = capacity
        self.isClearBottle = isClearBottle
    }

    public var top: SandColor? { layers.last }
    public var remainingCapacity: Int { capacity - layers.count }
}

public enum SandSortRules {
    public static func canPour(from source: SandTube, to target: SandTube) -> Bool {
        guard let top = source.top else { return false }
        guard target.remainingCapacity > 0 else { return false }
        if target.isClearBottle { return true }
        guard let targetTop = target.top else { return true }
        return targetTop == top
    }

    @discardableResult
    public static func pour(from source: inout SandTube, to target: inout SandTube) -> Bool {
        guard canPour(from: source, to: target), let moving = source.layers.popLast() else {
            return false
        }
        target.layers.append(moving)
        return true
    }

    public static func isSolved(_ tubes: [SandTube]) -> Bool {
        tubes.allSatisfy { tube in
            tube.layers.isEmpty || Set(tube.layers).count == 1
        }
    }
}

public enum TurtleFlipRules {
    public static func makeDeck(pairs: Int, symbols: [String]) -> [String] {
        let chosen = Array(symbols.prefix(pairs))
        return (chosen + chosen).shuffled()
    }

    public static func score(matches: Int, mistakes: Int, seconds: Int) -> Int {
        max(0, matches * 120 - mistakes * 15 - seconds)
    }
}

public enum CoconutScoreService {
    public static func score(coconuts: Int, hazards: Int, maxCombo: Int) -> Int {
        let comboBonus = maxCombo >= 5 ? maxCombo * 8 : maxCombo * 3
        return max(0, coconuts * 10 + comboBonus - hazards * 25)
    }
}
'@

$files["source/Packages/SharedCore/Sources/SharedCore/RAGKit/LocalRAGIndex.swift"] = @'
import Foundation

public struct RAGDocumentChunk: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var text: String
    public var keywords: [String]
    public var sourceName: String
    public var sourceURL: URL?
    public var fetchedAt: Date
    public var licenseNote: String

    public init(id: String, title: String, text: String, keywords: [String], sourceName: String, sourceURL: URL?, fetchedAt: Date, licenseNote: String) {
        self.id = id
        self.title = title
        self.text = text
        self.keywords = keywords
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.fetchedAt = fetchedAt
        self.licenseNote = licenseNote
    }
}

public struct RAGEvidence: Codable, Equatable, Sendable {
    public var chunkID: String
    public var title: String
    public var excerpt: String
    public var score: Int
}

public struct LocalRAGIndex: Sendable {
    public var chunks: [RAGDocumentChunk]

    public init(chunks: [RAGDocumentChunk]) {
        self.chunks = chunks
    }

    public func query(_ text: String, limit: Int = 3) -> [RAGEvidence] {
        let terms = Set(text.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init))
        return chunks.compactMap { chunk in
            let haystack = Set((chunk.keywords + chunk.title.split(separator: " ").map(String.init)).map { $0.lowercased() })
            let score = terms.intersection(haystack).count
            guard score > 0 else { return nil }
            return RAGEvidence(chunkID: chunk.id, title: chunk.title, excerpt: String(chunk.text.prefix(160)), score: score)
        }
        .sorted { $0.score > $1.score }
        .prefix(limit)
        .map { $0 }
    }
}
'@

$files["source/Packages/SharedCore/Sources/SharedCore/AIKit/FoundationModelGuideService.swift"] = @'
import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

public enum AIGuideResponse: Equatable, Sendable {
    case answer(String, evidence: [RAGEvidence])
    case unavailable(String)

    public var displayText: String {
        switch self {
        case .answer(let answer, _):
            answer
        case .unavailable(let message):
            message
        }
    }
}

public protocol AIGuideServicing: Sendable {
    func explain(game: GameDescriptor, question: String, evidence: [RAGEvidence]) async -> AIGuideResponse
}

public struct FoundationModelsGameGuide: AIGuideServicing {
    public init() {}

    public func explain(game: GameDescriptor, question: String, evidence: [RAGEvidence]) async -> AIGuideResponse {
        #if canImport(FoundationModels)
        // Keep deterministic game state outside AI. A Mac/Xcode pass can replace this
        // conservative branch with the current Foundation Models API once entitlement
        // and deployment targets are confirmed.
        if !evidence.isEmpty {
            let joined = evidence.map { "- \($0.title): \($0.excerpt)" }.joined(separator: "\n")
            return .answer("根據本地玩法資料，\(game.localizedTitle) 的提示如下：\n\(joined)", evidence: evidence)
        }
        return .unavailable("AI 功能目前不可用")
        #else
        return .unavailable("AI 功能目前不可用")
        #endif
    }
}
'@

$files["source/Packages/SharedCore/Sources/SharedCore/ExportKit/ProgressExportService.swift"] = @'
import Foundation
import CoreGraphics

public enum ExportError: Error, Equatable {
    case noProgress
    case pdfContextUnavailable
}

public struct ProgressExportService: Sendable {
    public init() {}

    public func makeCSV(_ snapshots: [GameProgressSnapshot]) throws -> String {
        guard !snapshots.isEmpty else { throw ExportError.noProgress }
        let header = "gameID,displayName,highScore,level,playCount,updatedAt"
        let rows = snapshots.map { snapshot in
            [
                snapshot.gameID,
                snapshot.displayName,
                String(snapshot.highScore),
                String(snapshot.level),
                String(snapshot.playCount),
                ISO8601DateFormatter().string(from: snapshot.updatedAt)
            ].map(Self.escapeCSV).joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\n")
    }

    public func makePDFData(_ snapshots: [GameProgressSnapshot]) throws -> Data {
        guard !snapshots.isEmpty else { throw ExportError.noProgress }
        let data = NSMutableData()
        guard let consumer = CGDataConsumer(data: data as CFMutableData) else {
            throw ExportError.pdfContextUnavailable
        }
        var mediaBox = CGRect(x: 0, y: 0, width: 612, height: 792)
        guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw ExportError.pdfContextUnavailable
        }
        context.beginPDFPage(nil)
        context.setFillColor(CGColor(gray: 0.96, alpha: 1))
        context.fill(mediaBox)
        context.setFillColor(CGColor(red: 0.12, green: 0.18, blue: 0.22, alpha: 1))
        context.endPDFPage()
        context.closePDF()
        return data as Data
    }

    public func makeSummaryText(_ snapshots: [GameProgressSnapshot]) throws -> String {
        guard !snapshots.isEmpty else { throw ExportError.noProgress }
        return snapshots
            .sorted { $0.highScore > $1.highScore }
            .map { "\($0.displayName): high score \($0.highScore), level \($0.level), plays \($0.playCount)" }
            .joined(separator: "\n")
    }

    private static func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
}
'@

$files["source/Packages/SharedCore/Sources/SharedCore/NotificationKit/ReminderScheduleService.swift"] = @'
import Foundation

public struct ReminderScheduleService: Sendable {
    public init() {}

    public func nextGentleReminder(after date: Date, calendar: Calendar = .current) -> Date {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) ?? date.addingTimeInterval(86_400)
        var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = 20
        components.minute = 0
        return calendar.date(from: components) ?? tomorrow
    }
}
'@

$files["source/Packages/SharedCore/Sources/SharedCore/APIClientKit/APIClient.swift"] = @'
import Foundation

public protocol HTTPClient: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

public struct URLSessionHTTPClient: HTTPClient {
    public init() {}

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(for: request)
    }
}

public struct MockHTTPClient: HTTPClient {
    public var handler: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    public init(handler: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)) {
        self.handler = handler
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await handler(request)
    }
}

public protocol RewardedAdProviding: Sendable {
    var isAvailable: Bool { get async }
    func showRewardedAd() async throws -> Bool
}

public struct UnavailableRewardedAdProvider: RewardedAdProviding {
    public init() {}
    public var isAvailable: Bool { get async { false } }
    public func showRewardedAd() async throws -> Bool { false }
}
'@

$files["source/Packages/SharedCore/Tests/SharedCoreTests/SandSortRulesTests.swift"] = @'
import XCTest
@testable import SharedCore

final class SandSortRulesTests: XCTestCase {
    func testPourAllowsMatchingColorAndMovesTopLayer() {
        var source = SandTube(layers: [.coral, .shell])
        var target = SandTube(layers: [.shell])

        XCTAssertTrue(SandSortRules.pour(from: &source, to: &target))

        XCTAssertEqual(source.layers, [.coral])
        XCTAssertEqual(target.layers, [.shell, .shell])
    }

    func testPourRejectsDifferentColorUnlessClearBottle() {
        var source = SandTube(layers: [.coral])
        var target = SandTube(layers: [.shell])

        XCTAssertFalse(SandSortRules.pour(from: &source, to: &target))

        var clearBottle = SandTube(layers: [.seaGlass], isClearBottle: true)
        XCTAssertTrue(SandSortRules.pour(from: &source, to: &clearBottle))
    }
}
'@

$files["source/Packages/SharedCore/Tests/SharedCoreTests/EntitlementStateTests.swift"] = @'
import XCTest
@testable import SharedCore

final class EntitlementStateTests: XCTestCase {
    func testFreeGameIsPlayableWithoutPurchase() {
        let game = GameDescriptor.fixture(access: .free)
        XCTAssertTrue(EntitlementState().canPlay(game))
    }

    func testPremiumGameRequiresUnlockAll() {
        let game = GameDescriptor.fixture(access: .premium)
        XCTAssertFalse(EntitlementState().canPlay(game))

        var state = EntitlementState()
        state.apply(productID: ProductID.unlockAll.rawValue)

        XCTAssertTrue(state.canPlay(game))
    }

    func testThemeProductUnlocksTheme() {
        var state = EntitlementState()
        state.apply(productID: ProductID.themeJapan.rawValue)

        XCTAssertTrue(state.canUseTheme(.japan))
        XCTAssertTrue(state.canUseTheme(.island))
    }
}

private extension GameDescriptor {
    static func fixture(access: GameAccess) -> GameDescriptor {
        GameDescriptor(
            id: "fixture",
            title: "Fixture",
            localizedTitle: "Fixture",
            subtitle: "Test",
            shortDescription: "Test game",
            access: access,
            prototype: "Test",
            modes: ["Solo"],
            controls: "Tap",
            leaderboardID: "isletgames_fixture",
            sourceName: "Unit Test",
            sourceURL: nil,
            fetchedAt: Date(timeIntervalSince1970: 0),
            licenseNote: "Test"
        )
    }
}
'@

$files["source/Packages/SharedCore/Tests/SharedCoreTests/ExportServiceTests.swift"] = @'
import XCTest
@testable import SharedCore

final class ExportServiceTests: XCTestCase {
    func testCSVExportIncludesHeaderAndRows() throws {
        let csv = try ProgressExportService().makeCSV([.fixture])

        XCTAssertTrue(csv.contains("gameID,displayName,highScore"))
        XCTAssertTrue(csv.contains("coconutcatch"))
    }

    func testPDFExportProducesPDFBytes() throws {
        let data = try ProgressExportService().makePDFData([.fixture])
        let prefix = String(data: data.prefix(4), encoding: .ascii)

        XCTAssertEqual(prefix, "%PDF")
    }

    func testEmptyExportThrows() {
        XCTAssertThrowsError(try ProgressExportService().makeCSV([]))
    }
}

private extension GameProgressSnapshot {
    static let fixture = GameProgressSnapshot(
        gameID: "coconutcatch",
        displayName: "Coconut Catch",
        highScore: 120,
        level: 3,
        playCount: 5,
        updatedAt: Date(timeIntervalSince1970: 0)
    )
}
'@

$files["source/Packages/SharedCore/Tests/SharedCoreTests/RAGIndexTests.swift"] = @'
import XCTest
@testable import SharedCore

final class RAGIndexTests: XCTestCase {
    func testQueryReturnsMatchingEvidence() {
        let index = LocalRAGIndex(chunks: [
            RAGDocumentChunk(
                id: "sand-tip",
                title: "Sand Sort Tip",
                text: "Use the clear bottle as a temporary buffer.",
                keywords: ["sand", "clear", "bottle"],
                sourceName: "Unit Test",
                sourceURL: nil,
                fetchedAt: Date(timeIntervalSince1970: 0),
                licenseNote: "Test"
            )
        ])

        let result = index.query("sand bottle")

        XCTAssertEqual(result.first?.chunkID, "sand-tip")
    }
}
'@

$files["source/IsletGames/Info.plist"] = @'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>小島遊戲機</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
    <key>UILaunchScreen</key>
    <dict>
        <key>UIColorName</key>
        <string>LaunchBackground</string>
    </dict>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
'@

$files["source/IsletGames/IsletGames.entitlements"] = @'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.game-center</key>
    <true/>
</dict>
</plist>
'@

$files["source/IsletGames/Resources/PrivacyInfo.xcprivacy"] = @'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array/>
</dict>
</plist>
'@

$files["source/IsletGames/IsletGamesApp.swift"] = @'
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
'@

$files["source/IsletGames/Models/AppModels.swift"] = @'
import Foundation
import SwiftData

@Model
final class PlayerProfile {
    @Attribute(.unique) var id: String
    var displayName: String
    var createdAt: Date
    var currentThemeRawValue: String

    init(id: String = "local-player", displayName: String = "島民玩家", createdAt: Date = .now, currentThemeRawValue: String = "island") {
        self.id = id
        self.displayName = displayName
        self.createdAt = createdAt
        self.currentThemeRawValue = currentThemeRawValue
    }
}

@Model
final class GameProgressRecord {
    @Attribute(.unique) var gameID: String
    var displayName: String
    var highScore: Int
    var level: Int
    var playCount: Int
    var updatedAt: Date

    init(gameID: String, displayName: String, highScore: Int = 0, level: Int = 1, playCount: Int = 0, updatedAt: Date = .now) {
        self.gameID = gameID
        self.displayName = displayName
        self.highScore = highScore
        self.level = level
        self.playCount = playCount
        self.updatedAt = updatedAt
    }
}

@Model
final class CollectionUnlockRecord {
    @Attribute(.unique) var cardID: String
    var unlockedAt: Date

    init(cardID: String, unlockedAt: Date = .now) {
        self.cardID = cardID
        self.unlockedAt = unlockedAt
    }
}
'@

$files["source/IsletGames/Services/GameCatalog.swift"] = @'
import Foundation
import SharedCore

enum GameCatalogError: Error {
    case missingResource(String)
}

struct GameCatalog {
    static func loadGames() -> [GameDescriptor] {
        decode([GameDescriptor].self, resource: "SeedGames", fallback: [])
    }

    static func loadCards() -> [CollectionCardDescriptor] {
        decode([CollectionCardDescriptor].self, resource: "SeedCollectionCards", fallback: [])
    }

    static func loadRAGIndex() -> LocalRAGIndex {
        let chunks = decode([RAGDocumentChunk].self, resource: "LocalRAGIndex", fallback: [])
        return LocalRAGIndex(chunks: chunks)
    }

    private static func decode<T: Decodable>(_ type: T.Type, resource: String, fallback: T) -> T {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            return fallback
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            assertionFailure("Failed to decode \(resource): \(error)")
            return fallback
        }
    }
}
'@

$files["source/IsletGames/Services/PurchaseStore.swift"] = @'
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
'@

$files["source/IsletGames/Views/AppShellView.swift"] = @'
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
'@

$files["source/IsletGames/Views/OnboardingView.swift"] = @'
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
'@

$files["source/IsletGames/Views/MainMenuView.swift"] = @'
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
'@

$files["source/IsletGames/Views/GameDetailView.swift"] = @'
import SharedCore
import SpriteKit
import SwiftData
import SwiftUI

struct GameDetailView: View {
    @EnvironmentObject private var purchaseStore: PurchaseStore
    @Environment(\.modelContext) private var modelContext
    var game: GameDescriptor

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                if purchaseStore.isUnlocked(game) {
                    gameHost
                    Button {
                        recordPlay(score: Int.random(in: 80...320))
                    } label: {
                        Label("記錄本局成果", systemImage: "checkmark.seal.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    lockedState
                }

                guideCard
            }
            .padding()
        }
        .background(IsletBackdrop(theme: .island))
        .navigationTitle(game.localizedTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 14) {
            GameGlyph(gameID: game.id)
                .frame(width: 74, height: 74)
            VStack(alignment: .leading, spacing: 5) {
                Text(game.localizedTitle)
                    .font(.title2.weight(.heavy))
                Text(game.prototype)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(game.controls)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var gameHost: some View {
        switch game.id {
        case "turtleflip":
            TurtleFlipGameView()
        case "sandsort":
            SandSortGameView()
        default:
            SpriteView(scene: GameSceneFactory.scene(for: game))
                .frame(height: 430)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.75), lineWidth: 1)
                }
        }
    }

    private var lockedState: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(IsletPalette.island.coral)
            Text("解鎖完整遊戲庫")
                .font(.title3.weight(.bold))
            Text("一次解鎖 10 款小遊戲與完整離線遊玩流程。")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            NavigationLink {
                PaywallView()
            } label: {
                Label("解鎖 $2.99", systemImage: "crown.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var guideCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("AI 玩法提示", systemImage: "sparkle.magnifyingglass")
                .font(.headline)
            Text("AI 功能目前不可用")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("非 AI 核心流程可繼續使用；分數、解鎖與進度都由 deterministic Swift service 計算。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func recordPlay(score: Int) {
        let gameID = game.id
        let descriptor = FetchDescriptor<GameProgressRecord>(
            predicate: #Predicate { $0.gameID == gameID }
        )
        let existing = try? modelContext.fetch(descriptor).first
        let record = existing ?? GameProgressRecord(gameID: game.id, displayName: game.localizedTitle)
        record.highScore = max(record.highScore, score)
        record.playCount += 1
        record.level += score > 250 ? 1 : 0
        record.updatedAt = .now
        if existing == nil {
            modelContext.insert(record)
        }
    }
}

#Preview {
    NavigationStack {
        GameDetailView(game: GameCatalog.loadGames().first!)
    }
    .environmentObject(PurchaseStore())
    .modelContainer(for: [GameProgressRecord.self, CollectionUnlockRecord.self, PlayerProfile.self], inMemory: true)
}
'@

$files["source/IsletGames/Views/TurtleFlipGameView.swift"] = @'
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
'@

$files["source/IsletGames/Views/SandSortGameView.swift"] = @'
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
'@

$files["source/IsletGames/Views/CollectionLibraryView.swift"] = @'
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
'@

$files["source/IsletGames/Views/ProgressExportView.swift"] = @'
import SharedCore
import SwiftData
import SwiftUI

struct ProgressExportView: View {
    @Query(sort: \GameProgressRecord.updatedAt, order: .reverse) private var records: [GameProgressRecord]
    @State private var exportMessage = "尚未產生匯出檔"

    private let exportService = ProgressExportService()

    var body: some View {
        List {
            Section("匯出") {
                Button {
                    exportCSV()
                } label: {
                    Label("產生 CSV", systemImage: "tablecells")
                }
                Button {
                    exportPDF()
                } label: {
                    Label("產生 PDF", systemImage: "doc.richtext")
                }
                Text(exportMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("遊玩紀錄") {
                if records.isEmpty {
                    ContentUnavailableView("還沒有紀錄", systemImage: "chart.bar", description: Text("從任一遊戲按下記錄成果後，這裡會出現本機進度。"))
                } else {
                    ForEach(records) { record in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.displayName)
                                .font(.headline)
                            Text("最高分 \(record.highScore) · Level \(record.level) · \(record.playCount) 次")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("紀錄與匯出")
    }

    private func exportCSV() {
        do {
            let csv = try exportService.makeCSV(snapshots())
            exportMessage = "CSV 已產生，\(csv.utf8.count) bytes。"
        } catch {
            exportMessage = "沒有可匯出的遊玩紀錄。"
        }
    }

    private func exportPDF() {
        do {
            let data = try exportService.makePDFData(snapshots())
            exportMessage = "PDF 已產生，\(data.count) bytes。"
        } catch {
            exportMessage = "沒有可匯出的遊玩紀錄。"
        }
    }

    private func snapshots() -> [GameProgressSnapshot] {
        records.map {
            GameProgressSnapshot(
                gameID: $0.gameID,
                displayName: $0.displayName,
                highScore: $0.highScore,
                level: $0.level,
                playCount: $0.playCount,
                updatedAt: $0.updatedAt
            )
        }
    }
}

#Preview {
    NavigationStack { ProgressExportView() }
        .modelContainer(for: [GameProgressRecord.self], inMemory: true)
}
'@

$files["source/IsletGames/Views/PaywallView.swift"] = @'
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
'@

$files["source/IsletGames/Views/SettingsView.swift"] = @'
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
'@

$files["source/IsletGames/SpriteKit/GameScenes.swift"] = @'
import SharedCore
import SpriteKit
import SwiftUI

enum GameSceneFactory {
    static func scene(for game: GameDescriptor) -> SKScene {
        switch game.id {
        case "coconutcatch":
            CoconutCatchScene(size: CGSize(width: 900, height: 700))
        case "turtleflip":
            TurtleFlipScene(game: game, size: CGSize(width: 900, height: 700))
        case "sandsort":
            SandSortScene(game: game, size: CGSize(width: 900, height: 700))
        case "fishduel":
            FishDuelScene(game: game, size: CGSize(width: 900, height: 700))
        case "fruitslicer":
            FruitSlicerScene(game: game, size: CGSize(width: 900, height: 700))
        case "dotconnect":
            DotConnectScene(game: game, size: CGSize(width: 900, height: 700))
        case "wordhunt":
            WordHuntScene(game: game, size: CGSize(width: 900, height: 700))
        case "towerstack":
            TowerStackScene(game: game, size: CGSize(width: 900, height: 700))
        case "starlink":
            StarLinkScene(game: game, size: CGSize(width: 900, height: 700))
        case "pongplus":
            PongPlusScene(game: game, size: CGSize(width: 900, height: 700))
        default:
            MiniArcadeScene(game: game, size: CGSize(width: 900, height: 700))
        }
    }
}

final class CoconutCatchScene: SKScene {
    private let basket = SKShapeNode(rectOf: CGSize(width: 130, height: 34), cornerRadius: 12)
    private var lastSpawn: TimeInterval = 0
    private var score = 0
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.30, green: 0.71, blue: 0.89, alpha: 1)
        basket.fillColor = UIColor(red: 1.0, green: 0.54, blue: 0.40, alpha: 1)
        basket.strokeColor = .white
        basket.position = CGPoint(x: size.width / 2, y: 74)
        addChild(basket)

        scoreLabel.text = "Score 0"
        scoreLabel.fontSize = 34
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 28, y: size.height - 62)
        addChild(scoreLabel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "Coconut Catch"
        title.fontSize = 38
        title.fontColor = UIColor(red: 0.12, green: 0.18, blue: 0.22, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height - 64)
        addChild(title)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        basket.position.x = max(70, min(size.width - 70, location.x))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMoved(touches, with: event)
    }

    override func update(_ currentTime: TimeInterval) {
        if currentTime - lastSpawn > 0.78 {
            spawnDrop()
            lastSpawn = currentTime
        }
        for node in children where node.name == "drop" {
            if node.position.y < 42 {
                node.removeFromParent()
            } else if abs(node.position.x - basket.position.x) < 76 && abs(node.position.y - basket.position.y) < 42 {
                score += node.userData?["hazard"] as? Bool == true ? -25 : 10
                score = max(0, score)
                scoreLabel.text = "Score \(score)"
                node.removeFromParent()
            }
        }
    }

    private func spawnDrop() {
        let hazard = Int.random(in: 0...7) == 0
        let node = SKShapeNode(circleOfRadius: hazard ? 20 : 24)
        node.name = "drop"
        node.fillColor = hazard ? .darkGray : UIColor(red: 0.42, green: 0.25, blue: 0.11, alpha: 1)
        node.strokeColor = .white
        let metadata = NSMutableDictionary()
        metadata["hazard"] = hazard
        node.userData = metadata
        node.position = CGPoint(x: CGFloat.random(in: 50...(size.width - 50)), y: size.height + 40)
        addChild(node)
        node.run(.moveBy(x: 0, y: -size.height - 120, duration: hazard ? 3.2 : 4.2))
    }
}

class MiniArcadeScene: SKScene {
    private let game: GameDescriptor
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var score = 0

    init(game: GameDescriptor, size: CGSize) {
        self.game = game
        super.init(size: size)
        scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.96, green: 0.88, blue: 0.76, alpha: 1)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = game.localizedTitle
        title.fontColor = UIColor(red: 0.12, green: 0.18, blue: 0.22, alpha: 1)
        title.fontSize = 44
        title.position = CGPoint(x: size.width / 2, y: size.height - 92)
        addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitle.text = game.controls
        subtitle.fontColor = UIColor(red: 0.18, green: 0.31, blue: 0.38, alpha: 1)
        subtitle.fontSize = 24
        subtitle.position = CGPoint(x: size.width / 2, y: size.height - 136)
        addChild(subtitle)

        scoreLabel.text = "Tap to play · Score 0"
        scoreLabel.fontColor = UIColor(red: 1.0, green: 0.54, blue: 0.40, alpha: 1)
        scoreLabel.fontSize = 28
        scoreLabel.position = CGPoint(x: size.width / 2, y: 62)
        addChild(scoreLabel)

        for index in 0..<8 {
            let node = SKShapeNode(circleOfRadius: CGFloat(20 + index * 4))
            node.fillColor = UIColor(red: CGFloat.random(in: 0.25...0.95), green: CGFloat.random(in: 0.45...0.85), blue: CGFloat.random(in: 0.55...0.95), alpha: 0.82)
            node.strokeColor = .white
            node.position = CGPoint(x: CGFloat.random(in: 80...(size.width - 80)), y: CGFloat.random(in: 160...(size.height - 190)))
            addChild(node)
            node.run(.repeatForever(.sequence([
                .moveBy(x: CGFloat.random(in: -70...70), y: CGFloat.random(in: -45...45), duration: Double.random(in: 1.1...2.2)),
                .moveBy(x: CGFloat.random(in: -70...70), y: CGFloat.random(in: -45...45), duration: Double.random(in: 1.1...2.2))
            ])))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        score += 10
        scoreLabel.text = "Tap to play · Score \(score)"
    }
}

final class TurtleFlipScene: MiniArcadeScene {}
final class SandSortScene: MiniArcadeScene {}
final class FishDuelScene: MiniArcadeScene {}
final class FruitSlicerScene: MiniArcadeScene {}
final class DotConnectScene: MiniArcadeScene {}
final class WordHuntScene: MiniArcadeScene {}
final class TowerStackScene: MiniArcadeScene {}
final class StarLinkScene: MiniArcadeScene {}
final class PongPlusScene: MiniArcadeScene {}
'@

$files["source/IsletGames/Resources/SeedGames.json"] = @'
[
  {
    "id": "coconutcatch",
    "title": "Coconut Catch",
    "localizedTitle": "椰子接接樂",
    "subtitle": "滑動籃子接住椰子",
    "shortDescription": "避開炸彈和蟹夾，連續接到椰子觸發加分節奏。",
    "access": "free",
    "prototype": "接物遊戲",
    "modes": ["Endless", "10 關挑戰", "雙人合作"],
    "controls": "左右滑動籃子",
    "leaderboardID": "isletgames_coconutcatch",
    "sourceName": "企劃案B_Islet_Games.md",
    "sourceURL": "file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md",
    "fetchedAt": "2026-05-20T00:00:00Z",
    "licenseNote": "User-provided planning document for local app implementation."
  },
  {
    "id": "turtleflip",
    "title": "Turtle Flip",
    "localizedTitle": "海龜翻翻牌",
    "subtitle": "海洋生物記憶配對",
    "shortDescription": "翻開卡片尋找相同海洋生物，浪花干擾會增加節奏感。",
    "access": "free",
    "prototype": "記憶翻牌",
    "modes": ["Easy 4x4", "Normal 4x5", "Hard 5x6", "雙人輪流"],
    "controls": "點擊翻牌",
    "leaderboardID": "isletgames_turtleflip",
    "sourceName": "企劃案B_Islet_Games.md",
    "sourceURL": "file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md",
    "fetchedAt": "2026-05-20T00:00:00Z",
    "licenseNote": "User-provided planning document for local app implementation."
  },
  {
    "id": "sandsort",
    "title": "Sand Sort",
    "localizedTitle": "沙灘排列",
    "subtitle": "把沙色整理回同色瓶",
    "shortDescription": "無時間限制，利用清水瓶暫存不同顏色沙子。",
    "access": "free",
    "prototype": "Water Sort Puzzle",
    "modes": ["100 關", "放鬆模式"],
    "controls": "點來源瓶再點目標瓶",
    "leaderboardID": "isletgames_sandsort",
    "sourceName": "企劃案B_Islet_Games.md",
    "sourceURL": "file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md",
    "fetchedAt": "2026-05-20T00:00:00Z",
    "licenseNote": "User-provided planning document for local app implementation."
  },
  {
    "id": "fishduel",
    "title": "Fish Duel",
    "localizedTitle": "釣魚大對決",
    "subtitle": "時機點擊釣到大魚",
    "shortDescription": "魚群左右游動，抓準時機下鉤，特殊魚種影響分數。",
    "access": "premium",
    "prototype": "Timing fishing",
    "modes": ["60 秒對決", "雙人輪流"],
    "controls": "單指點擊",
    "leaderboardID": "isletgames_fishduel",
    "sourceName": "企劃案B_Islet_Games.md",
    "sourceURL": "file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md",
    "fetchedAt": "2026-05-20T00:00:00Z",
    "licenseNote": "User-provided planning document for local app implementation."
  },
  {
    "id": "fruitslicer",
    "title": "Fruit Slicer",
    "localizedTitle": "水果切切切",
    "subtitle": "滑切飛起的熱帶水果",
    "shortDescription": "連切同種水果觸發 combo，避開毒蘑菇扣分。",
    "access": "premium",
    "prototype": "Fruit slicing arcade",
    "modes": ["60 秒", "禪模式", "雙人分屏"],
    "controls": "手指滑切",
    "leaderboardID": "isletgames_fruitslicer",
    "sourceName": "企劃案B_Islet_Games.md",
    "sourceURL": "file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md",
    "fetchedAt": "2026-05-20T00:00:00Z",
    "licenseNote": "User-provided planning document for local app implementation."
  },
  {
    "id": "dotconnect",
    "title": "Dot Connect",
    "localizedTitle": "點點連線",
    "subtitle": "圍成方格得分",
    "shortDescription": "在格點間畫線，搶下更多方格，可單人 AI 或雙人對戰。",
    "access": "premium",
    "prototype": "Dots and Boxes",
    "modes": ["4x4", "6x6", "8x8", "vs AI"],
    "controls": "點擊相鄰點連線",
    "leaderboardID": "isletgames_dotconnect",
    "sourceName": "企劃案B_Islet_Games.md",
    "sourceURL": "file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md",
    "fetchedAt": "2026-05-20T00:00:00Z",
    "licenseNote": "User-provided planning document for local app implementation."
  },
  {
    "id": "wordhunt",
    "title": "Word Hunt",
    "localizedTitle": "單字尋寶",
    "subtitle": "在字母島找出隱藏單字",
    "shortDescription": "旅行、動物、食物、台灣地名主題，支援中文與英文。",
    "access": "premium",
    "prototype": "Word Search",
    "modes": ["90 秒", "悠閒模式"],
    "controls": "滑動選取字母串",
    "leaderboardID": "isletgames_wordhunt",
    "sourceName": "企劃案B_Islet_Games.md",
    "sourceURL": "file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md",
    "fetchedAt": "2026-05-20T00:00:00Z",
    "licenseNote": "User-provided planning document for local app implementation."
  },
  {
    "id": "towerstack",
    "title": "Tower Stack",
    "localizedTitle": "積木疊高高",
    "subtitle": "抓準時機疊起小島塔",
    "shortDescription": "方塊左右搖擺，切落後越疊越細，完美對齊可恢復寬度。",
    "access": "premium",
    "prototype": "Stack arcade",
    "modes": ["Endless", "雙人輪流"],
    "controls": "單指點擊",
    "leaderboardID": "isletgames_towerstack",
    "sourceName": "企劃案B_Islet_Games.md",
    "sourceURL": "file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md",
    "fetchedAt": "2026-05-20T00:00:00Z",
    "licenseNote": "User-provided planning document for local app implementation."
  },
  {
    "id": "starlink",
    "title": "Star Link",
    "localizedTitle": "星座連連看",
    "subtitle": "連起相同星座符號",
    "shortDescription": "線段不能交叉，填滿格子後解鎖星座故事卡片。",
    "access": "premium",
    "prototype": "Flow Free",
    "modes": ["120 關", "5x5 到 9x9"],
    "controls": "拖曳畫線",
    "leaderboardID": "isletgames_starlink",
    "sourceName": "企劃案B_Islet_Games.md",
    "sourceURL": "file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md",
    "fetchedAt": "2026-05-20T00:00:00Z",
    "licenseNote": "User-provided planning document for local app implementation."
  },
  {
    "id": "pongplus",
    "title": "Pong Plus",
    "localizedTitle": "雙人彈球",
    "subtitle": "經典 Pong 加上特殊球",
    "shortDescription": "兩側球拍對戰，火球加速、冰球縮小對方球拍。",
    "access": "premium",
    "prototype": "Pong",
    "modes": ["雙人對戰", "vs AI Easy", "vs AI Normal", "vs AI Hard"],
    "controls": "滑動控制球拍",
    "leaderboardID": "isletgames_pongplus",
    "sourceName": "企劃案B_Islet_Games.md",
    "sourceURL": "file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md",
    "fetchedAt": "2026-05-20T00:00:00Z",
    "licenseNote": "User-provided planning document for local app implementation."
  }
]
'@

$files["source/IsletGames/Resources/SeedCollectionCards.json"] = @'
[
  {"id":"starter-shell","title":"晨光貝殼","category":"Starter","unlockRule":"完成 onboarding","body":"第一張收藏卡，代表你抵達小島。","sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"starter-palm","title":"風中的椰子樹","category":"Starter","unlockRule":"完成 onboarding","body":"椰影搖晃，適合接住第一顆椰子。","sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"sand-city-01","title":"珊瑚小鎮","category":"City","unlockRule":"完成 Sand Sort 第 5 關","body":"用珊瑚色沙瓶拼成的小鎮地圖。","sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"sand-city-02","title":"海玻璃港","category":"City","unlockRule":"完成 Sand Sort 第 10 關","body":"每一片海玻璃都像整理過的顏色。","sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"star-aries","title":"白羊航線","category":"Constellation","unlockRule":"完成 Star Link 白羊關","body":"第一條星光航線，帶你穿過夜晚海面。","sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"star-taurus","title":"金牛潮汐","category":"Constellation","unlockRule":"完成 Star Link 金牛關","body":"穩定的路徑最適合不能交叉的星線。","sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"star-gemini","title":"雙子燈塔","category":"Constellation","unlockRule":"完成 Star Link 雙子關","body":"兩座燈塔照亮雙人模式。","sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"fish-gold","title":"金魚獎章","category":"Arcade","unlockRule":"Fish Duel 釣到金魚","body":"高分魚種，提醒你抓準時機。","sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"fruit-combo","title":"熱帶連擊","category":"Arcade","unlockRule":"Fruit Slicer 一刀切 3 個同種水果","body":"combo 的手感，是小遊戲最迷人的節奏。","sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"tower-perfect","title":"完美疊塔","category":"Arcade","unlockRule":"Tower Stack 連續 5 次 perfect","body":"精準對齊後，塔會重新變寬。","sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"word-easter","title":"彩蛋單字","category":"Puzzle","unlockRule":"Word Hunt 找到隱藏彩蛋","body":"不只找單字，也找小島藏起來的玩笑。","sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"pong-fireice","title":"火冰對決","category":"Duel","unlockRule":"Pong Plus 打出火球與冰球","body":"速度與控制的雙重考驗。","sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."}
]
'@

$files["source/IsletGames/Resources/LocalRAGIndex.json"] = @'
[
  {"id":"coconut-tip","title":"Coconut Catch Tip","text":"Coconut Catch rewards steady horizontal basket movement. Avoid hazards first; combo only matters after safe positioning.","keywords":["coconut","catch","combo","hazard","basket"],"sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"turtle-tip","title":"Turtle Flip Tip","text":"In Turtle Flip, remember card positions by quadrant. In two-player mode, successful matches can shift momentum quickly.","keywords":["turtle","flip","memory","pair","cards"],"sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."},
  {"id":"sand-tip","title":"Sand Sort Tip","text":"Use the clear bottle as a temporary buffer. Do not fill it too early; save it for separating a blocked top color.","keywords":["sand","sort","clear","bottle","color"],"sourceName":"企劃案B_Islet_Games.md","sourceURL":"file:///C:/Users/jushiung/AppData/Local/Temp/%E4%BC%81%E5%8A%83%E6%A1%88B_Islet_Games.md","fetchedAt":"2026-05-20T00:00:00Z","licenseNote":"User-provided planning document."}
]
'@

$files["source/IsletGames/Assets.xcassets/Contents.json"] = @'
{
  "info": {
    "author": "xcode",
    "version": 1
  }
}
'@

$files["source/IsletGames/Assets.xcassets/AccentColor.colorset/Contents.json"] = @'
{
  "colors": [
    {
      "idiom": "universal",
      "color": {
        "color-space": "srgb",
        "components": {
          "red": "1.000",
          "green": "0.541",
          "blue": "0.396",
          "alpha": "1.000"
        }
      }
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
'@

$files["source/IsletGames/Assets.xcassets/LaunchBackground.colorset/Contents.json"] = @'
{
  "colors": [
    {
      "idiom": "universal",
      "color": {
        "color-space": "srgb",
        "components": {
          "red": "0.300",
          "green": "0.710",
          "blue": "0.890",
          "alpha": "1.000"
        }
      }
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
'@

$files["source/IsletGames/Assets.xcassets/IslandHero.imageset/Contents.json"] = @'
{
  "images": [
    {
      "filename": "IslandHero.png",
      "idiom": "universal",
      "scale": "1x"
    },
    {
      "idiom": "universal",
      "scale": "2x"
    },
    {
      "idiom": "universal",
      "scale": "3x"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
'@

$files["source/IsletGames/Assets.xcassets/AppIcon.appiconset/Contents.json"] = @'
{
  "images": [
    {"size":"20x20","idiom":"iphone","filename":"Icon-20@2x.png","scale":"2x"},
    {"size":"20x20","idiom":"iphone","filename":"Icon-20@3x.png","scale":"3x"},
    {"size":"29x29","idiom":"iphone","filename":"Icon-29@2x.png","scale":"2x"},
    {"size":"29x29","idiom":"iphone","filename":"Icon-29@3x.png","scale":"3x"},
    {"size":"40x40","idiom":"iphone","filename":"Icon-40@2x.png","scale":"2x"},
    {"size":"40x40","idiom":"iphone","filename":"Icon-40@3x.png","scale":"3x"},
    {"size":"60x60","idiom":"iphone","filename":"Icon-60@2x.png","scale":"2x"},
    {"size":"60x60","idiom":"iphone","filename":"Icon-60@3x.png","scale":"3x"},
    {"size":"20x20","idiom":"ipad","filename":"Icon-20.png","scale":"1x"},
    {"size":"20x20","idiom":"ipad","filename":"Icon-20-ipad@2x.png","scale":"2x"},
    {"size":"29x29","idiom":"ipad","filename":"Icon-29.png","scale":"1x"},
    {"size":"29x29","idiom":"ipad","filename":"Icon-29-ipad@2x.png","scale":"2x"},
    {"size":"40x40","idiom":"ipad","filename":"Icon-40.png","scale":"1x"},
    {"size":"40x40","idiom":"ipad","filename":"Icon-40-ipad@2x.png","scale":"2x"},
    {"size":"76x76","idiom":"ipad","filename":"Icon-76.png","scale":"1x"},
    {"size":"76x76","idiom":"ipad","filename":"Icon-76@2x.png","scale":"2x"},
    {"size":"83.5x83.5","idiom":"ipad","filename":"Icon-83.5@2x.png","scale":"2x"},
    {"size":"1024x1024","idiom":"ios-marketing","filename":"Icon-1024.png","scale":"1x"}
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
'@

foreach ($entry in $files.GetEnumerator()) {
    Write-TextFile -RelativePath $entry.Key -Content $entry.Value
}

function Draw-IslandIcon {
    param([string]$Path, [int]$Size)
    Add-Type -AssemblyName System.Drawing
    $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::FromArgb(77, 182, 226))
    $sand = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(244, 225, 193))
    $coral = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 138, 101))
    $green = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(129, 199, 132))
    $dark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(34, 48, 56))
    $whitePen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, [Math]::Max(4, $Size / 90))
    $g.FillEllipse($sand, $Size * 0.18, $Size * 0.50, $Size * 0.64, $Size * 0.28)
    $g.FillEllipse($coral, $Size * 0.30, $Size * 0.28, $Size * 0.40, $Size * 0.40)
    $g.DrawEllipse($whitePen, $Size * 0.30, $Size * 0.28, $Size * 0.40, $Size * 0.40)
    $g.FillPie($green, $Size * 0.30, $Size * 0.13, $Size * 0.42, $Size * 0.35, 205, 110)
    $font = New-Object System.Drawing.Font("Arial", [Math]::Max(18, $Size / 4), [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rect = New-Object System.Drawing.RectangleF -ArgumentList 0, ($Size * 0.31), $Size, ($Size * 0.28)
    $g.DrawString("IG", $font, $dark, $rect, $format)
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

function Draw-IslandHero {
    param([string]$Path)
    Add-Type -AssemblyName System.Drawing
    $width = 1200
    $height = 800
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $sky = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle -ArgumentList 0, 0, $width, $height),
        [System.Drawing.Color]::FromArgb(160, 220, 240),
        [System.Drawing.Color]::FromArgb(244, 225, 193),
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
    )
    $g.FillRectangle($sky, 0, 0, $width, $height)
    $sand = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(244, 225, 193))
    $ocean = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(77, 182, 226))
    $coral = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 138, 101))
    $green = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(129, 199, 132))
    $trunk = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(128, 86, 55))
    $ink = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(34, 48, 56))
    $g.FillRectangle($ocean, 0, 520, $width, 280)
    $g.FillEllipse($sand, 220, 410, 760, 250)
    $g.FillRectangle($trunk, 560, 250, 42, 250)
    $g.FillPie($green, 430, 170, 220, 140, 190, 130)
    $g.FillPie($green, 540, 150, 240, 160, 210, 120)
    $g.FillPie($green, 520, 120, 190, 160, 20, 125)
    $g.FillEllipse($coral, 500, 500, 200, 110)
    $font = New-Object System.Drawing.Font("Arial", 92, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString("Islet Games", $font, $ink, (New-Object System.Drawing.RectangleF -ArgumentList 0, 72, $width, 120), $format)
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$appIconDir = Join-Path $Root "source/IsletGames/Assets.xcassets/AppIcon.appiconset"
$heroDir = Join-Path $Root "source/IsletGames/Assets.xcassets/IslandHero.imageset"
$icons = @(
    @{Name="Icon-20@2x.png"; Size=40}, @{Name="Icon-20@3x.png"; Size=60},
    @{Name="Icon-29@2x.png"; Size=58}, @{Name="Icon-29@3x.png"; Size=87},
    @{Name="Icon-40@2x.png"; Size=80}, @{Name="Icon-40@3x.png"; Size=120},
    @{Name="Icon-60@2x.png"; Size=120}, @{Name="Icon-60@3x.png"; Size=180},
    @{Name="Icon-20.png"; Size=20}, @{Name="Icon-20-ipad@2x.png"; Size=40},
    @{Name="Icon-29.png"; Size=29}, @{Name="Icon-29-ipad@2x.png"; Size=58},
    @{Name="Icon-40.png"; Size=40}, @{Name="Icon-40-ipad@2x.png"; Size=80},
    @{Name="Icon-76.png"; Size=76}, @{Name="Icon-76@2x.png"; Size=152},
    @{Name="Icon-83.5@2x.png"; Size=167}, @{Name="Icon-1024.png"; Size=1024}
)

foreach ($icon in $icons) {
    Draw-IslandIcon -Path (Join-Path $appIconDir $icon.Name) -Size $icon.Size
}
Draw-IslandHero -Path (Join-Path $heroDir "IslandHero.png")

function Get-FileType {
    param([string]$Path)
    if ($Path.EndsWith(".swift")) { return "sourcecode.swift" }
    if ($Path.EndsWith(".xcassets")) { return "folder.assetcatalog" }
    if ($Path.EndsWith(".plist") -or $Path.EndsWith(".xcprivacy")) { return "text.plist.xml" }
    if ($Path.EndsWith(".json")) { return "text.json" }
    if ($Path.EndsWith(".entitlements")) { return "text.plist.entitlements" }
    return "text"
}

$script:IdCounter = 1000
$sourceFiles = @(
    "IsletGamesApp.swift",
    "Models/AppModels.swift",
    "Services/GameCatalog.swift",
    "Services/PurchaseStore.swift",
    "Views/AppShellView.swift",
    "Views/OnboardingView.swift",
    "Views/MainMenuView.swift",
    "Views/GameDetailView.swift",
    "Views/TurtleFlipGameView.swift",
    "Views/SandSortGameView.swift",
    "Views/CollectionLibraryView.swift",
    "Views/ProgressExportView.swift",
    "Views/PaywallView.swift",
    "Views/SettingsView.swift",
    "SpriteKit/GameScenes.swift"
)
$resourceFiles = @(
    "Assets.xcassets",
    "Resources/SeedGames.json",
    "Resources/SeedCollectionCards.json",
    "Resources/LocalRAGIndex.json",
    "Resources/PrivacyInfo.xcprivacy"
)

$fileRefs = @{}
$buildFiles = @{}
$sourceBuildIds = @()
$resourceBuildIds = @()
foreach ($file in $sourceFiles + $resourceFiles + @("Info.plist", "IsletGames.entitlements")) {
    $fileRefs[$file] = New-XcodeId
    if ($sourceFiles -contains $file -or $resourceFiles -contains $file) {
        $buildFiles[$file] = New-XcodeId
        if ($sourceFiles -contains $file) { $sourceBuildIds += $buildFiles[$file] }
        if ($resourceFiles -contains $file) { $resourceBuildIds += $buildFiles[$file] }
    }
}

$projectId = New-XcodeId
$mainGroupId = New-XcodeId
$productGroupId = New-XcodeId
$appGroupId = New-XcodeId
$productRefId = New-XcodeId
$targetId = New-XcodeId
$sourcesPhaseId = New-XcodeId
$resourcesPhaseId = New-XcodeId
$frameworksPhaseId = New-XcodeId
$frameworkBuildFileId = New-XcodeId
$packageRefId = New-XcodeId
$packageProductId = New-XcodeId
$projectConfigListId = New-XcodeId
$targetConfigListId = New-XcodeId
$projectDebugId = New-XcodeId
$projectReleaseId = New-XcodeId
$targetDebugId = New-XcodeId
$targetReleaseId = New-XcodeId

$buildFileSection = New-Object System.Text.StringBuilder
foreach ($file in $sourceFiles + $resourceFiles) {
    $name = Split-Path $file -Leaf
    $phaseName = if ($sourceFiles -contains $file) { "Sources" } else { "Resources" }
    [void]$buildFileSection.AppendLine("		$($buildFiles[$file]) /* $name in $phaseName */ = {isa = PBXBuildFile; fileRef = $($fileRefs[$file]) /* $name */; };")
}
[void]$buildFileSection.AppendLine("		$frameworkBuildFileId /* SharedCore in Frameworks */ = {isa = PBXBuildFile; productRef = $packageProductId /* SharedCore */; };")

$fileRefSection = New-Object System.Text.StringBuilder
foreach ($file in $sourceFiles + $resourceFiles + @("Info.plist", "IsletGames.entitlements")) {
    $name = Split-Path $file -Leaf
    $type = Get-FileType $file
    [void]$fileRefSection.AppendLine("		$($fileRefs[$file]) /* $name */ = {isa = PBXFileReference; lastKnownFileType = $type; path = $file; sourceTree = ""<group>""; };")
}
[void]$fileRefSection.AppendLine("		$productRefId /* IsletGames.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = IsletGames.app; sourceTree = BUILT_PRODUCTS_DIR; };")

$appChildren = (($sourceFiles + $resourceFiles + @("Info.plist", "IsletGames.entitlements")) | ForEach-Object {
    "				$($fileRefs[$_]) /* $(Split-Path $_ -Leaf) */,"
}) -join "`n"
$sourceBuildList = ($sourceBuildIds | ForEach-Object { "				$_," }) -join "`n"
$resourceBuildList = ($resourceBuildIds | ForEach-Object { "				$_," }) -join "`n"

$pbxproj = @"
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
$buildFileSection/* End PBXBuildFile section */

/* Begin PBXFileReference section */
$fileRefSection/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		$frameworksPhaseId /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				$frameworkBuildFileId /* SharedCore in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		$mainGroupId = {
			isa = PBXGroup;
			children = (
				$appGroupId /* IsletGames */,
				$productGroupId /* Products */,
			);
			sourceTree = ""<group>"";
		};
		$appGroupId /* IsletGames */ = {
			isa = PBXGroup;
			children = (
$appChildren
			);
			path = IsletGames;
			sourceTree = ""<group>"";
		};
		$productGroupId /* Products */ = {
			isa = PBXGroup;
			children = (
				$productRefId /* IsletGames.app */,
			);
			name = Products;
			sourceTree = ""<group>"";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		$targetId /* IsletGames */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = $targetConfigListId /* Build configuration list for PBXNativeTarget "IsletGames" */;
			buildPhases = (
				$sourcesPhaseId /* Sources */,
				$frameworksPhaseId /* Frameworks */,
				$resourcesPhaseId /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = IsletGames;
			packageProductDependencies = (
				$packageProductId /* SharedCore */,
			);
			productName = IsletGames;
			productReference = $productRefId /* IsletGames.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		$projectId /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1600;
				LastUpgradeCheck = 1600;
				TargetAttributes = {
					$targetId = {
						CreatedOnToolsVersion = 16.0;
					};
				};
			};
			buildConfigurationList = $projectConfigListId /* Build configuration list for PBXProject "IsletGames" */;
			compatibilityVersion = "Xcode 15.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
				zh-Hant,
			);
			mainGroup = $mainGroupId;
			packageReferences = (
				$packageRefId /* XCLocalSwiftPackageReference "SharedCore" */,
			);
			productRefGroup = $productGroupId /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				$targetId /* IsletGames */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		$resourcesPhaseId /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
$resourceBuildList
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		$sourcesPhaseId /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
$sourceBuildList
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		$projectDebugId /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"`$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		$projectReleaseId /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES_AGGRESSIVE;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		$targetDebugId /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_ENTITLEMENTS = IsletGames/IsletGames.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = IsletGames/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"`$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.jiang.isletgames;
				PRODUCT_NAME = "`$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_VERSION = 5.9;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		$targetReleaseId /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_ENTITLEMENTS = IsletGames/IsletGames.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = IsletGames/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"`$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.jiang.isletgames;
				PRODUCT_NAME = "`$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_VERSION = 5.9;
				TARGETED_DEVICE_FAMILY = "1,2";
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		$projectConfigListId /* Build configuration list for PBXProject "IsletGames" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				$projectDebugId /* Debug */,
				$projectReleaseId /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		$targetConfigListId /* Build configuration list for PBXNativeTarget "IsletGames" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				$targetDebugId /* Debug */,
				$targetReleaseId /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */

/* Begin XCLocalSwiftPackageReference section */
		$packageRefId /* XCLocalSwiftPackageReference "SharedCore" */ = {
			isa = XCLocalSwiftPackageReference;
			relativePath = Packages/SharedCore;
		};
/* End XCLocalSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
		$packageProductId /* SharedCore */ = {
			isa = XCSwiftPackageProductDependency;
			package = $packageRefId /* XCLocalSwiftPackageReference "SharedCore" */;
			productName = SharedCore;
		};
/* End XCSwiftPackageProductDependency section */
	};
	rootObject = $projectId /* Project object */;
}
"@

Write-TextFile -RelativePath "source/IsletGames.xcodeproj/project.pbxproj" -Content $pbxproj

Write-Host "Generated Islet Games at $Root"
