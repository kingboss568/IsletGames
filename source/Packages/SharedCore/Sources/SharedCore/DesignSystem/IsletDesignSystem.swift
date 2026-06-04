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