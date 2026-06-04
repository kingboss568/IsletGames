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