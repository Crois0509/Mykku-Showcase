//
//  StickyButton.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI

/// 메인 CTA 버튼 스타일 (활성/비활성 및 눌림 스케일 애니메이션)
public struct MainButtonStyle<S: Shape>: ButtonStyle {
    @Binding var isDisabled: Bool
    let isAnimation: Bool
    let clipShape: S
    
    public init(isDisabled: Binding<Bool>, isAnimation: Bool = true, clipShape: S) {
        self._isDisabled = isDisabled
        self.isAnimation = isAnimation
        self.clipShape = clipShape
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isDisabled ? .gray600 : .black)
            .background(
                isDisabled ? Color.gray100 : configuration.isPressed ? Color.green700 : Color.green400
            )
            .clipShape(clipShape)
            .scaleEffect(!isAnimation ? 1.0 : configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// 시스템 키보드 애니메이션 곡선(Duration)과 동기화되는 하단 CTA 버튼
/// - keyboardWillShowNotification / keyboardWillHideNotification의 지속 시간 추출
/// - 키보드 등장/퇴장 속도에 맞추어 여백(vertical) 및 모서리(radius) 상태를 부드럽게 동기화
public struct StickyButton: View {
    @Binding var isDisabled: Bool
    @Binding var vertical: CGFloat
    @Binding var radius: CGFloat
    let text: String
    var maxVertical: CGFloat = 24
    var minVertical: CGFloat = 0
    let action: () -> Void
    
    public init(
        isDisabled: Binding<Bool>,
        vertical: Binding<CGFloat>,
        radius: Binding<CGFloat>,
        text: String,
        maxVertical: CGFloat = 24,
        minVertical: CGFloat = 0,
        action: @escaping () -> Void
    ) {
        self._isDisabled = isDisabled
        self._vertical = vertical
        self._radius = radius
        self.text = text
        self.maxVertical = maxVertical
        self.minVertical = minVertical
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(verbatim: text)
                .font(.pretendard(of: .bold, size: 16))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
        .buttonStyle(
            MainButtonStyle(
                isDisabled: $isDisabled,
                isAnimation: false,
                clipShape: RoundedRectangle(cornerRadius: radius)
            )
        )
        .disabled(isDisabled)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            guard let userInfo = notification.userInfo,
                  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            else { return }
            
            withAnimation(.smooth(duration: duration)) {
                vertical = minVertical
                radius = 0
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            guard let userInfo = notification.userInfo,
                  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            else { return }
            
            withAnimation(.smooth(duration: duration)) {
                vertical = maxVertical
                radius = 16
            }
        }
    }
}
