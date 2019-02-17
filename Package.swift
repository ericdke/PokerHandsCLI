// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "SwiftyPokerHandsCLI",
    products: [
        .executable(
            name: "SwiftyPokerHandsCLI",
            targets: ["SwiftyPokerHandsCLI"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftyPokerHandsCLI",
            dependencies: [],
            path: "Sources")
    ]
)
