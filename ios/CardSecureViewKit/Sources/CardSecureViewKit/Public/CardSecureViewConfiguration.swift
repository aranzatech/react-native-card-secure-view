import Foundation

public struct CardSecureViewConfiguration: Equatable, Sendable {
    public static let allowedSessionTimeout: ClosedRange<TimeInterval> = 30...60

    public let concealWhenCaptured: Bool
    public let dismissAfterScreenshot: Bool
    public let sessionTimeout: TimeInterval

    public init(
        sessionTimeout: TimeInterval = 45,
        concealWhenCaptured: Bool = true,
        dismissAfterScreenshot: Bool = true
    ) {
        self.sessionTimeout = min(
            max(sessionTimeout, Self.allowedSessionTimeout.lowerBound),
            Self.allowedSessionTimeout.upperBound
        )
        self.concealWhenCaptured = concealWhenCaptured
        self.dismissAfterScreenshot = dismissAfterScreenshot
    }
}
