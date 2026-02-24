// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Avart",
    platforms: [
        .iOS("26.0"),
        .macOS("26.0")
    ],
    products: [
        .iOSApplication(
            name: "Avart",
            targets: ["Avart"],
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .flame),
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
