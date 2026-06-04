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