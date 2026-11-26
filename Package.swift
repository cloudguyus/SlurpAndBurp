// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SlurpAndBurpCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "SlurpAndBurpCore", targets: ["SlurpAndBurpCore"]),
    ],
    targets: [
        .target(name: "SlurpAndBurpCore"),
        .testTarget(
            name: "SlurpAndBurpCoreTests",
            dependencies: ["SlurpAndBurpCore"]
        ),
    ]
)
