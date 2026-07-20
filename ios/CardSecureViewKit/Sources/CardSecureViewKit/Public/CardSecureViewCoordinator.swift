import UIKit

@MainActor
public final class CardSecureViewCoordinator {
    private var activeViewController: UIViewController?
    private let configuration: CardSecureViewConfiguration
    private let dataProvider: CardSensitiveDataProviding
    private let tokenValidator: SecureTokenValidating

    public init(configuration: CardSecureViewConfiguration = .init()) {
        self.configuration = configuration
        self.dataProvider = NativeMockCardDataRepository()
        self.tokenValidator = HMACSecureTokenValidator()
    }

    init(
        configuration: CardSecureViewConfiguration,
        dataProvider: CardSensitiveDataProviding,
        tokenValidator: SecureTokenValidating
    ) {
        self.configuration = configuration
        self.dataProvider = dataProvider
        self.tokenValidator = tokenValidator
    }

    public func open(
        request: SecureViewRequest,
        from presenter: UIViewController,
        onEvent: @escaping SecureViewEventHandler
    ) {
        guard activeViewController == nil else {
            onEvent(
                .validationError(
                    cardId: request.cardId,
                    code: .viewAlreadyPresented,
                    message: "Ya existe una vista segura abierta."
                )
            )
            return
        }

        switch tokenValidator.validate(
            token: request.secureToken,
            expectedCardId: request.cardId
        ) {
        case let .failure(failure):
            presentValidationError(
                failure,
                cardId: request.cardId,
                from: presenter,
                onEvent: onEvent
            )
        case .success:
            guard let cardData = dataProvider.cardData(for: request.cardId) else {
                let failure = SecureValidationFailure(
                    code: .cardNotFound,
                    message: "No encontramos la tarjeta solicitada."
                )
                presentValidationError(
                    failure,
                    cardId: request.cardId,
                    from: presenter,
                    onEvent: onEvent
                )
                return
            }
            presentCardData(
                cardData,
                from: presenter,
                onEvent: onEvent
            )
        }
    }

    private func presentCardData(
        _ data: SensitiveCardData,
        from presenter: UIViewController,
        onEvent: @escaping SecureViewEventHandler
    ) {
        let controller = CardSecureViewController(
            data: data,
            configuration: configuration
        )
        activeViewController = controller

        controller.onCardDataShown = {
            onEvent(.cardDataShown(cardId: data.cardId))
        }
        controller.onRequestClose = { [weak self, weak controller] reason in
            guard let self, let controller else {
                return
            }
            self.close(
                controller,
                cardId: data.cardId,
                reason: reason,
                onEvent: onEvent
            )
        }

        presenter.present(controller, animated: true) {
            onEvent(.opened(cardId: data.cardId))
            controller.beginSession()
        }
    }

    private func presentValidationError(
        _ failure: SecureValidationFailure,
        cardId: String,
        from presenter: UIViewController,
        onEvent: @escaping SecureViewEventHandler
    ) {
        onEvent(
            .validationError(
                cardId: cardId,
                code: failure.code,
                message: failure.message
            )
        )

        let controller = SecureViewErrorViewController(failure: failure)
        activeViewController = controller
        controller.onClose = { [weak self, weak controller] in
            guard let self, let controller else {
                return
            }
            self.closeError(
                controller,
                cardId: cardId,
                onEvent: onEvent
            )
        }
        presenter.present(controller, animated: true)
    }

    private func close(
        _ controller: CardSecureViewController,
        cardId: String,
        reason: SecureViewCloseReason,
        onEvent: @escaping SecureViewEventHandler
    ) {
        guard activeViewController === controller else {
            return
        }
        controller.prepareForDismissal()
        controller.dismiss(animated: true) { [weak self] in
            self?.activeViewController = nil
            onEvent(.closed(cardId: cardId, reason: reason))
        }
    }

    private func closeError(
        _ controller: SecureViewErrorViewController,
        cardId: String,
        onEvent: @escaping SecureViewEventHandler
    ) {
        guard activeViewController === controller else {
            return
        }
        controller.dismiss(animated: true) { [weak self] in
            self?.activeViewController = nil
            onEvent(.closed(cardId: cardId, reason: .validationError))
        }
    }
}
