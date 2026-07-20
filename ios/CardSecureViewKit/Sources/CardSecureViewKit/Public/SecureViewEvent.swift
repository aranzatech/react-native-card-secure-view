import Foundation

public enum SecureValidationErrorCode: String, Equatable, Sendable {
    case cardNotFound = "CARD_NOT_FOUND"
    case tokenExpired = "TOKEN_EXPIRED"
    case tokenInvalid = "TOKEN_INVALID"
    case viewAlreadyPresented = "VIEW_ALREADY_PRESENTED"
}

public struct SecureValidationFailure: Error, Equatable, Sendable {
    public let code: SecureValidationErrorCode
    public let message: String

    public init(code: SecureValidationErrorCode, message: String) {
        self.code = code
        self.message = message
    }
}

public enum SecureViewCloseReason: String, Equatable, Sendable {
    case backgroundTimeout = "BACKGROUND_TIMEOUT"
    case captureDetected = "CAPTURE_DETECTED"
    case timeout = "TIMEOUT"
    case userDismiss = "USER_DISMISS"
    case validationError = "VALIDATION_ERROR"
}

public enum SecureViewEvent: Equatable, Sendable {
    case cardDataShown(cardId: String)
    case closed(cardId: String, reason: SecureViewCloseReason)
    case opened(cardId: String)
    case validationError(
        cardId: String,
        code: SecureValidationErrorCode,
        message: String
    )
}

public typealias SecureViewEventHandler = @Sendable (SecureViewEvent) -> Void
