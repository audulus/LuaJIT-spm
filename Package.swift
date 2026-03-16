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
            
            // Build LuaJIT as dynamic to hide the _lj_err_unwind_dwarf symbol
            // so we don't run out of unwind personality functions (only 3 allowed
            // per library).
            type: .dynamic,
            targets: ["luajit", "dummy"])
    ],
    targets: [
        // Just to convince xcode to build the library as dynamic.
        .target(
            name: "dummy",
            dependencies: ["luajit"]),
        .binaryTarget(
            name: "luajit",
            path: "luajit.xcframework"
        )
    ]
)
