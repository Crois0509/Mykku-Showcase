//
//  GlobalRoleAlertView.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 10/14/26.
//

import SwiftUI

/// 칭호 정보 도메인 엔티티
public struct MyRoleInfo: Equatable, Sendable {
    public let id: Int
    public let name: String
    public let description: String
    public let isRepresentative: Bool
    
    public init(id: Int, name: String, description: String, isRepresentative: Bool) {
        self.id = id
        self.name = name
        self.description = description
        self.isRepresentative = isRepresentative
    }
    
    public static func mock() -> [Self] {
        return [
            .init(
                id: 1,
                name: "첫 만남",
                description: "MYKKU에 오신 것을 환영합니다!",
                isRepresentative: true
            ),
            .init(
                id: 2,
                name: "도키도키 아카이버",
                description: "이벤트 5회 참여 달성",
                isRepresentative: false
            ),
            .init(
                id: 3,
                name: "성실한 덕후",
                description: "연속 7일 출석 체크 완료",
                isRepresentative: false
            )
        ]
    }
}

/// 독립 UIWindow 상에서 렌더링되는 칭호 획득 전역 축하 Alert View
public struct GlobalRoleAlertView: View {
    
    @State private var viewOpacity: CGFloat = 0.0
    
    let role: MyRoleInfo
    let showingTime: CGFloat
    let dismissAction: () -> Void
    private let duration: CGFloat = 0.3
    
    public init(role: MyRoleInfo, showingTime: CGFloat, dismissAction: @escaping () -> Void) {
        self.role = role
        self.showingTime = showingTime
        self.dismissAction = dismissAction
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .zIndex(0)
                .foregroundStyle(Color.black.opacity(0.25))
                .transition(.opacity)
                .onTapGesture {
                    Task {
                        withAnimation(.easeInOut(duration: duration)) {
                            viewOpacity = 0.0
                        }
                        try? await Task.sleep(for: .seconds(duration + 0.1))
                        dismissAction()
                    }
                }
            
            VStack(alignment: .center, spacing: 16) {
                Text("🎉 새로운 칭호를 획득했어요 🎉")
                    .font(.pretendard(of: .bold, size: 15))
                    .foregroundStyle(Color.blackApp)
                
                Text(role.name)
                    .font(.pretendard(of: .bold, size: 18))
                    .foregroundStyle(Color.blackApp)
                    .frame(width: 254, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(Color.green100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.green600, lineWidth: 1.5)
                            )
                    )
                
                Text(role.description)
                    .font(.pretendard(of: .regular, size: 13))
                    .foregroundStyle(Color.gray700)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .zIndex(2)
            .padding(.vertical, 24)
            .padding(.horizontal, 30)
            .background(Color.whiteApp)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 4)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .opacity(viewOpacity)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: duration)) {
                viewOpacity = 1.0
            }
            hideKeyboard()
        }
        .task {
            let stayDuration = max(0.5, showingTime - duration)
            try? await Task.sleep(for: .seconds(stayDuration))
            withAnimation(.easeInOut(duration: duration)) {
                viewOpacity = 0.0
            }
            try? await Task.sleep(for: .seconds(duration + 0.1))
            dismissAction()
        }
    }
}

public extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
