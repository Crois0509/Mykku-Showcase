//
//  LocalStorage.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import Foundation

/// 세션 토큰 및 로컬 설정 저장소 (Thread-Safe In-Memory Mock / Keychain 대체)
public enum LocalStorage {
    private final class TokenStore: @unchecked Sendable {
        private let lock = NSLock()
        private var _accessToken: String? = "mock_valid_access_token_sample"
        private var _refreshToken: String? = "mock_valid_refresh_token_sample"
        
        var accessToken: String? {
            get { lock.withLock { _accessToken } }
            set { lock.withLock { _accessToken = newValue } }
        }
        
        var refreshToken: String? {
            get { lock.withLock { _refreshToken } }
            set { lock.withLock { _refreshToken = newValue } }
        }
        
        func clear() {
            lock.withLock {
                _accessToken = nil
                _refreshToken = nil
            }
        }
    }
    
    private static let store = TokenStore()
    
    public static var accessToken: String? {
        get { store.accessToken }
        set { store.accessToken = newValue }
    }
    
    public static var refreshToken: String? {
        get { store.refreshToken }
        set { store.refreshToken = newValue }
    }
    
    public static func clear() {
        store.clear()
    }
}

public extension Notification.Name {
    static let logoutNotification = Notification.Name("com.mykku.showcase.logoutNotification")
}
