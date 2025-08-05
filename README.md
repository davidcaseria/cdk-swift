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

## Basic Usage

### Import the Library

```swift
import CashuDevKit
```

### Generate a Mnemonic

```swift
let mnemonic = try generateMnemonic()
print("Generated mnemonic: \(mnemonic)")
// Output: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
```

### Create a Wallet

```swift
// Configure wallet
let config = WalletConfig(
    workDir: "/path/to/wallet/data",
    targetProofCount: nil
)

// Create wallet with generated mnemonic
let wallet = try await Wallet(
    mintUrl: "https://mint.example.com/",
    unit: CurrencyUnit.sat,
    mnemonic: mnemonic,
    config: config
)
```

### Get Mint Information

```swift
let mintInfo = try await wallet.getMintInfo()
if let info = mintInfo {
    print("Mint name: \(info.name ?? "Unknown")")
    print("Supported units: \(info.nuts)")
}
```

### Create a Mint Quote

```swift
let amount = Amount(value: 1000) // 1000 sats
let quote = try await wallet.mintQuote(
    amount: amount, 
    description: "My payment"
)

print("Quote ID: \(quote.id())")
print("Payment request: \(quote.request())")
print("Amount: \(quote.amountMintable().value)")
```

### Mint Tokens

```swift
let proofs = try await wallet.mint(
    quoteId: quote.id(),
    amountSplitTarget: SplitTarget.none,
    spendingConditions: nil
)

print("Minted \(proofs.count) proofs")
```

### Create a Melt Quote (for Lightning payments)

```swift
let invoice = "lnbc1000n1..." // Lightning invoice
let meltQuote = try await wallet.meltQuote(
    request: invoice,
    options: nil
)

print("Melt quote ID: \(meltQuote.id())")
print("Fee reserve: \(meltQuote.feeReserve().value)")
```

### Send Tokens

```swift
// Configure send options
let sendOptions = SendOptions(
    memo: SendMemo(memo: "Payment for coffee", includeMemo: true),
    conditions: nil,
    amountSplitTarget: SplitTarget.none,
    sendKind: SendKind.onlineExact,
    includeFee: true,
    maxProofs: nil,
    metadata: [:]
)

// Prepare the send
let preparedSend = try await wallet.prepareSend(
    amount: Amount(value: 500),
    options: sendOptions
)

// Get the token to share
let token = try await preparedSend.confirm(memo: "Coffee payment")
print("Token to send: \(token)")
```

### Receive Tokens

```swift
// Configure receive options
let receiveOptions = ReceiveOptions(
    amountSplitTarget: SplitTarget.none,
    p2pkSigningKeys: [],
    preimages: [],
    metadata: [:]
)

// Receive the token
let receivedAmount = try await wallet.receive(
    token: token,
    options: receiveOptions
)

print("Received: \(receivedAmount.value) sats")
```

### Check Proof States

```swift
let states: [ProofState] = [.unspent, .spent, .pending]
let proofs = try await wallet.getProofsByStates(states: states)
print("Found \(proofs.count) proofs")
```

### Error Handling

```swift
do {
    let wallet = try await Wallet(
        mintUrl: "invalid-url",
        unit: CurrencyUnit.sat,
        mnemonic: mnemonic,
        config: config
    )
} catch let error as FfiError {
    switch error {
    case .generic(let message):
        print("CDK Error: \(message)")
    }
} catch {
    print("Unexpected error: \(error)")
}
```

### Working with Different Currency Units

```swift
// Satoshis (most common)
let satWallet = try await Wallet(
    mintUrl: "https://mint.example.com/",
    unit: CurrencyUnit.sat,
    mnemonic: mnemonic,
    config: config
)

// Millisatoshis
let msatWallet = try await Wallet(
    mintUrl: "https://mint.example.com/",
    unit: CurrencyUnit.msat,
    mnemonic: mnemonic,
    config: config
)

// Custom currency
let customWallet = try await Wallet(
    mintUrl: "https://mint.example.com/",
    unit: CurrencyUnit.custom(unit: "USD"),
    mnemonic: mnemonic,
    config: config
)
```

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