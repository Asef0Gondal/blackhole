// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Blackhole",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Blackhole", targets: ["Blackhole"])
    ],
    targets: [
        .executableTarget(
            name: "Blackhole",
            path: "Sources"
        )
    ]
)
