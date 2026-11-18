//
//  DIContainer.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import Foundation

// MARK: - Auth Repository Interface & Implementations (For TokenRefreshProxy Demo)
public protocol AuthRepository: Sendable {
    func executeReissueToken() async throws
}

public final class DefaultAuthRepository: AuthRepository {
    private let networkManager: any NetworkManager
    
    public init(networkManager: any NetworkManager) {
        self.networkManager = networkManager
    }
    
    public func executeReissueToken() async throws {
        // 실제 환경에서는 /api/v1/auth/refresh 엔드포인트 호출 후 LocalStorage 갱신
        try await Task.sleep(for: .milliseconds(300))
        LocalStorage.accessToken = "refreshed_access_token_\(UUID().uuidString.prefix(6))"
    }
}

public final class MockAuthRepository: AuthRepository, @unchecked Sendable {
    public private(set) var reissueCallCount = 0
    
    public init() {}
    
    public func executeReissueToken() async throws {
        reissueCallCount += 1
        // 토큰 갱신 네트워크 지연 시뮬레이션
        try await Task.sleep(for: .milliseconds(600))
        LocalStorage.accessToken = "mock_refreshed_token_\(reissueCallCount)"
    }
}

// MARK: - Dependency Injection Container
/// 앱 전역의 의존성을 조립하고 환경을 격리(`.network` vs `.mock`)하는 DI 컨테이너
/// - 단일 플래그(`Status`) 전환만으로 실제 서버 통신 환경과 인메모리 Mock 테스트/프리뷰 환경을 완벽히 분리
@MainActor
public final class DIContainer: ObservableObject {
    
    public enum Status: String, CaseIterable, Identifiable {
        case mock = "Mock (Offline)"
        case network = "Network (Live)"
        
        public var id: String { rawValue }
    }
    
    @Published public private(set) var status: Status
    
    public init(status: Status = .mock) {
        self.status = status
    }
    
    public func switchEnvironment(to newStatus: Status) {
        self.status = newStatus
    }
    
    // MARK: - Network & Concurrency Infrastructure
    
    public lazy var tokenRefreshProxy: TokenRefreshProxy = makeTokenRefreshProxy()
    
    private func makeTokenRefreshProxy() -> TokenRefreshProxy {
        let proxy = TokenRefreshProxy()
        let repo = self.authRepository
        
        // DIP: 인터셉터가 AuthRepository를 직접 소유하지 않고 클로저를 통해 순환 참조 해소
        Task.detached {
            await proxy.registerHandler {
                try await repo.executeReissueToken()
            }
        }
        return proxy
    }
    
    public lazy var authInterceptor: AuthInterceptor = {
        AuthInterceptor(refreshProxy: tokenRefreshProxy)
    }()
    
    public lazy var networkManager: any NetworkManager = {
        switch status {
        case .network:
            return DefaultNetworkManager(interceptor: authInterceptor)
        case .mock:
            return MockNetworkManager()
        }
    }()
    
    // MARK: - Repositories
    
    public lazy var authRepository: any AuthRepository = {
        switch status {
        case .network:
            return DefaultAuthRepository(networkManager: networkManager)
        case .mock:
            return MockAuthRepository()
        }
    }()
    
    public var reportRepository: any ReportRepository {
        switch status {
        case .network:
            return DefaultReportRepository(networkManager: networkManager)
        case .mock:
            return MockReportRepository()
        }
    }
    
    // MARK: - UseCases
    
    public var reportUseCase: any ReportUseCase {
        DefaultReportUseCase(repository: reportRepository)
    }
    
    // MARK: - Store Factories (MVI)
    
    public func makeReportStore() -> ReportStore {
        ReportStore(useCase: reportUseCase)
    }
    
    public func makeCommunityCommentStore() -> CommunityCommentStore {
        CommunityCommentStore()
    }
    
    public func makeStoreContainer() -> StoreContainer {
        StoreContainer(diContainer: self)
    }
}
