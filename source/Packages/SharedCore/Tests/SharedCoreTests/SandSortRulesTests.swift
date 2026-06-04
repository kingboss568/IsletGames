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