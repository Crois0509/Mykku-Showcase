//
//  BaseCoordinator.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 5/20/26.
//

import SwiftUI

/// 네비게이션 스택과 모달 시트, 탭바 가시성을 총괄하는 BaseCoordinator
/// - View / ViewController 내부에서 화면 전환(Push, Pop, Present) 로직을 완전히 제거
/// - 트리 구조의 계층적 네비게이션 관리 및 하위 화면 생명주기 통제
open class BaseCoordinator<Route: Hashable, Sheet: Identifiable>: CoordinatorProtocol {
    @Published public var sheet: Sheet?
    @Published private var _path: [Route] = [] {
        didSet {
            updateTabBarVisibility()
        }
    }

    public var onLogout: (() -> Void)?
    public var onTabBarHidden: ((Bool) -> Void)?

    public init() {}

    public var path: Binding<[Route]> {
        Binding(
            get: { self._path },
            set: { newValue in self._path = newValue }
        )
    }

    /// present 화면이 노출 중인지 여부
    open var isPresentingTabBarHiddenContent: Bool {
        return false
    }

    open func shouldHideTabBar(for route: Route) -> Bool {
        return true
    }

    open func push(_ view: Route) {
        _path.append(view)
    }

    open func pop() {
        guard !_path.isEmpty else { return }
        _path.removeLast()
    }

    open func popToRoot() {
        _path.removeAll()
    }

    open func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }

    open func dismissSheet() {
        sheet = nil
    }

    public func updateTabBarVisibility() {
        onTabBarHidden?(isNavigationTabBarHidden || isPresentingTabBarHiddenContent)
    }

    private var isNavigationTabBarHidden: Bool {
        guard let route = _path.last else { return false }
        return shouldHideTabBar(for: route)
    }
}
