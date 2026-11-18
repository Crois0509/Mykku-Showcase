//
//  ReportRepository.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 9/29/26.
//

import Foundation

/// 신고 도메인 데이터 저장소 추상 인터페이스 (Domain Layer)
/// - Swift 6 Typed Throws (`async throws(AppError)`)를 적용하여 컴파일 타임에 실패 시나리오 강제
public protocol ReportRepository: Sendable {
    func reportContent(
        type: ReportTargetType,
        id: Int,
        reason: ReportReasonType,
        detail: String
    ) async throws(AppError)
    
    func getReportReasonList() async throws(AppError) -> [ReportReason]
}
