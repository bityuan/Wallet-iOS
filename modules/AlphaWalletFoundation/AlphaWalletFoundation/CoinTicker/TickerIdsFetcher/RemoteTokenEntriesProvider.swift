//
//  RemoteTokenEntriesProvider.swift
//  AlphaWalletFoundation
//
//  Created by Vladyslav Shepitko on 05.09.2022.
//

import Foundation
import Combine
import CombineExt
import AlphaWalletCore

//TODO: Future impl for remote TokenEntries provider
@available(iOS 13.0.0, *)
public final class RemoteTokenEntriesProvider: TokenEntriesProvider {
    public func tokenEntries() async throws -> [TokenEntry] {
        return []
    }
}
