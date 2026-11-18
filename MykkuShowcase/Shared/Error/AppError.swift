//
//  AppError.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import Foundation

/// 앱 전역에서 사용하는 표준 도메인 에러 열거형
/// - Swift 6 Typed Throws 표준 준수
public enum AppError: Error, Equatable, Sendable {
    case `default`(String)
    case server(message: String, code: String?)
    case unauthorized
    case networkDisconnected
    case unknown
    
    public var message: String {
        switch self {
        case .default(let message):
            return message
        case .server(let message, _):
            return message
        case .unauthorized:
            return "세션이 만료되었습니다. 다시 로그인해 주세요."
        case .networkDisconnected:
            return "네트워크 연결을 확인해 주세요."
        case .unknown:
            return "알 수 없는 에러가 발생했습니다. 잠시 후 다시 시도해 주세요."
        }
    }
    
    public var code: String? {
        switch self {
        case .server(_, let code):
            return code
        case .default, .unauthorized, .networkDisconnected, .unknown:
            return nil
        }
    }
    
    public var serverCode: ServerErrorCode? {
        guard let code else { return nil }
        return ServerErrorCode(rawValue: code)
    }
    
    public static func notImplemented(_ message: String = "구현 예정인 기능입니다.") -> AppError {
        return .default(message)
    }
}
