// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LocationTracker",
    platforms: [
        .iOS(.v15), .macOS(.v13)
    ],
    products: [
        .library(
            name: "LocationTracker",
            targets: ["LocationTracker"]),
    ],
    targets: [
        .target(
            name: "LocationTracker"),
        .testTarget(
            name: "LocationTrackerTests",
            dependencies: ["LocationTracker"]),
    ]
)
