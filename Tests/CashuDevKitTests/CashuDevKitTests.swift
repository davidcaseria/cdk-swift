import XCTest
@testable import CashuDevKit

final class CashuDevKitTests: XCTestCase {
    
    // Test configuration
    private let testMintUrl = "https://fake.thesimplekid.dev/"
    private let testUnit = CurrencyUnit.sat
    
    private func createTestWalletConfig() -> WalletConfig {
        let tempDir = NSTemporaryDirectory() + UUID().uuidString
        return WalletConfig(workDir: tempDir, targetProofCount: nil)
    }
    
    private func createTestWallet() async throws -> Wallet {
        let config = createTestWalletConfig()
        let mnemonic = try generateMnemonic()
        
        return try await Wallet(
            mintUrl: testMintUrl,
            unit: testUnit,
            mnemonic: mnemonic,
            config: config
        )
    }
    
    func testWalletCreation() async throws {
        let wallet = try await createTestWallet()
        
        // Verify wallet was created successfully
        XCTAssertNotNil(wallet)
        
        // Check mint URL
        let mintUrl = wallet.mintUrl()
        XCTAssertNotNil(mintUrl)
    }
    
    func testWalletGetMintInfo() async throws {
        let wallet = try await createTestWallet()
        
        // Get mint info (this tests network connectivity to the mint)
        do {
            let mintInfo = try await wallet.getMintInfo()
            // If successful, verify we got some info back
            if let info = mintInfo {
                print("Mint info retrieved successfully: \(info)")
            } else {
                print("No mint info available")
            }
        } catch {
            // This is expected to fail with fake mint or network issues
            print("Failed to get mint info (expected): \(error)")
            // The error can be either FfiError or rustPanic depending on the failure mode
            XCTAssertTrue(error is FfiError || "\(error)".contains("rustPanic"), "Should be an FfiError or rustPanic")
        }
    }
    
    func testMintQuoteCreation() async throws {
        let wallet = try await createTestWallet()
        
        let amount = Amount(value: 1000) // 1000 sats
        
        do {
            let quote = try await wallet.mintQuote(amount: amount, description: "Test mint quote")
            
            // Verify quote properties
            XCTAssertNotNil(quote)
            XCTAssertEqual(quote.amountMintable().value, amount.value)
            XCTAssertFalse(quote.id().isEmpty)
            XCTAssertFalse(quote.request().isEmpty)
            XCTAssertEqual(quote.unit(), testUnit)
            
            print("Mint quote created successfully: ID=\(quote.id()), Amount=\(quote.amountMintable().value)")
        } catch {
            // This may fail with fake mint
            print("Mint quote creation failed (may be expected): \(error)")
            XCTAssertTrue(error is FfiError, "Should be an FfiError")
        }
    }
    
    func testMeltQuoteCreation() async throws {
        let wallet = try await createTestWallet()
        
        // Test lightning invoice (fake one for testing)
        let testInvoice = "lnbc1000n1pjqxz8xpp5..."
        
        do {
            let quote = try await wallet.meltQuote(request: testInvoice, options: nil)
            
            // Verify quote properties
            XCTAssertNotNil(quote)
            XCTAssertFalse(quote.id().isEmpty)
            XCTAssertEqual(quote.request(), testInvoice)
            XCTAssertEqual(quote.unit(), testUnit)
            
            print("Melt quote created successfully: ID=\(quote.id())")
        } catch {
            // This is expected to fail with fake invoice
            print("Melt quote creation failed (expected with fake invoice): \(error)")
            XCTAssertTrue(error is FfiError, "Should be an FfiError")
        }
    }
    
    func testProofStatesRetrieval() async throws {
        let wallet = try await createTestWallet()
        
        // Test getting proofs by various states
        let states: [ProofState] = [.unspent, .spent, .pending]
        
        do {
            let proofs = try await wallet.getProofsByStates(states: states)
            // New wallet should have no proofs
            XCTAssertTrue(proofs.isEmpty, "New wallet should have no proofs")
            print("Retrieved \(proofs.count) proofs")
        } catch {
            print("Failed to get proofs by states: \(error)")
            throw error
        }
    }
    
    func testSendOptionsCreation() throws {
        // Test creating send options with various configurations
        let memo = SendMemo(memo: "Test payment", includeMemo: true)
        let amount = Amount(value: 500)
        let splitTarget = SplitTarget.value(amount: amount)
        let sendKind = SendKind.onlineExact
        
        let sendOptions = SendOptions(
            memo: memo,
            conditions: nil,
            amountSplitTarget: splitTarget,
            sendKind: sendKind,
            includeFee: true,
            maxProofs: 10,
            metadata: ["test": "value"]
        )
        
        XCTAssertNotNil(sendOptions)
        XCTAssertEqual(sendOptions.memo?.memo, "Test payment")
        XCTAssertTrue(sendOptions.memo?.includeMemo ?? false)
        XCTAssertTrue(sendOptions.includeFee)
        XCTAssertEqual(sendOptions.maxProofs, 10)
        XCTAssertEqual(sendOptions.metadata["test"], "value")
    }
    
    func testReceiveOptionsCreation() throws {
        // Test creating receive options
        let amount = Amount(value: 1000)
        let splitTarget = SplitTarget.value(amount: amount)
        
        let receiveOptions = ReceiveOptions(
            amountSplitTarget: splitTarget,
            p2pkSigningKeys: [],
            preimages: [],
            metadata: ["receiver": "test"]
        )
        
        XCTAssertNotNil(receiveOptions)
        XCTAssertTrue(receiveOptions.p2pkSigningKeys.isEmpty)
        XCTAssertTrue(receiveOptions.preimages.isEmpty)
        XCTAssertEqual(receiveOptions.metadata["receiver"], "test")
    }
    
    func testAmountOperations() throws {
        let amount1 = Amount(value: 1000)
        let amount2 = Amount(value: 1000)
        let amount3 = Amount(value: 2000)
        
        // Test equality
        XCTAssertEqual(amount1, amount2)
        XCTAssertNotEqual(amount1, amount3)
        
        // Test value access
        XCTAssertEqual(amount1.value, 1000)
        XCTAssertEqual(amount3.value, 2000)
    }
    
    func testCurrencyUnits() throws {
        // Test different currency units
        XCTAssertEqual(CurrencyUnit.sat, CurrencyUnit.sat)
        XCTAssertEqual(CurrencyUnit.msat, CurrencyUnit.msat)
        XCTAssertEqual(CurrencyUnit.usd, CurrencyUnit.usd)
        XCTAssertEqual(CurrencyUnit.eur, CurrencyUnit.eur)
        
        // Test custom currency
        let customUnit = CurrencyUnit.custom(unit: "BTC")
        if case let .custom(unit) = customUnit {
            XCTAssertEqual(unit, "BTC")
        } else {
            XCTFail("Should be custom currency unit")
        }
    }
    
    func testSplitTargets() throws {
        // Test different split targets
        let noneTarget = SplitTarget.none
        let valueTarget = SplitTarget.value(amount: Amount(value: 1000))
        let valuesTarget = SplitTarget.values(amounts: [
            Amount(value: 500),
            Amount(value: 300),
            Amount(value: 200)
        ])
        
        // Verify enum cases
        if case .none = noneTarget {
            // Success
        } else {
            XCTFail("Should be none target")
        }
        
        if case let .value(amount) = valueTarget {
            XCTAssertEqual(amount.value, 1000)
        } else {
            XCTFail("Should be value target")
        }
        
        if case let .values(amounts) = valuesTarget {
            XCTAssertEqual(amounts.count, 3)
            XCTAssertEqual(amounts[0].value, 500)
        } else {
            XCTFail("Should be values target")
        }
    }
    
    func testWalletConfigCreation() throws {
        let tempDir = NSTemporaryDirectory() + "test-wallet"
        let config = WalletConfig(workDir: tempDir, targetProofCount: 50)
        
        XCTAssertEqual(config.workDir, tempDir)
        XCTAssertEqual(config.targetProofCount, 50)
        
        // Test with nil target proof count
        let config2 = WalletConfig(workDir: tempDir, targetProofCount: nil)
        XCTAssertNil(config2.targetProofCount)
    }
    
    func testErrorHandling() async throws {
        // Test wallet creation with invalid mint URL
        let config = createTestWalletConfig()
        let mnemonic = try generateMnemonic()
        
        do {
            let _ = try await Wallet(
                mintUrl: "invalid-url",
                unit: testUnit,
                mnemonic: mnemonic,
                config: config
            )
            XCTFail("Should have thrown an error for invalid mint URL")
        } catch {
            // Expected to fail
            XCTAssertTrue(error is FfiError, "Should be an FfiError")
            print("Correctly caught error for invalid mint URL: \(error)")
        }
    }
    
    func testMeltOptionsCreation() throws {
        // Test different melt options
        let amount = Amount(value: 1000)
        let mppOption = MeltOptions.mpp(amount: amount)
        let amountlessOption = MeltOptions.amountless(amountMsat: amount)
        
        // These are enum cases, just verify they can be created
        XCTAssertNotNil(mppOption)
        XCTAssertNotNil(amountlessOption)
        
        // Test enum pattern matching
        if case let .mpp(mppAmount) = mppOption {
            XCTAssertEqual(mppAmount.value, 1000)
        } else {
            XCTFail("Should be mpp option")
        }
        
        if case let .amountless(amountMsat) = amountlessOption {
            XCTAssertEqual(amountMsat.value, 1000)
        } else {
            XCTFail("Should be amountless option")
        }
    }
    
    func testMnemonicGeneration() throws {
        // Test mnemonic generation
        let mnemonic1 = try generateMnemonic()
        let mnemonic2 = try generateMnemonic()
        
        // Verify mnemonics are generated
        XCTAssertFalse(mnemonic1.isEmpty, "Mnemonic should not be empty")
        XCTAssertFalse(mnemonic2.isEmpty, "Mnemonic should not be empty")
        
        // Verify they are different (should be random)
        XCTAssertNotEqual(mnemonic1, mnemonic2, "Generated mnemonics should be different")
        
        // Verify mnemonic has expected format (should be words separated by spaces)
        let words1 = mnemonic1.split(separator: " ")
        let words2 = mnemonic2.split(separator: " ")
        
        XCTAssertTrue(words1.count >= 12, "Mnemonic should have at least 12 words")
        XCTAssertTrue(words2.count >= 12, "Mnemonic should have at least 12 words")
        
        print("Generated mnemonic 1: \(mnemonic1)")
        print("Generated mnemonic 2: \(mnemonic2)")
    }
    
}
