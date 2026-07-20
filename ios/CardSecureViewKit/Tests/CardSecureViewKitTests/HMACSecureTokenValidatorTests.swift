import Foundation
import Testing
@testable import CardSecureViewKit

struct HMACSecureTokenValidatorTests {
    private let referenceDate = Date(timeIntervalSince1970: 1_800_000_000)
    private let secret = Data("unit-test-secret".utf8)

    @Test
    func acceptsValidSignedTokenForExpectedCard() throws {
        let issuer = DemoSecureTokenIssuer(
            secret: secret,
            now: { referenceDate }
        )
        let validator = makeValidator(now: referenceDate)
        let token = try #require(issuer.issueToken(for: "card_001"))

        let result = validator.validate(
            token: token,
            expectedCardId: "card_001"
        )

        let claims = try result.get()
        #expect(claims.cardId == "card_001")
        #expect(claims.expiresAt == referenceDate.addingTimeInterval(60))
    }

    @Test
    func rejectsExpiredTokenWithTypedCode() throws {
        let issuer = DemoSecureTokenIssuer(
            secret: secret,
            now: { referenceDate }
        )
        let token = try #require(issuer.issueToken(for: "card_001"))
        let validator = makeValidator(
            now: referenceDate.addingTimeInterval(61)
        )

        let result = validator.validate(
            token: token,
            expectedCardId: "card_001"
        )

        #expect(failureCode(from: result) == .tokenExpired)
    }

    @Test
    func rejectsTokenIssuedForAnotherCard() throws {
        let issuer = DemoSecureTokenIssuer(
            secret: secret,
            now: { referenceDate }
        )
        let token = try #require(issuer.issueToken(for: "card_001"))

        let result = makeValidator(now: referenceDate).validate(
            token: token,
            expectedCardId: "card_002"
        )

        #expect(failureCode(from: result) == .tokenInvalid)
    }

    @Test
    func rejectsTamperedToken() throws {
        let issuer = DemoSecureTokenIssuer(
            secret: secret,
            now: { referenceDate }
        )
        let token = try #require(issuer.issueToken(for: "card_001"))
        let tamperedToken = token.replacingOccurrences(
            of: "card_001",
            with: "card_999"
        )

        let result = makeValidator(now: referenceDate).validate(
            token: tamperedToken,
            expectedCardId: "card_999"
        )

        #expect(failureCode(from: result) == .tokenInvalid)
    }

    @Test
    func issuerRejectsUnsafeCardIdentifier() {
        let issuer = DemoSecureTokenIssuer(
            secret: secret,
            now: { referenceDate }
        )

        #expect(issuer.issueToken(for: "card.001") == nil)
        #expect(issuer.issueToken(for: "") == nil)
    }

    private func makeValidator(now: Date) -> HMACSecureTokenValidator {
        HMACSecureTokenValidator(
            secret: secret,
            now: { now }
        )
    }

    private func failureCode(
        from result: Result<SecureTokenClaims, SecureValidationFailure>
    ) -> SecureValidationErrorCode? {
        guard case let .failure(failure) = result else {
            return nil
        }
        return failure.code
    }
}
