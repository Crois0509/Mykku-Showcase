//
//  NetworkGuardModifier.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 12/28/25.
//

import SwiftUI

/// 전역 네트워크 단절 감지 및 복구 ViewModifier
/// - NWPathMonitor 기반 NetworkMonitor 상태를 구독하여, 오프라인 시 인터랙션을 안전하게 보호
/// - 연결이 복구되면 스프링 애니메이션과 함께 직전 화면으로 매끄럽게 복귀
public struct NetworkGuardModifier: ViewModifier {
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @Binding var isLoading: Bool
    
    public init(isLoading: Binding<Bool>) {
        self._isLoading = isLoading
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(!networkMonitor.isConnected)
            
            if !networkMonitor.isConnected {
                VStack(alignment: .center) {
                    Spacer()
                    
                    Image(systemName: "wifi.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .padding(.bottom, 10)
                        .foregroundStyle(Color.blackApp)
                    
                    Text("네트워크 연결을 확인해 주세요")
                        .font(.pretendard(of: .bold, size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.blackApp)
                        .padding(.bottom, 24)
                    
                    Text("Wi-Fi 또는 데이터 연결이 불안정할 경우 발생할 수 있어요.\n연결 상태를 점검하신 후 다시 시도해 주세요.")
                        .font(.pretendard(of: .regular, size: 14))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.gray600)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 36)
                    
                    StickyButton(
                        isDisabled: $networkMonitor.isChecking,
                        vertical: .constant(0),
                        radius: .constant(.infinity),
                        text: networkMonitor.isChecking ? "확인 중..." : "다시 시도하기"
                    ) {
                        Task {
                            isLoading = true
                            await networkMonitor.manualCheck()
                            isLoading = false
                        }
                    }
                    .padding(.horizontal, 45)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.whiteApp)
                .ignoresSafeArea()
                .transition(.move(edge: .bottom))
                .zIndex(100)
            }
        }
        .animation(.spring, value: networkMonitor.isConnected)
    }
}

public extension View {
    func networkGuard(_ isLoading: Binding<Bool>) -> some View {
        self.modifier(NetworkGuardModifier(isLoading: isLoading))
    }
}
