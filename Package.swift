// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Headroom",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "HeadroomCore", targets: ["HeadroomCore"]),
        .executable(name: "HeadroomApp", targets: ["HeadroomApp"]),
        .executable(name: "headroom", targets: ["HeadroomCLI"])
    ],
    targets: [
        .target(
            name: "HeadroomCore",
            dependencies: [],
            path: "Sources/HeadroomCore"
        ),
        .executableTarget(
            name: "HeadroomApp",
            dependencies: ["HeadroomCore"],
            path: "Sources/HeadroomApp"
        ),
        .executableTarget(
            name: "HeadroomCLI",
            dependencies: ["HeadroomCore"],
            path: "Sources/HeadroomCLI"
        ),
        .testTarget(
            name: "HeadroomCoreTests",
            dependencies: ["HeadroomCore"],
            path: "Tests/HeadroomCoreTests"
        )
    ]
)
