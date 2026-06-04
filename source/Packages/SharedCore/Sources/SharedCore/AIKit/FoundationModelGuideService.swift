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