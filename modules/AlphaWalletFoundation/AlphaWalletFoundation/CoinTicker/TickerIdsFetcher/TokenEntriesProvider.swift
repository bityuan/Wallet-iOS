//
//  TokenEntriesProvider.swift
//  AlphaWalletFoundation
//
//  Created by Vladyslav Shepitko on 05.09.2022.
//

import Foundation
import Combine
import AlphaWalletCore

/// Provides tokens groups
@available(iOS 13.0.0, *)
public protocol TokenEntriesProvider {
    func tokenEntries() async throws -> [TokenEntry]
}
