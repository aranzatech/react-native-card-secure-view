import Foundation

public struct DemoSecureTokenIssuer {
    private let now: () -> Date
    private let secret: Data

    public init() {
        self.init(secret: DemoSecurityDefaults.hmacSecret, now: Date.init)
    }

    init(secret: Data, now: @escaping () -> Date) {
        self.secret = secret
        self.now = now
    }

    public func issueToken(
        for cardId: String,
        validFor requestedTTL: TimeInterval = 60
    ) -> String? {
        guard isValidCardId(cardId) else {
            return nil
        }

        let ttl = min(max(requestedTTL, 1), DemoSecurityDefaults.maximumTokenTTL)
        let issuedAt = Int(now().timeIntervalSince1970)
        let expiresAt = issuedAt + Int(ttl)
        let nonce = UUID().uuidString.lowercased()
        let payload = [
            SecureTokenCodec.version,
            cardId,
            String(issuedAt),
            String(expiresAt),
            nonce,
        ].joined(separator: ".")
        let signature = SecureTokenCodec.authenticationCode(
            for: payload,
            secret: secret
        )

        return payload + "." + SecureTokenCodec.base64URLString(from: signature)
    }

    private func isValidCardId(_ cardId: String) -> Bool {
        !cardId.isEmpty && !cardId.contains(".") && cardId.count <= 64
    }
}
