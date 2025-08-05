// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "cdk-swift",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "CashuDevKit",
            targets: ["CashuDevKit"]
        )
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "cdkFFI",
            path: "cdkFFI.xcframework"
        ),
        .systemLibrary(
            name: "CashuDevKitFFI",
            path: "Sources/CashuDevKitFFI"
        ),
        .target(
            name: "CashuDevKit",
            dependencies: ["CashuDevKitFFI", "cdkFFI"],
            linkerSettings: [
                .linkedLibrary("resolv")
            ]
        ),
        .testTarget(
            name: "CashuDevKitTests",
            dependencies: ["CashuDevKit"]
        )
    ]
)