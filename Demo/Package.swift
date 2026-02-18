// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ConfettiDemo",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ConfettiDemo",
            path: "Sources"
        )
    ]
)
