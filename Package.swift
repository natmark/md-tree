// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "md-tree",
    dependencies: [
        .Package(url: "https://github.com/natmark/OptionKit.git",
            majorVersion: 3),
    ]
)
