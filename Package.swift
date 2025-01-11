// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Deepgram",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        // the models for request and response
        .library(name: "Deepgram", targets: ["Deepgram"]),
        // local use for apps
        .library(name: "DeepgramDependency", targets: ["DeepgramDependency"]),
        // AsyncHTTPClient implementation
        .library(name: "Deepgram_AHC", targets: ["Deepgram_AHC"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.1"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.6.0"),
        .package(url: "git@github.com:atacan/WebSocketDependency.git", branch: "main"),
        // .package(path: "../WebSocketDependency"),
        .package(url: "git@github.com:atacan/AudioRecorder.git", branch: "main"),
        // .package(path: "../AudioRecorder"),

        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "Deepgram"),
        .target(
            name: "DeepgramDependency",
            dependencies: [
                "Deepgram",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "WebSocketDependency", package: "WebSocketDependency"),
                .product(name: "AudioDataStreamClient", package: "AudioRecorder"),
            ]
        ),
        .target(
            name: "Deepgram_AHC",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
            ],
            exclude: [
                "openapi.json",
                "openapi-generator-config.yaml",
            ]
        ),
        .testTarget(
            name: "DeepgramTests",
            dependencies: ["Deepgram"]
        ),
        .testTarget(
            name: "DeepgramDependencyTests", 
            dependencies: ["DeepgramDependency"]
        ),
        .testTarget(
            name: "Deepgram_AHCTests",
            dependencies: ["Deepgram_AHC"],
            resources: [.copy("Resources")]
        ),
    ]
)
