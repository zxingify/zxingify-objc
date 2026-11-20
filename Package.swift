// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZXingObjC",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ZXingObjC",
            targets: ["ZXingObjC"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ZXingObjC",
            dependencies: [],
            path: "ZXingObjC",
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("aztec"),
                .headerSearchPath("aztec/decoder"),
                .headerSearchPath("aztec/detector"),
                .headerSearchPath("aztec/encoder"),
                
                .headerSearchPath("client"),
                .headerSearchPath("client/result"),
                
                .headerSearchPath("common"),
                .headerSearchPath("common/detector"),
                .headerSearchPath("common/reedsolomon"),
                
                .headerSearchPath("core"),
                
                .headerSearchPath("datamatrix"),
                .headerSearchPath("datamatrix/decoder"),
                .headerSearchPath("datamatrix/detector"),
                .headerSearchPath("datamatrix/encoder"),
                
                .headerSearchPath("maxicode"),
                .headerSearchPath("maxicode/decoder"),
                
                .headerSearchPath("multi"),
                
                .headerSearchPath("oned"),
                .headerSearchPath("oned/rss"),
                .headerSearchPath("oned/rss/expanded"),
                .headerSearchPath("oned/rss/expanded/decoders"),
                
                .headerSearchPath("pdf417"),
                .headerSearchPath("pdf417/decoder"),
                .headerSearchPath("pdf417/decoder/ec"),
                .headerSearchPath("pdf417/detector"),
                .headerSearchPath("pdf417/encoder"),
                
                .headerSearchPath("qrcode"),
                .headerSearchPath("qrcode/decoder"),
                .headerSearchPath("qrcode/detector"),
                .headerSearchPath("qrcode/encoder"),
                .headerSearchPath("qrcode/multi"),
                .headerSearchPath("qrcode/multi/detector"),
            ]
        )
    ]
)
