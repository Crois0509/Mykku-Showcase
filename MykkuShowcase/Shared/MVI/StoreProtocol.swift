//
//  StoreProtocol.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI
import Combine

/// 단방향 데이터 흐름(MVI)을 위한 기본 Store 프로토콜
/// - Single Source of Truth 원칙에 따라 하나의 State만을 소유
/// - Intent(Action)을 통해서만 State 변경 가능
/// - Swift Concurrency 메인 스레드 안전성을 보장하기 위해 @MainActor 격리
@MainActor
public protocol Store: ObservableObject {
    associatedtype State
    associatedtype Intent
    
    var state: State { get }
    func send(_ intent: Intent)
}
