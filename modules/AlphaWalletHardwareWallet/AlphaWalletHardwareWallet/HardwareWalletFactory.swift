// Copyright © 2023 Stormbird PTE. LTD.

import Foundation

@available(iOS 13.0.0, *)
public protocol HardwareWalletFactory {
    func createWallet() -> HardwareWallet
}
