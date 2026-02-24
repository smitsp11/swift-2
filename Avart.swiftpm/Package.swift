// swift-tools-version: 6.0

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Avart",
    platforms: [
        .iOS("18.0"),
        .macOS("15.0")
    ],
    products: [
        .iOSApplication(
            name: "Avart",
            targets: ["Avart"],
            displayVersion: "1.0",
            bundleVersion: "1",
            accentColor: .presetColor(.orange),
            supportedDeviceFamilies: [.pad],
            supportedInterfaceOrientations: [
                .landscapeRight,
                .landscapeLeft
            ],
            capabilities: [
                .microphone(purposeString: "Avart listens for claps and rhythmic sounds to generate Rangoli art in real time.")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "Avart",
            path: "Sources"
        )
    ]
)
