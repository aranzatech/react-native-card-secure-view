// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CardSecureViewKit",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "CardSecureViewKit",
            targets: ["CardSecureViewKit"]
        ),
    ],
    targets: [
        .target(name: "CardSecureViewKit"),
        .testTarget(
            name: "CardSecureViewKitTests",
            dependencies: ["CardSecureViewKit"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
