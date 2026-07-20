import Foundation

enum DemoSecurityDefaults {
    // Demo-only material. Production consumers must inject a key obtained from
    // their backend or protected native configuration.
    static let hmacSecret = Data("io-card-secure-view-demo-v1".utf8)
    static let maximumTokenTTL: TimeInterval = 60
    static let acceptedClockSkew: TimeInterval = 5
}
