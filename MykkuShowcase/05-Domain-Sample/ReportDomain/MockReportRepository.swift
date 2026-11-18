//
//  MockReportRepository.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 9/29/26.
//

import Foundation

/// 오프라인 개발 및 단위 테스트를 위한 Mock Repository (Data Layer)
/// - DIContainer의 `.mock` 환경 플래그를 통해 네트워크 연결 없이도 전체 신고 파이프라인 검증 가능
public final class MockReportRepository: ReportRepository {
    
    public init() {}
    
    public func reportContent(
        type: ReportTargetType,
        id: Int,
        reason: ReportReasonType,
        detail: String
    ) async throws(AppError) {
        do {
            // 실제 네트워크 지연 시뮬레이션
            try await Task.sleep(for: .seconds(0.8))
        } catch {
            throw .default(error.localizedDescription)
        }
    }
    
    public func getReportReasonList() async throws(AppError) -> [ReportReason] {
        do {
            try await Task.sleep(for: .seconds(0.3))
            return [
                .init(reason: "ABUSE", description: "욕설 및 비방"),
                .init(reason: "OBSCENE", description: "음란하거나 부적절한 콘텐츠"),
                .init(reason: "SPAM", description: "반복 게시물, 광고 및 무분별한 홍보"),
                .init(reason: "FRAUD", description: "사칭 및 허위 정보"),
                .init(reason: "PERSONAL_INFO", description: "개인정보 노출"),
                .init(reason: "COPYRIGHT", description: "저작권 침해"),
                .init(reason: "ETC", description: "기타")
            ]
        } catch {
            throw .default(error.localizedDescription)
        }
    }
}
