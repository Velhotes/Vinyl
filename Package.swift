// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Vinyl",
    products: [
        .library(name: "Vinyl", targets: ["Vinyl"]),
    ],
    targets: [
        .target(name: "Vinyl", path: "Vinyl"),
        .testTarget(name: "VinylTests", path: "VinylTests"),
    ],
    swiftLanguageVersions: [.v4_2]
)

