// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ResearchBoard",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ResearchBoard", targets: ["ResearchBoard"])
    ],
    targets: [
        .executableTarget(
            name: "ResearchBoard",
            path: "ResearchBoard",
            exclude: ["Resources/Info.plist"]
        )
    ]
)
