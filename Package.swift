// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftyVK",
    products: [
        .library(
            name: "SwiftyVK",
            targets: ["SwiftyVK"]
        ),
        targets: [
        .target(name: "SwiftyVK", dependencies: ["SwiftyVK_Lib"], path: "Library/UI"),
        .target(name: "SwiftyVK_Lib", dependencies: ["SwiftyVK_Res"], path: "Library/Sources"),
        .target(name: "SwiftyVK_Res", dependencies: [], path: "Library/Resources"),
        ]
    ]
)
