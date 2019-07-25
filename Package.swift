// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Vinyl",
    products: [
        .library(name: "Vinyl", targets: ["Vinyl"]),
    ],
    targets: [
        .target(name: "Vinyl", path: "Vinyl"),
    ],
    swiftLanguageVersions: [.v4_2]
)

