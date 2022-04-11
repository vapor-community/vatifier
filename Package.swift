// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "vatifier",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Vatifier",
            targets: ["Vatifier"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.55.4"),
        .package(url: "https://github.com/yahoojapan/SwiftyXMLParser.git", from: "5.6.0")
    ],
    targets: [
        .target(
            name: "Vatifier",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "SwiftyXMLParser", package: "SwiftyXMLParser")
        ]),
        .testTarget(
            name: "VatifierTests",
            dependencies: ["Vatifier", .product(name: "XCTVapor", package: "vapor")]),
    ]
)
