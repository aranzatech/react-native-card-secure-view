import Testing
import UIKit
@testable import CardSecureViewKit

@MainActor
struct CardSecureViewControllerTests {
    private let referenceDate = Date(timeIntervalSince1970: 1_800_000_000)

    @Test
    func clearsSensitiveLabelsBeforeDismissal() {
        let controller = makeController()
        controller.loadViewIfNeeded()
        controller.beginSession()

        #expect(controller.containsSensitiveData)

        controller.prepareForDismissal()

        #expect(!controller.containsSensitiveData)
        #expect(controller.isSensitiveContentConcealed)
    }

    @Test
    func requestsCloseWhenSessionTimeoutExpires() {
        var currentDate = referenceDate
        let controller = makeController(now: { currentDate })
        var closeReason: SecureViewCloseReason?
        controller.onRequestClose = { closeReason = $0 }
        controller.loadViewIfNeeded()
        controller.beginSession()

        currentDate = referenceDate.addingTimeInterval(31)
        controller.handleTimerTick()

        #expect(closeReason == .timeout)
        controller.prepareForDismissal()
    }

    @Test
    func keepsContentConcealedWhenSessionExpiresInBackground() {
        var currentDate = referenceDate
        let controller = makeController(now: { currentDate })
        var closeReason: SecureViewCloseReason?
        controller.onRequestClose = { closeReason = $0 }
        controller.loadViewIfNeeded()
        controller.beginSession()

        controller.handleWillResignActive()
        #expect(controller.isSensitiveContentConcealed)

        currentDate = referenceDate.addingTimeInterval(31)
        controller.handleDidBecomeActive()

        #expect(closeReason == .backgroundTimeout)
        #expect(controller.isSensitiveContentConcealed)
        controller.prepareForDismissal()
    }

    @Test
    func concealsContentWhileScreenCaptureIsActive() {
        var isCaptured = true
        let controller = makeController(
            captureStateProvider: { isCaptured }
        )
        controller.loadViewIfNeeded()
        controller.beginSession()

        #expect(controller.isSensitiveContentConcealed)

        isCaptured = false
        controller.handleCaptureStateChange()

        #expect(!controller.isSensitiveContentConcealed)
        controller.prepareForDismissal()
    }

    @Test
    func screenshotConcealsContentAndClosesSession() {
        let controller = makeController()
        var closeReason: SecureViewCloseReason?
        controller.onRequestClose = { closeReason = $0 }
        controller.loadViewIfNeeded()
        controller.beginSession()

        controller.handleScreenshotTaken()

        #expect(controller.isSensitiveContentConcealed)
        #expect(closeReason == .captureDetected)
        controller.prepareForDismissal()
    }

    @Test
    func screenshotCanConcealWithoutAutomaticallyClosing() {
        let controller = makeController(
            configuration: CardSecureViewConfiguration(
                dismissAfterScreenshot: false
            )
        )
        var closeReason: SecureViewCloseReason?
        controller.onRequestClose = { closeReason = $0 }
        controller.loadViewIfNeeded()
        controller.beginSession()

        controller.handleScreenshotTaken()

        #expect(controller.isSensitiveContentConcealed)
        #expect(closeReason == nil)
        controller.prepareForDismissal()
    }

    @Test
    func hideButtonRequestsUserDismiss() throws {
        let controller = makeController()
        var closeReason: SecureViewCloseReason?
        controller.onRequestClose = { closeReason = $0 }
        controller.loadViewIfNeeded()
        controller.beginSession()
        let button = try #require(
            findButton(
                withAccessibilityIdentifier: "secure-view-hide-button",
                in: controller.view
            )
        )

        let registeredAction = try #require(hideAction(for: button))
        #expect(registeredAction.contains("didTapHide"))
        let contentView = try #require(
            ancestor(of: button, as: CardSecureContentView.self)
        )
        contentView.didTapHide()

        #expect(closeReason == .userDismiss)
        controller.prepareForDismissal()
    }

    private func makeController(
        configuration: CardSecureViewConfiguration = .init(sessionTimeout: 30),
        now: @escaping () -> Date = { Date(timeIntervalSince1970: 1_800_000_000) },
        captureStateProvider: @escaping () -> Bool = { false }
    ) -> CardSecureViewController {
        CardSecureViewController(
            data: SensitiveCardData(
                brand: "VISA",
                cardId: "card_001",
                cvv: "842",
                expiry: "12/28",
                holder: "JUAN PEREZ",
                pan: "4111 1111 1111 1234"
            ),
            configuration: configuration,
            now: now,
            captureStateProvider: captureStateProvider
        )
    }

    private func findButton(
        withAccessibilityIdentifier identifier: String,
        in view: UIView
    ) -> UIButton? {
        if let button = view as? UIButton,
           button.accessibilityIdentifier == identifier {
            return button
        }

        return view.subviews.lazy.compactMap {
            findButton(withAccessibilityIdentifier: identifier, in: $0)
        }.first
    }

    private func hideAction(for button: UIButton) -> String? {
        for target in button.allTargets {
            let actionName = button.actions(
                forTarget: target,
                forControlEvent: .touchUpInside
            )?.first(where: { $0.contains("didTapHide") })
            if let actionName {
                return actionName
            }
        }
        return nil
    }

    private func ancestor<T: UIView>(
        of view: UIView,
        as type: T.Type
    ) -> T? {
        var current = view.superview
        while let candidate = current {
            if let match = candidate as? T {
                return match
            }
            current = candidate.superview
        }
        return nil
    }
}
