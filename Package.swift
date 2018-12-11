// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "todotxt2org",
    dependencies: [
    ],
    targets: [
        .target(
            name: "todotxt2org",
            dependencies: []),
        .testTarget(
            name: "todotxt2orgTests",
            dependencies: ["todotxt2org"]),
    ]
)
