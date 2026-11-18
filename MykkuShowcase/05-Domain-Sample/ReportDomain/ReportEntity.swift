//
//  ReportEntity.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 9/29/26.
//

import Foundation

/// 신고 대상 유형 (순수 도메인 엔티티)
public enum ReportTargetType: String, Codable, Sendable {
    case feed = "FEED"                          // 피드
    case feedComment = "FEED_COMMENT"           // 피드 댓글(답글)
    case dailyMSGComment = "DAILY_MESSAGE_COMMENT" // 하루 덕담 댓글(답글)
}

/// 신고 사유 분류 열거형
public enum ReportReasonType: String, Codable, Sendable {
    case abuse = "ABUSE"               // 욕설 및 비방
    case obscene = "OBSCENE"           // 음란하거나 부적절한 콘텐츠
    case spam = "SPAM"                 // 반복 게시물, 광고 및 무분별한 홍보
    case fraud = "FRAUD"               // 사칭 및 허위 정보
    case personalInfo = "PERSONAL_INFO"// 개인정보 노출
    case copyright = "COPYRIGHT"       // 저작권 침해
    case etc = "ETC"                   // 기타
}

/// 신고 사유 모델
public struct ReportReason: Equatable, Hashable, Sendable {
    public let reason: String
    public let description: String
    
    public init(reason: String, description: String) {
        self.reason = reason
        self.description = description
    }
}

/// 신고 접수 요청 정보 엔티티
public struct ReportInfo: Equatable, Sendable {
    public let type: ReportTargetType
    public let id: Int
    public let reason: ReportReasonType
    public var detail: String
    
    public init(type: ReportTargetType, id: Int, reason: ReportReasonType, detail: String) {
        self.type = type
        self.id = id
        self.reason = reason
        self.detail = detail
    }
}
