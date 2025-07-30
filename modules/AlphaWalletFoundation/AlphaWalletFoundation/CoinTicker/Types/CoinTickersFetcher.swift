// Copyright © 2023 Stormbird PTE. LTD.

import Foundation
import Combine

@available(iOS 13.0.0, *)
public protocol CoinTickersFetcher {
    func fetchTickers(for tokens: [TokenMappedToTicker], force: Bool, currency: Currency)
    func resolveTickerIds(for tokens: [TokenMappedToTicker])
    func fetchChartHistories(for token: TokenMappedToTicker, force: Bool, periods: [ChartHistoryPeriod], currency: Currency) async -> [ChartHistoryPeriod: ChartHistory]
    func cancel()
}
