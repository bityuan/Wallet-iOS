// Copyright © 2023 Stormbird PTE. LTD.

import Combine
import Foundation
import AlphaWalletAddress

fileprivate typealias AttestationsStorage = [AlphaWallet.Address: [Attestation]]

public class AttestationsStore {
    static private let filename: String = "attestations.json"
    static private var fileUrl: URL = {
        let documentsDirectory = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        return documentsDirectory.appendingPathComponent(filename)
    }()

    @Published public var attestations: [Attestation]
    private let wallet: AlphaWallet.Address

    public init(wallet: AlphaWallet.Address) {
        self.wallet = wallet
        self.attestations = functional.readAttestations(forWallet: wallet, from: Self.fileUrl)
    }

    public static func allAttestations() -> [Attestation] {
        return functional.readAttestations(from: fileUrl).flatMap { $0.value }
    }

    public func addAttestation(_ attestation: Attestation, forWallet address: AlphaWallet.Address) -> Bool {
        var allAttestations = functional.readAttestations(from: Self.fileUrl)
        do {
            var attestationsForWallet: [Attestation] = allAttestations[address] ?? []
            guard !attestations.contains(attestation) else {
                infoLog("[Attestation] Attestation already exist. Skipping")
                return false
            }
            attestationsForWallet.append(attestation)
            allAttestations[address] = attestationsForWallet
            try saveAttestations(attestations: allAttestations)
            attestations = attestationsForWallet
            infoLog("[Attestation] Imported attestation")
            return true
        } catch {
            errorLog("[Attestation] failed to encode attestations while adding attestation to: \(Self.fileUrl.absoluteString) error: \(error)")
            return false
        }
    }

    public func removeAttestation(_ attestation: Attestation, forWallet address: AlphaWallet.Address) {
        var allAttestations = functional.readAttestations(from: Self.fileUrl)
        do {
            var attestationsForWallet: [Attestation] = allAttestations[address] ?? []
            attestationsForWallet = attestationsForWallet.filter { $0 != attestation }
            allAttestations[address] = attestationsForWallet

            try saveAttestations(attestations: allAttestations)
            attestations = attestationsForWallet
        } catch {
            errorLog("[Attestation] failed to encode attestations while removing attestation to: \(Self.fileUrl.absoluteString) error: \(error)")
        }
    }

    private func saveAttestations(attestations: AttestationsStorage) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(attestations)
        try data.write(to: Self.fileUrl)
    }

    enum functional {}
}

fileprivate extension AttestationsStore.functional {
    static func readAttestations(from fileUrl: URL) -> AttestationsStorage {
        do {
            let data = try Data(contentsOf: fileUrl)
            let decoder = JSONDecoder()
            let allAttestations = try decoder.decode(AttestationsStorage.self, from: data)
            return allAttestations
        } catch {
            return AttestationsStorage()
        }
    }

    static func readAttestations(forWallet address: AlphaWallet.Address, from fileUrl: URL) -> [Attestation] {
        let allAttestations = readAttestations(from: fileUrl)
        let result: [Attestation] = allAttestations[address] ?? []
        return result
    }
}
