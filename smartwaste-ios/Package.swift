// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "smartwaste-ios",
    defaultLocalization: "en",
    platforms: [
      .iOS(.v16)
    ],
    products: [
      .library(name: "AuthFeature", targets: ["AuthFeature"]),
      .library(name: "Shared", targets: ["Shared"]),
      .library(name: "Styleguide", targets: ["Styleguide"])
    ],
    dependencies: [
      .package(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", from: "2.1.1"),
      .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.8.0"),
      .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
      .package(url: "https://github.com/CSolanaM/SkeletonUI", from: "2.0.0"),
      .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "20.0.0"),
      .package(url: "https://github.com/elai950/AlertToast.git", from: "1.3.9"),
      .package(url: "https://github.com/Alecrim/Reachability", from: "1.2.1"),
      .package(url: "https://github.com/johnpatrickmorgan/TCACoordinators", from: "0.6.1"),
      .package(url: "https://github.com/DanielMandea/swiftui-loading-view", from: "1.1.7"),
      
    ],
    targets: [
        .target(
          name: "AuthFeature",
          dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            .product(name: "Alamofire", package: "Alamofire"),
            .product(name: "AlertToast", package: "AlertToast"),
            .product(name: "Reachability", package: "Reachability"),
            "Shared",
          ]
        ),
        .target(
          name: "Shared",
          dependencies: []
        ),
        .target(
          name: "Styleguide",
          dependencies: []
        )
    ]
)
