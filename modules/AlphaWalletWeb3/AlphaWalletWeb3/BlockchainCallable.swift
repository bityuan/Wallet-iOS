// Copyright © 2023 Stormbird PTE. LTD.

import Combine

public protocol BlockchainCallable {
    @available(iOS 13.0, *)
    func call<R: ContractMethodCall>(_ method: R, block: BlockParameter) -> AnyPublisher<R.Response, SessionTaskError>
    @available(iOS 13.0.0, *)
    func callAsync<R: ContractMethodCall>(_ method: R, block: BlockParameter) async throws -> R.Response
}

public extension BlockchainCallable {
    @available(iOS 13.0, *)
    func call<R: ContractMethodCall>(_ method: R, block: BlockParameter = .latest) -> AnyPublisher<R.Response, SessionTaskError> {
        call(method, block: block)
    }

    @available(iOS 13.0.0, *)
    func callAsync<R: ContractMethodCall>(_ method: R, block: BlockParameter = .latest) async throws -> R.Response {
        try await callAsync(method, block: block)
    }
}
