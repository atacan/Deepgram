// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDeepgram",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        // the models for request and response
        .library(name: "SwiftDeepgram", targets: ["SwiftDeepgram"]),
        // local use for apps
        .library(name: "DeepgramDependency", targets: ["DeepgramDependency"]),
        // usable on linux server
        .library(name: "DeepgramServerDependency", targets: ["DeepgramServerDependency"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.2.1"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.6.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "SwiftDeepgram"),
        .target(name: "DeepgramDependency",
                dependencies: [
                    "SwiftDeepgram",
                    .product(name: "Dependencies", package: "swift-dependencies"),
                ]),

            .target(name: "DeepgramServerDependency",
                    dependencies: [
                        "SwiftDeepgram",
                        .product(name: "Dependencies", package: "swift-dependencies"),
                        .product(name: "AsyncHTTPClient", package: "async-http-client"),
                    ]),

            .testTarget(name: "SwiftDeepgramTests",
                        dependencies: ["SwiftDeepgram"]),
        
        .testTarget(name: "DeepgramDependencyTests", dependencies: ["DeepgramDependency"]),
    ]
)
