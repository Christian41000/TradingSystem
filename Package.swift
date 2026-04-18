// swiftlint:disable all
// Generated Swift Package Manager manifest for TradingApp
// This is an alternative to Xcode project for building with SPM

import PackageDescription

let package = Package(
    name: "TradingApp",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "TradingApp",
            targets: ["TradingApp"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "TradingApp",
            dependencies: [],
            path: "Frontend/TradingApp",
            exclude: ["Info.plist"],
            sources: [
                "TradingAppApp.swift",
                "ContentView.swift",
                "TradingViewModel.swift",
                "TradingBackend.swift"
            ],
            linkerSettings: [
                .linkedLibrary("TradingBackend", .when(platforms: [.macOS]))
            ]
        )
    ],
    cxxLanguageStandard: .cxx17
)

// Note: To use this package:
// 1. First build the C++ backend: cd Backend && mkdir build && cd build && cmake .. && make
// 2. Copy libTradingBackend.dylib to /usr/local/lib or set DYLD_LIBRARY_PATH
// 3. Run: swift run
