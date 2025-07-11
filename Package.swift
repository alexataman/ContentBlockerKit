// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContentBlockerKit",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "ContentBlockerKit",
            targets: ["ContentBlockerKit"]),
    ],
    targets: [
        .target(
            name: "ContentBlockerKit",
            dependencies: [],
            path: "Sources/ContentBlockerKit",
            resources: [
                .process("Resources /HateSpeach.mlpackage"),
                .process("Resources /NSFW.mlpackage"),
                .process("Resources /yolo_small_weights.mlpackage")
            ]),

    ]
)
