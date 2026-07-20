import UIKit

final class CardSecureContentView: UIView {
    var onHide: (() -> Void)?

    private let brandLabel = UILabel()
    private let cvvRow = SensitiveDataRow(title: "CVV")
    private let expiryRow = SensitiveDataRow(title: "Vencimiento")
    private let gradientCard = GradientCardView()
    private let holderRow = SensitiveDataRow(title: "Titular")
    private let hideButton = UIButton(type: .system)
    private let panRow = SensitiveDataRow(title: "Número de tarjeta")
    private let timerLabel = UILabel()

    var containsSensitiveData: Bool {
        panRow.hasValue
            || cvvRow.hasValue
            || expiryRow.hasValue
            || holderRow.hasValue
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(with card: SensitiveCardData, secondsRemaining: Int) {
        brandLabel.text = card.brand
        panRow.setValue(card.pan)
        cvvRow.setValue(card.cvv)
        expiryRow.setValue(card.expiry)
        holderRow.setValue(card.holder)
        updateTimer(secondsRemaining: secondsRemaining)
    }

    func updateTimer(secondsRemaining: Int) {
        timerLabel.text = "Se ocultará en \(secondsRemaining)s"
        timerLabel.accessibilityLabel = "Los datos se ocultarán en \(secondsRemaining) segundos"
    }

    func clearSensitiveContent() {
        brandLabel.text = nil
        panRow.clear()
        cvvRow.clear()
        expiryRow.clear()
        holderRow.clear()
        timerLabel.text = nil
    }

    @objc func didTapHide() {
        onHide?()
    }

    private func configure() {
        backgroundColor = SecureViewPalette.background

        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = SecureViewPalette.text
        titleLabel.text = "Datos de tu tarjeta"
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = SecureViewPalette.secondaryText
        subtitleLabel.text = "Información segura y temporal"

        timerLabel.font = .preferredFont(forTextStyle: .subheadline)
        timerLabel.adjustsFontForContentSizeCategory = true
        timerLabel.textColor = SecureViewPalette.accentBlue

        brandLabel.font = .italicSystemFont(ofSize: 22)
        brandLabel.textColor = SecureViewPalette.text
        brandLabel.textAlignment = .right

        let expiryAndCvv = UIStackView(arrangedSubviews: [expiryRow, cvvRow])
        expiryAndCvv.axis = .horizontal
        expiryAndCvv.distribution = .fillEqually
        expiryAndCvv.spacing = 24

        let cardStack = UIStackView(arrangedSubviews: [brandLabel, panRow, expiryAndCvv, holderRow])
        cardStack.axis = .vertical
        cardStack.spacing = 22
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        gradientCard.addSubview(cardStack)

        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = SecureViewPalette.actionGreen
        buttonConfiguration.baseForegroundColor = SecureViewPalette.background
        buttonConfiguration.cornerStyle = .capsule
        buttonConfiguration.title = "Ocultar datos"
        buttonConfiguration.image = UIImage(systemName: "eye.slash")
        buttonConfiguration.imagePadding = 8
        hideButton.configuration = buttonConfiguration
        hideButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        hideButton.accessibilityIdentifier = "secure-view-hide-button"
        hideButton.accessibilityHint = "Cierra la vista y elimina los datos mostrados"
        hideButton.addTarget(self, action: #selector(didTapHide), for: .touchUpInside)
        hideButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true

        let contentStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            timerLabel,
            gradientCard,
            hideButton,
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.setCustomSpacing(28, after: timerLabel)
        contentStack.setCustomSpacing(28, after: gradientCard)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 28),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28),

            cardStack.topAnchor.constraint(equalTo: gradientCard.topAnchor, constant: 24),
            cardStack.leadingAnchor.constraint(equalTo: gradientCard.leadingAnchor, constant: 24),
            cardStack.trailingAnchor.constraint(equalTo: gradientCard.trailingAnchor, constant: -24),
            cardStack.bottomAnchor.constraint(equalTo: gradientCard.bottomAnchor, constant: -24),
        ])
    }
}
