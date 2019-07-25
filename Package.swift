// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Vinyl",
    products: [
        .library(name: "Vinyl", targets: ["Vinyl"]),
    ],
    dependencies: [
        .package(url: "https://github.com/typelift/SwiftCheck", from: "0.12.0")
    ],
    targets: [
        .target(name: "Vinyl", path: "Vinyl"),
        .testTarget(name: "VinylTests", dependencies: ["Vinyl", "SwiftCheck"], path: "VinylTests"),
    ],
    swiftLanguageVersions: [.v4_2]
)

