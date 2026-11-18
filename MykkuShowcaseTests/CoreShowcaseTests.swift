//
//  CoreShowcaseTests.swift
//  MYKKU Core Showcase Tests
//
//  Created by Jang Sang-gyeong on 2026.
//

import XCTest
@testable import MykkuShowcase

final class CoreShowcaseTests: XCTestCase {
    
    /// 1. TokenRefreshProxy 동시 401 직렬화 검증
    /// - 20개의 비동기 Task가 동시에 토큰 재발급을 요청하더라도, 실제 서버 갱신 핸들러는 단 1회만 호출되어야 함
    func testTokenRefreshProxySerializesConcurrent401Requests() async throws {
        let proxy = TokenRefreshProxy()
        let mockRepo = MockAuthRepository()
        
        await proxy.registerHandler {
            try await mockRepo.executeReissueToken()
        }
        
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<20 {
                group.addTask {
                    try? await proxy.executeRefresh()
                }
            }
        }
        
        XCTAssertEqual(mockRepo.reissueCallCount, 1, "동시 다발적 401 응답에도 토큰 갱신 API는 단 1회만 호출되어야 합니다.")
    }
    
    /// 2. Clean Architecture ReportUseCase 도메인 유효성 검증
    func testReportUseCaseRejectsShortDescription() async {
        let mockRepo = MockReportRepository()
        let useCase = DefaultReportUseCase(repository: mockRepo)
        
        let invalidInfo = ReportInfo(
            type: .feed,
            id: 1,
            reason: .spam,
            detail: "짧은글" // 10자 미만
        )
        
        do {
            try await useCase.submitReport(invalidInfo)
            XCTFail("10자 미만 신고 상세 내용은 AppError를 던져야 합니다.")
        } catch {
            XCTAssertEqual(error, .default("신고 상세 내용은 최소 10글자 이상 입력해야 합니다."))
        }
    }
    
    /// 3. MVI ReportStore 단방향 상태 흐름 검증
    @MainActor
    func testReportStoreLoadsReasonsFromMockRepository() async throws {
        let container = DIContainer(status: .mock)
        let store = container.makeReportStore()
        
        XCTAssertTrue(store.state.reasonList.isEmpty)
        
        store.send(.getReportReasonList)
        
        // MockRepository 지연 대기
        try await Task.sleep(for: .seconds(0.6))
        
        XCTAssertFalse(store.state.reasonList.isEmpty)
        XCTAssertFalse(store.state.isLoading)
        XCTAssertNil(store.state.errorState)
    }
    
    /// 4. CommunityCommentStore 낙관적 유저 차단(Optimistic UI Block) 즉시 필터링 검증
    @MainActor
    func testCommunityCommentStoreOptimisticBlockFiltersCommentsAndReplies() {
        let store = CommunityCommentStore()
        let spamMemberId = "user_spam_99"
        
        XCTAssertTrue(store.commentList?.comments.contains(where: { $0.author.memberId == spamMemberId }) == true)
        
        store.blockMember(spamMemberId)
        
        XCTAssertTrue(store.blockedMemberIds.contains(spamMemberId))
        XCTAssertFalse(store.commentList?.comments.contains(where: { $0.author.memberId == spamMemberId }) == true)
    }
}
