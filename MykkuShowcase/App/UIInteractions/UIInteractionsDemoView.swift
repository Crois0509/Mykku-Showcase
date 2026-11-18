//
//  UIInteractionsDemoView.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI

/// 1번: ContentsViewController의 applyStickyHeader(_:) 주간 달력 숨김 스티키 헤더
/// 2번: 독립 UIWindow 기반 전역 칭호 팝업 (GlobalAlertManager)
/// 3번: MYKKU CarouselView 수상작 포스터 캐러셀
/// 4번: FanNoteViewerViewController 3분할 제스처 팬노트 뷰어
struct UIInteractionsDemoView: View {
    @ObservedObject var coordinator: ShowcaseCoordinator
    @State private var selectedFeatureIndex: Int = 0
    @State private var stickyScrollRatio: CGFloat = 0.0
    
    private let featureTabs = [
        "1. Sticky달력",
        "2. Window팝업",
        "3. Carousel",
        "4. 팬노트뷰어"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 4대 인터랙션 전환 탭 바
            HStack(spacing: 0) {
                ForEach(featureTabs.indices, id: \.self) { idx in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedFeatureIndex = idx
                        }
                    } label: {
                        VStack(spacing: 10) {
                            Text(featureTabs[idx])
                                .font(.pretendard(of: selectedFeatureIndex == idx ? .bold : .medium, size: 12))
                                .foregroundStyle(selectedFeatureIndex == idx ? Color.blackApp : Color.gray500)
                                .padding(.top, 12)
                            
                            Rectangle()
                                .fill(selectedFeatureIndex == idx ? Color.green400 : Color.gray200)
                                .frame(height: 3)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color.whiteApp)
            
            if selectedFeatureIndex == 0 {
                stickyHeaderFeatureSection
            } else if selectedFeatureIndex == 1 {
                globalWindowAlertFeatureSection
            } else if selectedFeatureIndex == 2 {
                carouselFeatureSection
            } else {
                fanNoteViewerFeatureSection
            }
        }
        .background(Color.gray50)
        .navigationTitle("UI/UX Interactions")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: Feature 1 - ContentsViewController Sticky Header (applyStickyHeader(_:))
    private var stickyHeaderFeatureSection: some View {
        VStack(spacing: 0) {
            // 상태 인디케이터 바
            HStack {
                Text("applyStickyHeader(_:)\n실시간 스크롤 비율")
                    .font(.pretendard(of: .semiBold, size: 12))
                    .foregroundStyle(Color.blackApp)
                Spacer()
                Text(String(format: "scrollRatio: %.2f (alpha: %.2f)", stickyScrollRatio, max(0, 1.0 - stickyScrollRatio)))
                    .font(.pretendard(of: .bold, size: 12))
                    .foregroundStyle(Color.blackApp)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green400)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.green50)
            
            // 실제 ContentsStickyHeaderViewController 임베드
            ContentsStickyHeaderRepresentable(scrollRatio: $stickyScrollRatio)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // MARK: Feature 2 - GlobalAlertManager Independent UIWindow
    private var globalWindowAlertFeatureSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 14) {
                    SectionBadgeHeader(
                        badge: "UIWINDOW (.ALERT + 1)",
                        title: "독립 UIWindow 기반 전역 칭호 획득 팝업"
                    )
                    
                    Text("일반적인 SwiftUI Sheet나 ViewModifier 알림은 사용자가 화면을 뒤로 이동(Pop)하거나 모달을 닫으면 함께 강제 종료됩니다.\nMYKKU의 GlobalAlertManager는 최상위 UIWindowScene 위에 독립된 투명 UIWindow를 생성하여 화면 전환과 무관하게 축하 애니메이션을 끝까지 보장합니다.")
                        .font(.pretendard(of: .regular, size: 13))
                        .foregroundStyle(Color.gray700)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(spacing: 10) {
                        ForEach(MyRoleInfo.mock(), id: \.id) { role in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("🎖️ \(role.name)")
                                        .font(.pretendard(of: .bold, size: 14))
                                        .foregroundStyle(Color.blackApp)
                                    Text(role.description)
                                        .font(.pretendard(of: .regular, size: 12))
                                        .foregroundStyle(Color.gray600)
                                }
                                Spacer()
                                Button("팝업 띄우기") {
                                    GlobalAlertManager.shared.showAlert(roleInfo: role, for: 2.5)
                                }
                                .font(.pretendard(of: .bold, size: 12))
                                .foregroundStyle(Color.blackApp)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.green400)
                                .clipShape(Capsule())
                            }
                            .padding(14)
                            .background(Color.gray50)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    
                    Button {
                        let role = MyRoleInfo.mock().first
                        GlobalAlertManager.shared.showAlert(roleInfo: role, for: 3.0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            coordinator.pop()
                        }
                    } label: {
                        Text("팝업 호출 후 즉시 이전 화면으로 Pop 테스트")
                            .font(.pretendard(of: .bold, size: 14))
                            .foregroundStyle(Color.whiteApp)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.blackApp)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.whiteApp)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray200, lineWidth: 1))
                )
            }
            .padding(20)
        }
    }
    
    // MARK: Feature 3 - MYKKU CarouselView
    private var carouselFeatureSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    SectionBadgeHeader(
                        badge: "MYKKU CAROUSEL VIEW",
                        title: "내 수상작 아카이브 캐러셀 (CarouselView)"
                    )
                    
                    Text("드래그 변위(@GestureState dragOffset)와 예측 종료 가속도(predictedEndLocation velocity)를 결합하여, 짧은 플리킹이나 드래그로도 자연스럽게 센터 스냅되는 MYKKU의 커스텀 CarouselView입니다.")
                        .font(.pretendard(of: .regular, size: 13))
                        .foregroundStyle(Color.gray700)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                MyWinningCarouselShowcaseView()
                    .padding(.bottom, 28)
            }
        }
    }
    
    // MARK: Feature 4 - FanNoteViewerViewController (3-Zone Gesture & Auto-Hide Timer Toolbar)
    private var fanNoteViewerFeatureSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("좌/우 1/3 탭(페이지 이동) · 중앙 1/3 탭(툴바 + 3초 자동 숨김 타이머)")
                    .font(.pretendard(of: .semiBold, size: 11))
                    .foregroundStyle(Color.blackApp)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.green50)
            
            FanNoteViewerRepresentable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
