// Copyright © 2023 Stormbird PTE. LTD.

import Combine
import AlphaWalletCore

public protocol BlockchainsProvider {
    @available(iOS 13.0, *)
    var blockchains: AnyPublisher<ServerDictionary<BlockchainCallable>, Never> { get }

    func blockchain(with server: RPCServer) -> BlockchainCallable?

}
