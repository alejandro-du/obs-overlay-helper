// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OBSOverlayHelper",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", exact: "1.15.0")
    ],
    targets: [
        .executableTarget(
            name: "OBSOverlayHelper",
            dependencies: [
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts")
            ]
        )
    ]
)
