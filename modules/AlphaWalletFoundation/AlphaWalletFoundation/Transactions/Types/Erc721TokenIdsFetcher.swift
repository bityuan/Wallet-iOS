// Copyright © 2021 Stormbird PTE. LTD.

import Foundation
import Combine

@available(iOS 13.0, *)
public protocol Erc721TokenIdsFetcher: AnyObject {
    func tokenIdsForErc721Token(contract: AlphaWallet.Address, forServer: RPCServer, inAccount account: AlphaWallet.Address) -> AnyPublisher<[String], Never>
}
