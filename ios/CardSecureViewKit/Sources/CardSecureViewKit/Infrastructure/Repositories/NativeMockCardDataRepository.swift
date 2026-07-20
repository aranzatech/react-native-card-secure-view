import Foundation

struct NativeMockCardDataRepository: CardSensitiveDataProviding {
    private let cards: [String: SensitiveCardData] = [
        "card_001": SensitiveCardData(
            brand: "VISA",
            cardId: "card_001",
            cvv: "842",
            expiry: "12/28",
            holder: "JUAN PEREZ",
            pan: "4111 1111 1111 1234"
        ),
        "card_002": SensitiveCardData(
            brand: "VISA",
            cardId: "card_002",
            cvv: "317",
            expiry: "09/29",
            holder: "JUAN PEREZ",
            pan: "4555 5555 5555 5678"
        ),
    ]

    func cardData(for cardId: String) -> SensitiveCardData? {
        cards[cardId]
    }
}
