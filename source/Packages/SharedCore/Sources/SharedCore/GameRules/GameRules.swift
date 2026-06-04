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