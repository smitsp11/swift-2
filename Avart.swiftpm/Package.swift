// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Avart",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Avart",
            targets: ["Avart"]
        )
    ],
    targets: [
        .target(
            name: "Avart",
            path: "Sources"
        )
    ]
)
