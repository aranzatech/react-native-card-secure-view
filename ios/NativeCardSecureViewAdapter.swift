import CardSecureViewKit
import UIKit

private final class NativeSecureViewEventSink: @unchecked Sendable {
    private let handler: ([String: String]) -> Void

    init(handler: @escaping ([String: String]) -> Void) {
        self.handler = handler
    }

    func send(_ event: SecureViewEvent) {
        handler(Self.payload(for: event))
    }

    private static func payload(for event: SecureViewEvent) -> [String: String] {
        switch event {
        case let .opened(cardId):
            return ["type": "opened", "cardId": cardId]
        case let .cardDataShown(cardId):
            return ["type": "cardDataShown", "cardId": cardId]
        case let .validationError(cardId, code, message):
            return [
                "type": "validationError",
                "cardId": cardId,
                "code": code.rawValue,
                "message": message,
            ]
        case let .closed(cardId, reason):
            return [
                "type": "closed",
                "cardId": cardId,
                "reason": reason.rawValue,
            ]
        }
    }
}

@MainActor
@objc(NativeCardSecureViewAdapter)
final class NativeCardSecureViewAdapter: NSObject {
    private let coordinator = CardSecureViewCoordinator(
        configuration: CardSecureViewConfiguration(sessionTimeout: 45)
    )
    private let tokenIssuer = DemoSecureTokenIssuer()

    @objc(createSecureTokenForCardId:)
    func createSecureToken(forCardId cardId: String) -> String? {
        tokenIssuer.issueToken(for: cardId, validFor: 60)
    }

    @objc(openSecureViewWithCardId:secureToken:eventHandler:completion:)
    func openSecureView(
        cardId: String,
        secureToken: String,
        eventHandler: @escaping ([String: String]) -> Void,
        completion: @escaping (String?) -> Void
    ) {
        guard let presenter = Self.topViewController() else {
            completion("No se encontró un controlador desde el cual presentar la vista segura.")
            return
        }

        let sink = NativeSecureViewEventSink(handler: eventHandler)
        coordinator.open(
            request: SecureViewRequest(
                cardId: cardId,
                secureToken: secureToken
            ),
            from: presenter,
            onEvent: { event in
                sink.send(event)
            }
        )
        completion(nil)
    }

    private static func topViewController() -> UIViewController? {
        let activeWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)

        guard let rootViewController = activeWindow?.rootViewController else {
            return nil
        }

        return topViewController(from: rootViewController)
    }

    private static func topViewController(
        from viewController: UIViewController
    ) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return topViewController(from: presented)
        }
        if let navigation = viewController as? UINavigationController,
           let visible = navigation.visibleViewController {
            return topViewController(from: visible)
        }
        if let tab = viewController as? UITabBarController,
           let selected = tab.selectedViewController {
            return topViewController(from: selected)
        }
        return viewController
    }
}
