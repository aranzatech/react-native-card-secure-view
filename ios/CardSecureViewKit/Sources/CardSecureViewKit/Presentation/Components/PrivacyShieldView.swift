import UIKit

final class PrivacyShieldView: UIView {
    private let iconView = UIImageView(image: UIImage(systemName: "eye.slash.fill"))
    private let messageLabel = UILabel()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func updateMessage(_ message: String) {
        messageLabel.text = message
    }

    private func configure() {
        backgroundColor = SecureViewPalette.background
        isAccessibilityElement = true
        accessibilityLabel = "Contenido protegido"

        iconView.tintColor = SecureViewPalette.accentBlue
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = SecureViewPalette.text
        titleLabel.text = "Contenido protegido"
        titleLabel.textAlignment = .center

        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = SecureViewPalette.secondaryText
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.text = "Vuelve a la aplicación para continuar."

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, messageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: 48),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
        ])
    }
}
