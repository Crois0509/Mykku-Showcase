//
//  ServerErrorCode.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import Foundation

/// 서버 비즈니스 에러 코드 정의
public enum ServerErrorCode: String, Sendable {
    // MARK: - Common
    case commonInvalidInput = "C101"
    
    // MARK: - Auth
    case authOauthUserInfoFailed = "AU101"
    case authInvalidRefreshToken = "AU202"
    case authInvalidOauthToken = "AU203"
    case authExternalServiceError = "AU401"
    
    // MARK: - Block
    case blockCannotBlockSelf = "BL101"
    case blockKeywordTooLong = "BL102"
    case blockKeywordEmpty = "BL103"
    case blockKeywordLimitExceeded = "BL104"
    case blockMemberNotFound = "BL001"
    case blockKeywordNotFound = "BL003"
    case blockMemberAlreadyBlocked = "BL301"
    
    // MARK: - Contest
    case contestNotFound = "CN001"
    case contestWinnerNotAnnounced = "CN111"
    case contestAcceptanceSpeechForbidden = "CN201"
    
    // MARK: - Daily Message
    case dailyMessageNotFound = "DM001"
    case dailyMessageCommentNotFound = "DM002"
    case dailyMessageCommentTooLong = "DM102"
    case dailyMessageCommentForbidden = "DM201"
    
    // MARK: - Feed
    case feedNotFound = "FD001"
    case feedCommentNotFound = "FD002"
    case feedImageLimitExceeded = "FD102"
    case feedForbidden = "FD201"
    case feedCommentForbidden = "FD202"
    case feedTagTitleTooLong = "FD106"
    case feedTagInvalidFormat = "FD107"
    
    // MARK: - Report
    case reportAlreadyReported = "RP101"
    case reportContentNotFound = "RP001"
    
    // MARK: - Member
    case memberInvalidCurrentPassword = "MB103"
    case memberNicknameAlreadyExists = "MB301"
    case memberIdAlreadyExists = "MB302"
    
    // MARK: - Role
    case roleNotOwned = "RL002"
}

public extension ServerErrorCode {
    /// 인증 갱신 또는 재로그인이 필요한 에러 코드인지 여부
    var isAuthError: Bool {
        switch self {
        case .authOauthUserInfoFailed,
             .authInvalidRefreshToken,
             .authInvalidOauthToken,
             .authExternalServiceError:
            return true
        default:
            return false
        }
    }
}
