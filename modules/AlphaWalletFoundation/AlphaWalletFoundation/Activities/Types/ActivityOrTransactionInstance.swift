//
//  ActivityOrTransactionInstance.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 18.02.2022.
//

import Foundation

@available(iOS 13.0, *)
public enum ActivityOrTransactionInstance {
    case activity(Activity)
    case transaction(Transaction)

    public var blockNumber: Int {
        switch self {
        case .activity(let activity):
            return activity.blockNumber
        case .transaction(let transaction):
            return transaction.blockNumber
        }
    }

    public var transaction: Transaction? {
        switch self {
        case .activity:
            return nil
        case .transaction(let transaction):
            return transaction
        }
    }
    public var activity: Activity? {
        switch self {
        case .activity(let activity):
            return activity
        case .transaction:
            return nil
        }
    }
}
