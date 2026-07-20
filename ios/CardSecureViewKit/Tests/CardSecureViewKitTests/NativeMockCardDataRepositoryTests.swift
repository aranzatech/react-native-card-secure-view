import Testing
@testable import CardSecureViewKit

struct NativeMockCardDataRepositoryTests {
    @Test
    func keepsSensitiveDataInsideNativeRepository() throws {
        let repository = NativeMockCardDataRepository()
        let card = try #require(repository.cardData(for: "card_001"))

        #expect(card.pan.hasSuffix("1234"))
        #expect(card.cvv.count == 3)
        #expect(repository.cardData(for: "unknown") == nil)
    }
}
