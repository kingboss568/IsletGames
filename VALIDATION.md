# Validation Log

Static verification run on Windows, 2026-05-20.

## Results

- Toolchain: `swift NOT FOUND`; `xcodebuild NOT FOUND`.
- Required files: OK.
- Seed data: 10 games, including 3 free and 7 premium.
- Collection seed data: 12 cards.
- Local RAG chunks: 3 chunks.
- XML parse: `Info.plist`, `IsletGames.entitlements`, `PrivacyInfo.xcprivacy` OK.
- Assets: 18 AppIcon PNGs; `IslandHero.png` is 1200x800.
- `project.pbxproj` file references: OK.
- Swift quote-balance text sanity: OK.
- SharedCore modules present: AIKit, APIClientKit, DesignSystem, ExportKit, GameRules, NotificationKit, PaywallKit, PersistenceKit, RAGKit.
- Guard scan: no mojibake replacement characters, no placeholder bundle-name text, no forbidden model-training wording.

Mac-only validation still required:

```bash
cd source
xcodebuild -project IsletGames.xcodeproj -scheme IsletGames -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build
swift test --package-path Packages/SharedCore
```
