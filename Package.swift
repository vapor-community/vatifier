// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "vatifier",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Vatifier",
            targets: ["Vatifier"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/yahoojapan/SwiftyXMLParser.git", from: "5.2.0")
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
