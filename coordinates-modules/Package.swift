// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swiftlint:disable prohibited_global_constants
import PackageDescription

let package = Package(
    name: "coordinates-modules",
    platforms: [.iOS("16.4")],
    // MARK: - Products
    products: [
        // MARK: Common
        .library(
            name: "Models",
            targets: ["Models"]
        ),
        // MARK: Features
        .library(
            name: "Chart",
            targets: ["Chart"]
        ),
        .library(
            name: "Input",
            targets: ["Input"]
        ),
        // MARK: Clients
        .library(
            name: "APIClient",
            targets: ["APIClient"]
        ),
        .library(
            name: "APIClientLive",
            targets: ["APIClientLive"]
        )
    ],
    // MARK: - Dependencies
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.0.0")
    ],
    // MARK: - Targets
    targets: [
        .target(
            name: "Models",
            dependencies: []),
        .target(
            name: "Chart",
            dependencies: [
                .byName(name: "Models"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]),
        .testTarget(
            name: "ChartTests",
            dependencies: ["Chart"]),
        .target(
            name: "Input",
            dependencies: [
                .byName(name: "Models"),
                .byName(name: "Chart"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]),
        .testTarget(
            name: "InputTests",
            dependencies: ["Input"]),
        .target(
            name: "APIClient",
            dependencies: [
                .byName(name: "Models"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]),
        .target(
            name: "APIClientLive",
            dependencies: ["APIClient"]),
        .testTarget(
            name: "APIClientTests",
            dependencies: ["APIClient"])
    ]
)
