import Foundation

public struct SecureViewRequest: Equatable, Sendable {
    public let cardId: String
    public let secureToken: String

    public init(cardId: String, secureToken: String) {
        self.cardId = cardId
        self.secureToken = secureToken
    }
}
