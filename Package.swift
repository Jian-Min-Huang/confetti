// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Confetti",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Confetti",
            path: "Sources"
        )
    ]
)
