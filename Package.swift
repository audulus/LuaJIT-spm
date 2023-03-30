// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LuaJIT",
    platforms: [
        .macOS(.v11), .iOS(.v13)
    ],
    products: [
        .library(
            name: "LuaJIT",
            targets: ["LuaJIT_framework"])
    ],
    targets: [
        .binaryTarget(
            name: "LuaJIT_framework",
            path: "luajit.xcframework"
        )
    ]
)
