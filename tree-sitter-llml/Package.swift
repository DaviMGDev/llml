// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TreeSitterLlml",
    products: [
        .library(name: "TreeSitterLlml", targets: ["TreeSitterLlml"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/SwiftTreeSitter", from: "0.8.0"),
    ],
    targets: [
        .target(
            name: "TreeSitterLlml",
            dependencies: [],
            path: ".",
            sources: [
                "src/parser.c",
                // NOTE: if your language has an external scanner, add it here.
            ],
            resources: [
                .copy("queries")
            ],
            publicHeadersPath: "bindings/swift",
            cSettings: [.headerSearchPath("src")]
        ),
        .testTarget(
            name: "TreeSitterLlmlTests",
            dependencies: [
                "SwiftTreeSitter",
                "TreeSitterLlml",
            ],
            path: "bindings/swift/TreeSitterLlmlTests"
        )
    ],
    cLanguageStandard: .c11
)
