import Testing
import UIKit
@testable import CardSecureViewKit

@MainActor
struct CardSecureViewCoordinatorTests {
    @Test
    func emitsValidationErrorAndPresentsErrorScreen() {
        let failure = SecureValidationFailure(
            code: .tokenInvalid,
            message: "Invalid token"
        )
        let recorder = SecureViewEventRecorder()
        let presenter = PresentingViewControllerSpy()
        let coordinator = CardSecureViewCoordinator(
            configuration: .init(),
            dataProvider: CardDataProviderStub(card: nil),
            tokenValidator: TokenValidatorStub(result: .failure(failure))
        )

        coordinator.open(
            request: .init(cardId: "card_001", secureToken: "invalid"),
            from: presenter,
            onEvent: { recorder.record($0) }
        )

        #expect(
            recorder.events == [
                .validationError(
                    cardId: "card_001",
                    code: .tokenInvalid,
                    message: "Invalid token"
                ),
            ]
        )
        #expect(presenter.lastPresented is SecureViewErrorViewController)
    }

    @Test
    func emitsCardNotFoundForValidTokenWithoutNativeData() {
        let recorder = SecureViewEventRecorder()
        let presenter = PresentingViewControllerSpy()
        let coordinator = CardSecureViewCoordinator(
            configuration: .init(),
            dataProvider: CardDataProviderStub(card: nil),
            tokenValidator: TokenValidatorStub(result: .success(validClaims))
        )

        coordinator.open(
            request: .init(cardId: "card_404", secureToken: "valid"),
            from: presenter,
            onEvent: { recorder.record($0) }
        )

        #expect(
            recorder.events.first == .validationError(
                cardId: "card_404",
                code: .cardNotFound,
                message: "No encontramos la tarjeta solicitada."
            )
        )
    }

    @Test
    func emitsOpenedAndCardDataShownForValidRequest() throws {
        let recorder = SecureViewEventRecorder()
        let presenter = PresentingViewControllerSpy()
        let coordinator = CardSecureViewCoordinator(
            configuration: .init(),
            dataProvider: CardDataProviderStub(card: card),
            tokenValidator: TokenValidatorStub(result: .success(validClaims))
        )

        coordinator.open(
            request: .init(cardId: "card_001", secureToken: "valid"),
            from: presenter,
            onEvent: { recorder.record($0) }
        )

        #expect(
            recorder.events == [
                .opened(cardId: "card_001"),
                .cardDataShown(cardId: "card_001"),
            ]
        )
        let secureController = try #require(
            presenter.lastPresented as? CardSecureViewController
        )
        secureController.prepareForDismissal()
    }

    @Test
    func rejectsASecondSecureViewWhileOneIsActive() {
        let recorder = SecureViewEventRecorder()
        let presenter = PresentingViewControllerSpy()
        let coordinator = CardSecureViewCoordinator(
            configuration: .init(),
            dataProvider: CardDataProviderStub(card: card),
            tokenValidator: TokenValidatorStub(result: .success(validClaims))
        )
        let request = SecureViewRequest(
            cardId: "card_001",
            secureToken: "valid"
        )

        coordinator.open(
            request: request,
            from: presenter,
            onEvent: { recorder.record($0) }
        )
        coordinator.open(
            request: request,
            from: presenter,
            onEvent: { recorder.record($0) }
        )

        #expect(
            recorder.events.contains(
                .validationError(
                    cardId: "card_001",
                    code: .viewAlreadyPresented,
                    message: "Ya existe una vista segura abierta."
                )
            )
        )
        (presenter.lastPresented as? CardSecureViewController)?
            .prepareForDismissal()
    }

    private var validClaims: SecureTokenClaims {
        SecureTokenClaims(
            cardId: "card_001",
            expiresAt: Date(timeIntervalSince1970: 1_800_000_060),
            issuedAt: Date(timeIntervalSince1970: 1_800_000_000),
            nonce: "nonce"
        )
    }

    private var card: SensitiveCardData {
        SensitiveCardData(
            brand: "VISA",
            cardId: "card_001",
            cvv: "842",
            expiry: "12/28",
            holder: "JUAN PEREZ",
            pan: "4111 1111 1111 1234"
        )
    }
}

private struct TokenValidatorStub: SecureTokenValidating {
    let result: Result<SecureTokenClaims, SecureValidationFailure>

    func validate(
        token: String,
        expectedCardId: String
    ) -> Result<SecureTokenClaims, SecureValidationFailure> {
        result
    }
}

private struct CardDataProviderStub: CardSensitiveDataProviding {
    let card: SensitiveCardData?

    func cardData(for cardId: String) -> SensitiveCardData? {
        card
    }
}

@MainActor
private final class PresentingViewControllerSpy: UIViewController {
    private(set) var lastPresented: UIViewController?

    override func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        lastPresented = viewControllerToPresent
        viewControllerToPresent.loadViewIfNeeded()
        completion?()
    }
}

private final class SecureViewEventRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var storedEvents: [SecureViewEvent] = []

    var events: [SecureViewEvent] {
        lock.lock()
        defer { lock.unlock() }
        return storedEvents
    }

    func record(_ event: SecureViewEvent) {
        lock.lock()
        defer { lock.unlock() }
        storedEvents.append(event)
    }
}
