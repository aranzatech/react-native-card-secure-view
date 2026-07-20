import UIKit

@MainActor
final class CardSecureViewController: UIViewController {
    var onCardDataShown: (() -> Void)?
    var onRequestClose: ((SecureViewCloseReason) -> Void)?

    private let configuration: CardSecureViewConfiguration
    private let captureStateProvider: (() -> Bool)?
    private let contentView = CardSecureContentView()
    private var data: SensitiveCardData?
    private var expirationDate: Date?
    private var isAppActive = true
    private var isCaptureActive = false
    private var notificationTokens: [NSObjectProtocol] = []
    private let privacyShield = PrivacyShieldView()
    private let now: () -> Date
    private var timer: Timer?

    var containsSensitiveData: Bool {
        contentView.containsSensitiveData
    }

    var isSensitiveContentConcealed: Bool {
        contentView.isHidden
    }

    init(
        data: SensitiveCardData,
        configuration: CardSecureViewConfiguration,
        now: @escaping () -> Date = Date.init,
        captureStateProvider: (() -> Bool)? = nil
    ) {
        self.data = data
        self.configuration = configuration
        self.now = now
        self.captureStateProvider = captureStateProvider
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = SecureViewPalette.background

        contentView.translatesAutoresizingMaskIntoConstraints = false
        privacyShield.translatesAutoresizingMaskIntoConstraints = false
        privacyShield.isHidden = true

        view.addSubview(contentView)
        view.addSubview(privacyShield)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            privacyShield.topAnchor.constraint(equalTo: view.topAnchor),
            privacyShield.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            privacyShield.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            privacyShield.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.onHide = { [weak self] in
            self?.onRequestClose?(.userDismiss)
        }
        registerForPrivacyNotifications()
    }

    deinit {
        timer?.invalidate()
        notificationTokens.forEach(NotificationCenter.default.removeObserver)
    }

    func beginSession() {
        guard let data else {
            return
        }

        expirationDate = now().addingTimeInterval(configuration.sessionTimeout)
        contentView.configure(
            with: data,
            secondsRemaining: Int(configuration.sessionTimeout)
        )
        updateCaptureState()
        startTimer()
        onCardDataShown?()
    }

    func prepareForDismissal() {
        timer?.invalidate()
        timer = nil
        expirationDate = nil
        data = nil
        contentView.clearSensitiveContent()
        setPrivacyShieldVisible(true, message: "Los datos fueron ocultados.")
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(handleTimerTick),
            userInfo: nil,
            repeats: true
        )
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    @objc func handleTimerTick() {
        guard let expirationDate else {
            return
        }

        let remaining = Int(ceil(expirationDate.timeIntervalSince(now())))
        guard remaining > 0 else {
            onRequestClose?(.timeout)
            return
        }
        contentView.updateTimer(secondsRemaining: remaining)
    }

    private func registerForPrivacyNotifications() {
        let center = NotificationCenter.default
        notificationTokens = [
            center.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.handleWillResignActive()
                }
            },
            center.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.handleDidBecomeActive()
                }
            },
            center.addObserver(
                forName: UIScreen.capturedDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.handleCaptureStateChange()
                }
            },
            center.addObserver(
                forName: UIApplication.userDidTakeScreenshotNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.handleScreenshotTaken()
                }
            },
        ]
    }

    func handleWillResignActive() {
        isAppActive = false
        refreshPrivacyShield()
    }

    func handleDidBecomeActive() {
        isAppActive = true
        guard validateSessionAfterForeground() else {
            return
        }
        updateCaptureState()
    }

    func handleCaptureStateChange() {
        updateCaptureState()
    }

    private func updateCaptureState() {
        isCaptureActive = captureStateProvider?()
            ?? view.window?.screen.isCaptured
            ?? UIScreen.main.isCaptured
        refreshPrivacyShield()
    }

    func handleScreenshotTaken() {
        setPrivacyShieldVisible(
            true,
            message: "La sesión se cerró porque se detectó una captura."
        )
        if configuration.dismissAfterScreenshot {
            onRequestClose?(.captureDetected)
        }
    }

    private func validateSessionAfterForeground() -> Bool {
        guard let expirationDate else {
            return true
        }
        guard expirationDate > now() else {
            onRequestClose?(.backgroundTimeout)
            return false
        }
        return true
    }

    private func refreshPrivacyShield() {
        if !isAppActive {
            setPrivacyShieldVisible(
                true,
                message: "Vuelve a la aplicación para continuar."
            )
            return
        }

        if configuration.concealWhenCaptured && isCaptureActive {
            setPrivacyShieldVisible(
                true,
                message: "Detén la grabación o duplicación de pantalla para continuar."
            )
            return
        }

        setPrivacyShieldVisible(false, message: "")
    }

    private func setPrivacyShieldVisible(_ visible: Bool, message: String) {
        privacyShield.updateMessage(message)
        privacyShield.isHidden = !visible
        contentView.isHidden = visible
        if visible {
            UIAccessibility.post(notification: .screenChanged, argument: privacyShield)
        }
    }
}
