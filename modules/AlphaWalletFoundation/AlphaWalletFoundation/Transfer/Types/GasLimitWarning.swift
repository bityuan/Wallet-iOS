//
//  GasLimitWarning.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 10.05.2022.
//

import Foundation

@available(iOS 13.0, *)
extension TransactionConfigurator {
    public enum GasLimitWarning {
        case tooHighCustomGasLimit
    }
}

