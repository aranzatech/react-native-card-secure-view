import Foundation

protocol CardSensitiveDataProviding {
    func cardData(for cardId: String) -> SensitiveCardData?
}
