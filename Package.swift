// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BtcNotificationBot",
    dependencies: [
        .Package(url: "https://github.com/zmeyc/telegram-bot-swift.git", majorVersion: 0)
    ],
    targets: [
        .target(
            name: "BtcNotificationBot",
            dependencies: []),
    ]
)
