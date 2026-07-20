import Foundation

struct SensitiveCardData: Equatable {
    let brand: String
    let cardId: String
    let cvv: String
    let expiry: String
    let holder: String
    let pan: String
}
