//
//  AuthInterceptor.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 3/17/26.
//

import Foundation

/// 세션 토큰 자동 주입 및 401 만료 복구 인터셉터
/// - Moya / Alamofire RequestInterceptor 패턴을 네이티브 Swift Concurrency와 조화롭게 융합
/// - TokenRefreshProxy를 활용해 401 에러 시 안전하게 토큰을 갱신하고 단 1회 재시도(Retry)
public final class AuthInterceptor: @unchecked Sendable {
    
    private let refreshProxy: TokenRefreshProxy
    
    public init(refreshProxy: TokenRefreshProxy) {
        self.refreshProxy = refreshProxy
    }
    
    /// 발송되는 모든 요청의 헤더에 Bearer 토큰 주입 (Adapt)
    public func adapt(_ urlRequest: URLRequest) -> URLRequest {
        var request = urlRequest
        if let accessToken = LocalStorage.accessToken, !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    /// 401 수신 시 TokenRefreshProxy를 통해 세션 갱신 시도 후 재시도 가능 여부 반환 (Retry)
    public func retry(request: URLRequest, statusCode: Int) async -> Bool {
        guard statusCode == 401 else { return false }
        
        // 토큰 갱신 API 자체에서 401이 발생한 경우 무한 루프 방지 및 강제 로그아웃
        if let path = request.url?.path, path.contains("/refresh") {
            postLogoutNotification()
            return false
        }
        
        do {
            try await refreshProxy.executeRefresh()
            return true
        } catch {
            postLogoutNotification()
            return false
        }
    }
    
    private func postLogoutNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .logoutNotification, object: nil)
        }
    }
}
