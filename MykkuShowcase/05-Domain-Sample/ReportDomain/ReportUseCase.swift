//
//  ReportUseCase.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 9/29/26.
//

import Foundation

/// 신고 도메인 비즈니스 로직 추상화 (Domain Layer)
public protocol ReportUseCase: Sendable {
    func fetchReportReasons() async throws(AppError) -> [ReportReason]
    func submitReport(_ info: ReportInfo) async throws(AppError)
}

/// 신고 유스케이스 기본 구현체
/// - 도메인 규칙 검증(예: 신고 사유 상세 최소 글자 수 검증)을 뷰나 저장소가 아닌 유스케이스에서 일원화
public final class DefaultReportUseCase: ReportUseCase {
    
    private let repository: any ReportRepository
    
    public init(repository: any ReportRepository) {
        self.repository = repository
    }
    
    public func fetchReportReasons() async throws(AppError) -> [ReportReason] {
        try await repository.getReportReasonList()
    }
    
    public func submitReport(_ info: ReportInfo) async throws(AppError) {
        let trimmedDetail = info.detail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedDetail.count >= 10 else {
            throw .default("신고 상세 내용은 최소 10글자 이상 입력해야 합니다.")
        }
        
        try await repository.reportContent(
            type: info.type,
            id: info.id,
            reason: info.reason,
            detail: trimmedDetail
        )
    }
}
