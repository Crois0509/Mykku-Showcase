//
//  GlobalAlertManager.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 10/14/26.
//

import SwiftUI

/// 독립 UIWindow 기반 전역 칭호 획득 알림 매니저
/// - 핵심 설계:
///   - SwiftUI ViewModifier / Sheet 방식은 사용자가 이전 화면으로 이동(Pop)하거나 시트를 닫으면 알림 뷰가 함께 강제 종료되는 한계가 있음.
///   - 최상위 UIWindowScene 위에 시스템 Alert보다 높은 레벨(.alert + 1)의 독립 투명 UIWindow를 동적으로 생성함으로써,
///     뷰 계층이나 네비게이션 스택 변화와 완전히 무관하게 정해진 시간 동안 보상 축하 애니메이션을 유지한 뒤 안전하게 해제.
@MainActor
public final class GlobalAlertManager {
    
    public static let shared = GlobalAlertManager()
    private var alertWindow: UIWindow?

    private init() {}
        
    public func showAlert(roleInfo: MyRoleInfo?, for second: CGFloat = 3.0) {
        guard let roleInfo,
              let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })
                ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene)
        else { return }
        
        // 기존 열려 있는 윈도우가 있다면 정리
        hideAlert()
        
        let window = UIWindow(windowScene: windowScene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        
        let hostingController = UIHostingController(
            rootView: GlobalRoleAlertView(role: roleInfo, showingTime: second) { [weak self] in
                self?.hideAlert()
            }
        )
        hostingController.view.backgroundColor = .clear
        window.rootViewController = hostingController
        window.isHidden = false
        window.makeKeyAndVisible()
        
        self.alertWindow = window
    }
    
    public func hideAlert() {
        alertWindow?.isHidden = true
        alertWindow = nil
    }
}
