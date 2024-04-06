// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDeepgram",
    platforms: [
            .macOS(.v14),
            .iOS(.v17),
            .watchOS(.v6),
            .tvOS(.v13)
        ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftDeepgram",
            targets: ["SwiftDeepgram"]),
        .library(name: "DeepgramURLSessionClient", targets: ["DeepgramURLSessionClient"]),
        .library(name: "DeepgramModels", targets: ["DeepgramModels"]),
        .library(name: "DeepgramDependency", targets: ["DeepgramDependency"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.2.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftDeepgram"),
        .target(name: "DeepgramModels"),
        .target(name: "DeepgramDependency", 
                dependencies: [
                    "DeepgramModels",
                    .product(name: "Dependencies", package: "swift-dependencies"),
                ]),
        .target(name: "DeepgramURLSessionClient",
                dependencies: [
                    .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                    .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                ],
                plugins: [.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")]
                
               ),
        .testTarget(
            name: "SwiftDeepgramTests",
            dependencies: ["SwiftDeepgram"]),
        .testTarget(name: "DeepgramURLSessionClientTests", dependencies: ["DeepgramURLSessionClient"]),
        .testTarget(name: "DeepgramDependencyTests", dependencies: ["DeepgramDependency"]),
    ]
)
