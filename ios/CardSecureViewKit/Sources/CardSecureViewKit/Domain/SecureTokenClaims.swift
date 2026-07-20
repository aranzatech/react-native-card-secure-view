import Foundation

struct SecureTokenClaims: Equatable {
    let cardId: String
    let expiresAt: Date
    let issuedAt: Date
    let nonce: String
}
