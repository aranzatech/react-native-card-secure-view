import Foundation

protocol SecureTokenValidating {
    func validate(
        token: String,
        expectedCardId: String
    ) -> Result<SecureTokenClaims, SecureValidationFailure>
}
