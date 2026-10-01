// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PasswordManager",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PasswordManager", targets: ["PasswordManager"])
    ],
    targets: [
        .executableTarget(
            name: "PasswordManager",
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
