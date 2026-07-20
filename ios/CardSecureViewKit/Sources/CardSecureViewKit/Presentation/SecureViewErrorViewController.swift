import UIKit

@MainActor
final class SecureViewErrorViewController: UIViewController {
    var onClose: (() -> Void)?

    private let failure: SecureValidationFailure

    init(failure: SecureValidationFailure) {
        self.failure = failure
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SecureViewPalette.background

        let iconView = UIImageView(image: UIImage(systemName: "exclamationmark.shield.fill"))
        iconView.tintColor = SecureViewPalette.error
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let codeLabel = UILabel()
        codeLabel.font = .monospacedSystemFont(ofSize: 13, weight: .semibold)
        codeLabel.textColor = SecureViewPalette.error
        codeLabel.text = failure.code.rawValue
        codeLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = SecureViewPalette.text
        titleLabel.text = failure.code == .tokenExpired
            ? "Tu sesión expiró"
            : "No pudimos abrir los datos"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let messageLabel = UILabel()
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = SecureViewPalette.secondaryText
        messageLabel.text = failure.message
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let closeButton = UIButton(type: .system)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = SecureViewPalette.actionGreen
        buttonConfiguration.baseForegroundColor = SecureViewPalette.background
        buttonConfiguration.cornerStyle = .capsule
        buttonConfiguration.title = "Volver a mis tarjetas"
        closeButton.configuration = buttonConfiguration
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        closeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true

        let stack = UIStackView(arrangedSubviews: [
            iconView,
            codeLabel,
            titleLabel,
            messageLabel,
            closeButton,
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(24, after: messageLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: 64),
            iconView.widthAnchor.constraint(equalToConstant: 64),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
        ])
    }

    @objc private func didTapClose() {
        onClose?()
    }
}
