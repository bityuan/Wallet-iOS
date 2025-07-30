//
// Created by James Sangalli on 14/7/18.
// Copyright © 2018 Stormbird PTE. LTD.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class IsErc1155Contract {
    private let blockchainProvider: BlockchainProvider
    private lazy var resolver = IsInterfaceSupported165(blockchainProvider: blockchainProvider)

    private struct ERC165Hash {
        //https://eips.ethereum.org/EIPS/eip-1155
        static let official = "0xd9b67a26"
    }
    public init(blockchainProvider: BlockchainProvider) {
        self.blockchainProvider = blockchainProvider
    }

    public func getIsErc1155Contract(for contract: AlphaWallet.Address) -> AnyPublisher<Bool, SessionTaskError> {
        return resolver.getInterfaceSupported165(hash: ERC165Hash.official, contract: contract)
    }
}
