//
//  NetworkMonitor.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import Network
import SwiftUI

/// 실시간 Wi-Fi 및 셀룰러 네트워크 연결 상태 감지기
public final class NetworkMonitor: ObservableObject, @unchecked Sendable {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.mykku.networkMonitor")
    
    @Published public var isConnected: Bool = true
    @Published public var isChecking: Bool = false
    
    public init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isSatisfied = (path.status == .satisfied)
            Task { @MainActor [weak self] in
                self?.isConnected = isSatisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    /// 수동 연결 상태 점검 (사용자가 재시도 버튼을 탭했을 때)
    @MainActor
    public func manualCheck() async {
        guard !isChecking else { return }
        isChecking = true
        
        try? await Task.sleep(for: .seconds(1))
        
        let status = (monitor.currentPath.status == .satisfied)
        self.isConnected = status
        self.isChecking = false
    }
    
    deinit {
        monitor.cancel()
    }
}
