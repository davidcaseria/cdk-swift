# CDK Swift

Swift language bindings for the [Cashu Development Kit (CDK)](https://github.com/cashubtc/cdk).

## Overview

`cdk-swift` provides Swift/iOS bindings for CDK, enabling developers to integrate Cashu ecash functionality into their iOS and macOS applications.

## Supported Platforms

- macOS (x86_64 and Apple Silicon)
- iOS (iPhone - aarch64)
- iOS Simulator (x86_64 and Apple Silicon)

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/cdk-swift.git", from: "0.1.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version you want to use

## Building from Source

1. Clone this repository
2. Ensure you have Rust installed with the required targets
3. Run the build script:

```bash
./build-xcframework.sh
```

This will:
- Generate Swift bindings from the CDK FFI crate
- Build Rust libraries for all supported platforms
- Create a universal XCFramework
- Run tests (if `--test` flag is provided)

## Usage

```swift
import CashuDevKit

// Create a wallet
let wallet = try Wallet(mintUrl: "https://mint.example.com")

// Generate a mint quote
let mintQuote = try await wallet.createMintQuote(amount: Amount(value: 1000))

// Create a melt quote
let meltQuote = try await wallet.createMeltQuote(request: "lnbc...")

// Send tokens
let sendOptions = SendOptions()
let token = try await wallet.send(amount: Amount(value: 500), options: sendOptions)

// Receive tokens
let receiveOptions = ReceiveOptions()
try await wallet.receive(token: token, options: receiveOptions)
```

## Requirements

- Swift 5.5+
- iOS 15.0+ / macOS 12.0+
- Xcode 13.0+

## Development

### Prerequisites

- Rust (with `rustup`)
- Xcode and Xcode Command Line Tools
- Swift Package Manager

### Building

The build process requires the CDK FFI crate to be available at `../cdk/crates/cdk-ffi`. Make sure you have cloned the CDK repository alongside this one.

### Testing

Run tests with:

```bash
swift test
```

Or run the build script with tests:

```bash
./build-xcframework.sh --test
```

## License

This project is licensed under the same license as the CDK project.