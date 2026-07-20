import Testing
@testable import CardSecureViewKit

struct CardSecureViewConfigurationTests {
    @Test
    func keepsTimeoutInsideSecurityRange() {
        #expect(CardSecureViewConfiguration(sessionTimeout: 10).sessionTimeout == 30)
        #expect(CardSecureViewConfiguration(sessionTimeout: 45).sessionTimeout == 45)
        #expect(CardSecureViewConfiguration(sessionTimeout: 90).sessionTimeout == 60)
    }
}
