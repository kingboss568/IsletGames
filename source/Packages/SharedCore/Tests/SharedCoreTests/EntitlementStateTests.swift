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