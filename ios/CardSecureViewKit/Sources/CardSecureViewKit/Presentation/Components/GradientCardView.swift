import UIKit

final class GradientCardView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private func configure() {
        layer.cornerRadius = 24
        layer.borderColor = SecureViewPalette.border.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true

        gradientLayer.colors = [
            SecureViewPalette.surfaceHighlight.cgColor,
            SecureViewPalette.surface.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
