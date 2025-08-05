# CDK Swift

Swift language bindings for the [Cashu Development Kit (CDK)](https://github.com/cashubtc/cdk).

## Overview

`cdk-swift` provides Swift/iOS bindings for CDK, enabling developers to integrate Cashu ecash functionality into their iOS and macOS applications.

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/cashubtc/cdk-swift.git", from: "0.1.0")
]
```

Then add it to your target dependencies:

```swift
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "CashuDevKit", package: "cdk-swift")
        ]
    )
]
```

### Xcode Integration

1. Open your Xcode project
2. Go to **File → Add Package Dependencies**
3. Enter the repository URL: `https://github.com/cashubtc/cdk-swift.git`
4. Select the version you want to use
5. Add `CashuDevKit` to your target

## Supported Platforms

- **macOS**: 12.0+ (Intel and Apple Silicon)
- **iOS**: 15.0+ (Device and Simulator)
- **Swift**: 5.5+

## Building from Source

### Prerequisites

- [Rust](https://rustup.rs/) with cargo
- Xcode and Xcode Command Line Tools
- [Just](https://github.com/casey/just) task runner (optional but recommended)

### Setup

1. Clone the CDK repository:
   ```bash
   git clone https://github.com/cashubtc/cdk.git
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/cashubtc/cdk-swift.git
   cd cdk-swift
   ```

3. Generate Swift bindings:
   ```bash
   just generate
   # or
   ./generate-bindings.sh
   ```

### Available Commands

```bash
# Generate Swift bindings from CDK FFI
just generate

# Build XCFramework for all platforms
just build

# Build for native platform only (faster for development)
just build-native  

# Run all tests
just test

# Clean all build artifacts
just clean

# Check prerequisites
just check-tools
just check-cdk

# Show project information
just info
```

### Environment Variables

- `CDK_DIR`: Path to the CDK repository (default: `../cdk`)

## Project Structure

```
cdk-swift/
├── Sources/
│   ├── CashuDevKit/           # Swift bindings
│   │   └── CashuDevKit.swift  # Generated Swift code
│   └── CashuDevKitFFI/        # FFI bridge
│       ├── CashuDevKitFFI.h   # C header
│       └── module.modulemap   # Module map
├── Tests/                     # Swift tests
├── Package.swift              # Swift Package Manager
├── generate-bindings.sh       # Bindings generation script
└── justfile                   # Build tasks
```

## Development Workflow

1. **Generate bindings** after CDK changes:
   ```bash
   just generate
   ```

2. **Build and test** your changes:
   ```bash
   just build-native
   just test
   ```

3. **For full cross-platform build**:
   ```bash
   just build
   ```

## License

This project is licensed under the same license as the CDK project.