// CashuDevKit - Swift bindings for the Cashu Development Kit
//
// This module provides Swift bindings for the Cashu protocol implementation
// via FFI bindings to the Rust CDK library.

import Foundation

// Re-export the main types from the generated bindings
// This ensures the target is not empty and provides a clean public API

public typealias CashuAmount = Amount
public typealias CashuWallet = Wallet
public typealias CashuToken = Token
public typealias CashuProof = Proof
public typealias CashuMintInfo = MintInfo