//
//  ConcurrencyDemoView.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI
import UIKit

struct ConcurrencyDemoView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @Environment(\.scenePhase) private var scenePhase
    @State private var concurrentRequestCount = 10
    @State private var actualServerRefreshCount = 0
    @State private var completedRequests = 0
    @State private var isRunning = false
    @State private var logs: [String] = []
    @State private var permissionStatuses: [PermissionType: Bool] = [:]
    
    private let permissionManager = PermissionManager()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // 1. TokenRefreshProxy Card
                VStack(alignment: .leading, spacing: 16) {
                    SectionBadgeHeader(
                        badge: "SWIFT ACTOR PROXY",
                        title: "TokenRefreshProxy 동시 401 직렬화"
                    )
                    
                    Text("복합 화면 진입 시 10개의 API 요청이 동시에 401 Unauthorized를 수신하더라도, Actor 내부의 진행 중인 Task(ongoingRefreshTask)를 공유하여 서버 재발급 API는 단 1회만 호출됩니다.")
                        .font(.pretendard(of: .regular, size: 13))
                        .foregroundStyle(Color.gray700)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 10) {
                        metricBox(label: "동시 401 요청", value: "\(concurrentRequestCount)개", bg: .gray100)
                        metricBox(label: "실제 서버 갱신 호출", value: "\(actualServerRefreshCount)회", bg: .green200)
                        metricBox(label: "복구된 요청", value: "\(completedRequests)/\(concurrentRequestCount)", bg: .blue100)
                    }
                    
                    Button {
                        runConcurrent401Simulation()
                    } label: {
                        Text(isRunning ? "동시 401 요청 직렬화 실행 중..." : "동시 10개 401 요청 시뮬레이션 실행")
                            .font(.pretendard(of: .bold, size: 14))
                            .foregroundStyle(Color.blackApp)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(isRunning ? Color.gray200 : Color.green400)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isRunning)
                    
                    if !logs.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(logs, id: \.self) { log in
                                Text(log)
                                    .font(.pretendard(of: .medium, size: 12))
                                    .foregroundStyle(Color.blackApp)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray50)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.whiteApp)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray200, lineWidth: 1))
                )
                
                // 2. NetworkGuardModifier Card
                VStack(alignment: .leading, spacing: 14) {
                    SectionBadgeHeader(
                        badge: "OFFLINE GUARD",
                        title: "NetworkGuardModifier 실시간 단절 복구"
                    )
                    
                    Text("NWPathMonitor를 통해 네트워크 단절이 감지되면 진행 중인 화면 인터랙션을 보호하고, 재연결 시 스프링 애니메이션으로 직전 작업 화면으로 복귀합니다.")
                        .font(.pretendard(of: .regular, size: 13))
                        .foregroundStyle(Color.gray700)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button {
                        Task {
                            networkMonitor.isConnected = false
                            try? await Task.sleep(for: .seconds(2.5))
                            networkMonitor.isConnected = true
                        }
                    } label: {
                        Text("오프라인 가드 화면 시뮬레이션")
                            .font(.pretendard(of: .bold, size: 14))
                            .foregroundStyle(Color.whiteApp)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.blackApp)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.whiteApp)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray200, lineWidth: 1))
                )
                
                // 3. PermissionManager Card
                VStack(alignment: .leading, spacing: 14) {
                    SectionBadgeHeader(
                        badge: "ASYNC PERMISSION",
                        title: "PermissionManager 비동기 미디어 권한 제어"
                    )
                    
                    Text("AVCaptureDevice(카메라) 및 PHPhotoLibrary(사진첩 .authorized / .limited 부분 허용 판별) 권한 확인·요청 로직을 PermissionManagable 프로토콜과 async/await로 추상화하여 UI 계층과 분리했습니다.")
                        .font(.pretendard(of: .regular, size: 13))
                        .foregroundStyle(Color.gray700)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 10) {
                        ForEach(PermissionType.allCases, id: \.rawValue) { perm in
                            let granted = permissionStatuses[perm] ?? permissionManager.isGranted(for: perm)
                            metricBox(
                                label: perm.rawValue,
                                value: granted ? "허용됨" : "미허용/미요청",
                                bg: granted ? .green100 : .gray100,
                                action: {
                                    handlePermissionTap(for: perm)
                                }
                            )
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.whiteApp)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray200, lineWidth: 1))
                )
            }
            .padding(20)
        }
        .background(Color.gray50)
        .navigationTitle("Concurrency")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshPermissionStatuses()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                refreshPermissionStatuses()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            refreshPermissionStatuses()
        }
    }
    
    private func refreshPermissionStatuses() {
        for perm in PermissionType.allCases {
            permissionStatuses[perm] = permissionManager.isGranted(for: perm)
        }
    }
    
    private func handlePermissionTap(for type: PermissionType) {
        Task {
            let granted = await permissionManager.requestOrOpenSettings(for: type)
            permissionStatuses[type] = granted
        }
    }
    
    private func metricBox(label: String, value: String, bg: Color, action: (() -> Void)? = nil) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.pretendard(of: .medium, size: 11))
                .foregroundStyle(Color.gray700)
                .multilineTextAlignment(.center)
            Text(value)
                .font(.pretendard(of: .extraBold, size: 16))
                .foregroundStyle(Color.blackApp)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            action?()
        }
    }
    
    private func runConcurrent401Simulation() {
        isRunning = true
        actualServerRefreshCount = 0
        completedRequests = 0
        logs.removeAll()
        
        let proxy = TokenRefreshProxy()
        let mockRepo = MockAuthRepository()
        
        Task {
            await proxy.registerHandler {
                try await mockRepo.executeReissueToken()
            }
            
            logs.append("🚀 10개 비동기 API 요청 동시 401 발생")
            
            await withTaskGroup(of: Int.self) { group in
                for index in 1...concurrentRequestCount {
                    group.addTask {
                        try? await proxy.executeRefresh()
                        return index
                    }
                }
                
                for await finishedIndex in group {
                    completedRequests += 1
                    logs.append("✅ Request #\(finishedIndex): 갱신된 토큰 공유받아 재시도 성공")
                }
            }
            
            actualServerRefreshCount = mockRepo.reissueCallCount
            logs.append("🎯 최종 결과: 10개 동시 요청 중 서버 재발급 API는 단 \(actualServerRefreshCount)회만 실행됨")
            isRunning = false
        }
    }
}
