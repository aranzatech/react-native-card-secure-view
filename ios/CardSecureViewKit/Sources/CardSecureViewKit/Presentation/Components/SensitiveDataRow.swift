import UIKit

final class SensitiveDataRow: UIStackView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    var hasValue: Bool {
        valueLabel.text?.isEmpty == false
    }

    init(title: String) {
        super.init(frame: .zero)
        configure(title: title)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setValue(_ value: String) {
        valueLabel.text = value
        accessibilityLabel = "\(titleLabel.text ?? ""), \(value)"
    }

    func clear() {
        valueLabel.text = nil
        accessibilityLabel = titleLabel.text
    }

    private func configure(title: String) {
        axis = .vertical
        spacing = 4
        isAccessibilityElement = true

        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = SecureViewPalette.secondaryText
        titleLabel.text = title

        valueLabel.font = .monospacedSystemFont(ofSize: 19, weight: .semibold)
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.textColor = SecureViewPalette.text
        valueLabel.numberOfLines = 1
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.75

        addArrangedSubview(titleLabel)
        addArrangedSubview(valueLabel)
    }
}
