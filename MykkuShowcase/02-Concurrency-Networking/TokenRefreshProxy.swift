//
//  TokenRefreshProxy.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 3/17/26.
//

import Foundation

/// Swift Concurrency 기반 토큰 갱신 프록시 (Actor)
/// - 핵심 가치:
///   1. 여러 비동기 뷰 컴포넌트에서 거의 동시에 401 Unauthorized 오류를 수신하더라도,
///      서버의 Refresh Token 회전(Rotation) 엔드포인트는 단 1회만 호출되도록 직렬화 보장.
///   2. 진행 중인 Task가 존재할 경우, 새 네트워크 요청을 발생시키지 않고 기존 Task의 비동기 결과값을 공유받아 대기(await).
///   3. DIContainer / NetworkManager / Repository 간의 강한 참조 순환(Circular Dependency)을 해소하기 위해
///      핸들러 클로저 주입 방식(DIP)을 채택.
public actor TokenRefreshProxy {
    
    private var refreshHandler: (@Sendable () async throws -> Void)?
    private var ongoingRefreshTask: Task<Void, any Error>?
    
    public init() {}
    
    /// 토큰 갱신 비즈니스 로직(UseCase / Repository)을 외부에서 주입
    public func registerHandler(_ handler: @escaping @Sendable () async throws -> Void) {
        self.refreshHandler = handler
    }
    
    /// AuthInterceptor 또는 네트워크 파이프라인에서 401 에러를 만났을 때 호출
    public func executeRefresh() async throws {
        // 1. 이미 진행 중인 토큰 갱신 Task가 있다면 그 결과만 공유받아 await
        if let ongoing = ongoingRefreshTask {
            try await ongoing.value
            return
        }
        
        // 2. 등록된 핸들러 검증
        guard let handler = refreshHandler else {
            throw AppError.default("토큰 갱신 핸들러가 등록되지 않았습니다.")
        }
        
        // 3. 단일 Task를 생성하여 동시 진입 요청들이 동일한 비동기 작업을 참조하도록 바인딩
        let task = Task { () async throws in
            defer {
                self.ongoingRefreshTask = nil
            }
            try await handler()
        }
        
        self.ongoingRefreshTask = task
        try await task.value
    }
}
