import Foundation
import Testing
@testable import CardSecureViewKit

struct SecurityPerformanceTests {
    @Test
    func validatesOneThousandTokensWithinTwoSeconds() throws {
        let referenceDate = Date(timeIntervalSince1970: 1_800_000_000)
        let secret = Data("performance-test-secret".utf8)
        let issuer = DemoSecureTokenIssuer(
            secret: secret,
            now: { referenceDate }
        )
        let token = try #require(issuer.issueToken(for: "card_001"))
        let validator = HMACSecureTokenValidator(
            secret: secret,
            now: { referenceDate }
        )
        var validCount = 0

        let startedAt = ProcessInfo.processInfo.systemUptime
        for _ in 0..<1_000 {
            if case .success = validator.validate(
                token: token,
                expectedCardId: "card_001"
            ) {
                validCount += 1
            }
        }
        let elapsed = ProcessInfo.processInfo.systemUptime - startedAt

        #expect(validCount == 1_000)
        #expect(elapsed < 2)
    }
}
