// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "SwiftArgs",
  platforms: [
    .macOS(.v10_14),
  ],
  products: [
    .library(name: "SwiftArgs", targets: ["SwiftArgs"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "SwiftArgs", dependencies: []),
    .testTarget(
       name: "Tests",
       dependencies: ["SwiftArgs"]),
  ]
)
