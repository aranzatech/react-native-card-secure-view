import CryptoKit
import Foundation

struct HMACSecureTokenValidator: SecureTokenValidating {
    private let acceptedClockSkew: TimeInterval
    private let maximumTokenTTL: TimeInterval
    private let now: () -> Date
    private let secret: Data

    init(
        secret: Data = DemoSecurityDefaults.hmacSecret,
        maximumTokenTTL: TimeInterval = DemoSecurityDefaults.maximumTokenTTL,
        acceptedClockSkew: TimeInterval = DemoSecurityDefaults.acceptedClockSkew,
        now: @escaping () -> Date = Date.init
    ) {
        self.secret = secret
        self.maximumTokenTTL = maximumTokenTTL
        self.acceptedClockSkew = acceptedClockSkew
        self.now = now
    }

    func validate(
        token: String,
        expectedCardId: String
    ) -> Result<SecureTokenClaims, SecureValidationFailure> {
        let components = token.split(separator: ".", omittingEmptySubsequences: false)
        guard components.count == 6 else {
            return .failure(.invalidToken)
        }

        let values = components.map(String.init)
        guard
            values[0] == SecureTokenCodec.version,
            values[1] == expectedCardId,
            let issuedAtSeconds = TimeInterval(values[2]),
            let expiresAtSeconds = TimeInterval(values[3]),
            !values[4].isEmpty,
            let suppliedSignature = SecureTokenCodec.data(fromBase64URL: values[5])
        else {
            return .failure(.invalidToken)
        }

        let payload = values[0...4].joined(separator: ".")
        let key = SymmetricKey(data: secret)
        guard HMAC<SHA256>.isValidAuthenticationCode(
            suppliedSignature,
            authenticating: Data(payload.utf8),
            using: key
        ) else {
            return .failure(.invalidToken)
        }

        let issuedAt = Date(timeIntervalSince1970: issuedAtSeconds)
        let expiresAt = Date(timeIntervalSince1970: expiresAtSeconds)
        let currentDate = now()
        let lifetime = expiresAt.timeIntervalSince(issuedAt)

        guard
            lifetime > 0,
            lifetime <= maximumTokenTTL,
            issuedAt.timeIntervalSince(currentDate) <= acceptedClockSkew
        else {
            return .failure(.invalidToken)
        }

        guard currentDate < expiresAt else {
            return .failure(.expiredToken)
        }

        return .success(
            SecureTokenClaims(
                cardId: expectedCardId,
                expiresAt: expiresAt,
                issuedAt: issuedAt,
                nonce: values[4]
            )
        )
    }
}

private extension SecureValidationFailure {
    static let expiredToken = SecureValidationFailure(
        code: .tokenExpired,
        message: "El token de seguridad expiró. Solicita uno nuevo."
    )

    static let invalidToken = SecureValidationFailure(
        code: .tokenInvalid,
        message: "No pudimos validar el token de seguridad."
    )
}
