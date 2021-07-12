// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "rswift",
  platforms: [
    .macOS(.v10_11)
  ],
  products: [
    .executable(name: "rswift", targets: ["rswift"])
  ],
  dependencies: [
    .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
    .package(url: "https://github.com/tomlokhorst/XcodeEdit", from: "2.7.0"),
    .package(url: "https://github.com/kareman/FootlessParser", from: "0.5.2")
  ],
  targets: [
    .target(name: "rswift", dependencies: ["RswiftCore"]),
    .target(name: "RswiftCore", dependencies: ["Commander", "XcodeEdit", "FootlessParser"]),
    .testTarget(name: "RswiftCoreTests", dependencies: ["RswiftCore"]),
  ]
)
