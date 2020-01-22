// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Eureka",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "Eureka", targets: ["Eureka"])
    ],
    targets: [
        .target(
            name: "Eureka",
            path: "Source"
        ),
        .testTarget(
            name: "EurekaTests",
            dependencies: ["Eureka"],
            path: "Tests"
        )
    ]
)
