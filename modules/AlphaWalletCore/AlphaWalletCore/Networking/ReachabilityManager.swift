//
//  ReachabilityManager.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 31.03.2022.
//

import Alamofire
import Combine
import CombineExt

public protocol ReachabilityManagerProtocol {
    var isReachable: Bool { get }
    @available(iOS 13.0, *)
    var isReachablePublisher: AnyPublisher<Bool, Never> { get }
    @available(iOS 13.0, *)
    var networkBecomeReachablePublisher: AnyPublisher<Void, Never> { get }
}

@available(iOS 13.0, *)
public class ReachabilityManager {
    private let manager: NetworkReachabilityManager?

    public var isReachable: Bool {
        return manager?.isReachable ?? false
    }

    private lazy var reachabilitySubject = CurrentValueSubject<Bool, Never>(isReachable)

    public init() {
        manager = NetworkReachabilityManager()

        manager?.startListening(onUpdatePerforming: { [weak reachabilitySubject] state in
            switch state {
            case .notReachable, .unknown:
                reachabilitySubject?.send(false)
            case .reachable:
                reachabilitySubject?.send(true)
            }
        })
    }
}

@available(iOS 13.0, *)
extension ReachabilityManager: ReachabilityManagerProtocol {
    public var networkBecomeReachablePublisher: AnyPublisher<Void, Never> {
        isReachablePublisher
            .filter { $0 }
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public var isReachablePublisher: AnyPublisher<Bool, Never> {
        reachabilitySubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
