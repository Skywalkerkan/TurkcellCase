//
//  NetworkReachability.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import Foundation
import Network

final class NetworkReachability {
    
    static let shared = NetworkReachability()
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkReachabilityQueue")
    private(set) var isConnected: Bool = false
    
    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
    
    func isConnectedToNetwork() -> Bool {
        return isConnected
    }
}
