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