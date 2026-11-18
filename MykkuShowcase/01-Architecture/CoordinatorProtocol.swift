//
//  CoordinatorProtocol.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI

/// 화면 전환 및 라우팅 책임 분리를 위한 Coordinator 추상 프로토콜
public protocol CoordinatorProtocol: ObservableObject {
    associatedtype Route: Hashable
    associatedtype Sheet: Identifiable
    
    var path: Binding<[Route]> { get }
    var sheet: Sheet? { get }
    
    func push(_ view: Route)
    func pop()
    func popToRoot()
    func presentSheet(_ sheet: Sheet)
    func dismissSheet()
}
