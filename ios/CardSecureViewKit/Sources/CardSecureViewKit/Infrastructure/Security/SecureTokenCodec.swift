import CryptoKit
import Foundation

enum SecureTokenCodec {
    static let version = "v1"

    static func authenticationCode(
        for payload: String,
        secret: Data
    ) -> Data {
        let key = SymmetricKey(data: secret)
        let code = HMAC<SHA256>.authenticationCode(
            for: Data(payload.utf8),
            using: key
        )
        return Data(code)
    }

    static func base64URLString(from data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    static func data(fromBase64URL value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = base64.count % 4
        if remainder != 0 {
            base64.append(String(repeating: "=", count: 4 - remainder))
        }

        return Data(base64Encoded: base64)
    }
}
