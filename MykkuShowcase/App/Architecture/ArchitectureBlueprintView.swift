//
//  ArchitectureBlueprintView.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI

struct ArchitectureBlueprintView: View {
    @State private var selectedTab: Int = 0
    @State private var selectedLayerIndex: Int = 0
    
    private let tabs = ["Clean Architecture & MVI", "Coordinator & Store 트리"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 커스텀 MYKKU 세그먼트 바
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { idx in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedTab = idx
                        }
                    } label: {
                        VStack(spacing: 10) {
                            Text(tabs[idx])
                                .font(.pretendard(of: selectedTab == idx ? .bold : .medium, size: 14))
                                .foregroundStyle(selectedTab == idx ? Color.blackApp : Color.gray500)
                                .padding(.top, 12)
                            
                            Rectangle()
                                .fill(selectedTab == idx ? Color.green400 : Color.gray200)
                                .frame(height: 3)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color.whiteApp)
            
            ScrollView(.vertical, showsIndicators: false) {
                if selectedTab == 0 {
                    cleanArchitectureDiagramSection
                        .padding(20)
                } else {
                    coordinatorTreeDiagramSection
                        .padding(20)
                }
            }
            .background(Color.gray50)
        }
        .navigationTitle("Architecture & DI")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: Tab 1 - Clean Architecture & MVI Visual Diagram
    private var cleanArchitectureDiagramSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            // 1. MVI Unidirectional Data Flow Diagram
            VStack(alignment: .leading, spacing: 14) {
                SectionBadgeHeader(badge: "MVI PATTERN", title: "단방향 데이터 흐름 (Unidirectional Flow)")
                
                Text("모든 화면의 Store는 단일 불변 상태(@Published State)만 소유하며, 외부에서는 오직 send(Intent)를 통해서만 상태 변경을 요청할 수 있습니다.")
                    .font(.pretendard(of: .regular, size: 13))
                    .foregroundStyle(Color.gray700)
                    .lineSpacing(3.5)
                    .fixedSize(horizontal: false, vertical: true)
                
                ScrollView(.horizontal) {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            mviNode(title: "View", subtitle: "SwiftUI / UIKit VC", bg: .gray100, border: .gray300)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.blackApp)
                            mviNode(title: "Intent", subtitle: "store.send(Action)", bg: .green100, border: .green500)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.blackApp)
                            mviNode(title: "Store", subtitle: "@MainActor 격리", bg: .green400, border: .green700)
                        }
                        
                        HStack {
                            Spacer()
                            Label("UseCase / Repository 비동기 호출 (async throws)", systemImage: "arrow.down.left.arrow.up.right")
                                .font(.pretendard(of: .semiBold, size: 11))
                                .foregroundStyle(Color.gray700)
                                .padding(.vertical, 4)
                            Spacer()
                        }
                        
                        HStack(spacing: 8) {
                            mviNode(title: "UI Re-render", subtitle: "Diffable / View 갱신", bg: .gray100, border: .gray300)
                            Image(systemName: "arrow.left")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.blackApp)
                            mviNode(title: "@Published State", subtitle: "Single Source of Truth", bg: .blue100, border: .blue400)
                            Image(systemName: "arrow.left")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.blackApp)
                            mviNode(title: "Domain Entity", subtitle: "순수 비즈니스 모델", bg: .pink50, border: .pink300)
                        }
                    }
                    .padding(14)
                    .background(Color.gray50)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .scrollIndicators(.hidden)
            }
            .padding(18)
            .background(cardBackground)
            
            // 2. 4-Layer Architecture Interactive Diagram
            VStack(alignment: .leading, spacing: 14) {
                SectionBadgeHeader(badge: "4-LAYER ARCHITECTURE", title: "계층별 역할 및 의존성 역전 (DIP)")
                
                Text("각 레이어 카드를 탭하면 포함된 핵심 코드와 아키텍처 설계 원칙을 확인할 수 있습니다.")
                    .font(.pretendard(of: .regular, size: 13))
                    .foregroundStyle(Color.gray700)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 6) {
                    layerDiagramBox(
                        index: 0,
                        layerName: "Presentation Layer",
                        role: "View + @MainActor MVI Store",
                        files: "ReportView.swift · ReportStore.swift · CommentDetailViewController.swift",
                        description: "UIKit ViewController와 SwiftUI View가 단일 Store의 @Published state를 구독합니다. 비즈니스 로직 없이 오직 사용자 이벤트를 Intent로 변환합니다.",
                        accentColor: .green400
                    )
                    
                    dependencyArrow(text: "라우팅 위임 (Delegate / Closure)")
                    
                    layerDiagramBox(
                        index: 1,
                        layerName: "Navigation Layer (Coordinator)",
                        role: "BaseCoordinator<Route, Sheet>",
                        files: "CoordinatorProtocol.swift · BaseCoordinator.swift",
                        description: "View 내부에서 push / pop / presentSheet 코드를 완전히 제거하고, 계층형 Coordinator가 화면 전환과 탭바 가시성을 일괄 제어합니다.",
                        accentColor: .blue300
                    )
                    
                    dependencyArrow(text: "인터페이스 호출 (UseCase & Repository Protocol)")
                    
                    layerDiagramBox(
                        index: 2,
                        layerName: "Domain Layer (Core Business)",
                        role: "Entity + UseCase + Repository Interface",
                        files: "ReportEntity.swift · ReportUseCase.swift · ReportRepository.swift",
                        description: "외부 프레임워크나 UIKit/Moya에 전혀 의존하지 않는 순수 Swift 영역입니다. Swift 6 Typed Throws(async throws(AppError))로 실패 계약을 강제합니다.",
                        accentColor: .pink300
                    )
                    
                    dependencyArrow(text: "⬆️ 의존성 역전 (DIP: Data가 Domain Protocol을 채택)")
                    
                    layerDiagramBox(
                        index: 3,
                        layerName: "Data Layer & DIContainer",
                        role: "Default/Mock Repository + Network + Actor Proxy",
                        files: "DefaultReportRepository.swift · MockReportRepository.swift · DIContainer.swift",
                        description: "DIContainer가 Status(.network vs .mock)에 따라 실제 서버 통신 구현체 또는 인메모리 Mock 구현체를 런타임에 주입합니다.",
                        accentColor: .gray300
                    )
                }
            }
            .padding(18)
            .background(cardBackground)
        }
    }
    
    // MARK: Tab 2 - Coordinator Tree & StoreContainer Diagram
    private var coordinatorTreeDiagramSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            // 1. Coordinator Tree Hierarchy
            VStack(alignment: .leading, spacing: 14) {
                SectionBadgeHeader(badge: "COORDINATOR TREE", title: "계층적 네비게이션 라우팅 트리")
                
                Text("MYKKU는 앱 진입점부터 각 메인 탭까지 부모-자식 트리 구조의 Coordinator로 화면 스택(NavigationPath)과 시트(Sheet) 생명주기를 관리합니다.")
                    .font(.pretendard(of: .regular, size: 13))
                    .foregroundStyle(Color.gray700)
                    .lineSpacing(3.5)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 10) {
                    // Root
                    treeNodeBox(
                        title: "AppCoordinator",
                        subtitle: "인증 상태 및 온보딩 완료 여부에 따라 최상위 플로우 분기",
                        badge: "ROOT",
                        bgHex: 0x282828,
                        textColor: .whiteApp
                    )
                    
                    Image(systemName: "arrow.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.gray600)
                    
                    // Second Level
                    HStack(spacing: 8) {
                        treeBranchBox(title: "Auth\nCoordinator", subtitle: "소셜/이메일 로그인\n회원가입 플로우", color: .pink100)
                        treeBranchBox(title: "Onboarding\nCoordinator", subtitle: "취향/장르/무드\n초기 설정", color: .blue100)
                        treeBranchBox(title: "Main\nCoordinator", subtitle: "4대 메인 탭 및\n탭바 가시성 제어", color: .green200)
                    }
                    
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.turn.Right.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.green800)
                        Text("MainCoordinator 하위 4개 탭 독립 스택")
                            .font(.pretendard(of: .bold, size: 12))
                            .foregroundStyle(Color.green900)
                        Spacer()
                    }
                    .padding(.top, 4)
                    
                    // Third Level (4 Tabs)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        tabCoordinatorCard(tab: "HOME", name: "Home\nCoordinator", routes: "이벤트 상세 · 알림 · 배너 라우팅")
                        tabCoordinatorCard(tab: "CONTENTS", name: "Contents\nCoordinator", routes: "주간/월간 달력 · 팬노트 · 하루덕담 · 콘테스트")
                        tabCoordinatorCard(tab: "COMMUNITY", name: "Community\nCoordinator", routes: "게시판 검색 · 피드 상세 · 글쓰기 · 댓글/신고")
                        tabCoordinatorCard(tab: "MYPAGE", name: "MyPage\nCoordinator", routes: "프로필/칭호 편집 · 차단 유저/키워드 · 설정")
                    }
                }
                .padding(14)
                .background(Color.gray50)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(18)
            .background(cardBackground)
            
            // 2. StoreContainer Lifecycle Isolation Diagram
            VStack(alignment: .leading, spacing: 14) {
                SectionBadgeHeader(badge: "STORE CONTAINER", title: "StoreContainer 기반 전역 상태 격리")
                
                Text("초기 단일 MainStore가 모든 탭의 데이터를 소유하며 발생하던 비대화 및 불필요한 리렌더링을 해결하기 위해, 탭별 Store 생명주기를 독립 격리했습니다.")
                    .font(.pretendard(of: .regular, size: 13))
                    .foregroundStyle(Color.gray700)
                    .lineSpacing(3.5)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Text("DIContainer")
                            .font(.pretendard(of: .bold, size: 13))
                            .foregroundStyle(Color.whiteApp)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blackApp)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                        
                        Text("StoreContainer (@MainActor)")
                            .font(.pretendard(of: .bold, size: 13))
                            .foregroundStyle(Color.blackApp)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.green400)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        storeIsolationRow(storeName: "contents", targetView: "ContentsCoordinatorView 전용 주입 (타 탭 상태 변화 무관)")
                        storeIsolationRow(storeName: "community", targetView: "CommunityCoordinatorView 전용 주입 (피드/댓글 상태 격리)")
                        storeIsolationRow(storeName: "myPage", targetView: "MyPageCoordinatorView 전용 주입 (프로필/칭호 상태 격리)")
                        storeIsolationRow(storeName: "report", targetView: "ReportView 생성 시 DIContainer Factory로 독립 인스턴스 주입")
                    }
                    .padding(12)
                    .background(Color.gray50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(18)
            .background(cardBackground)
            
            // 3. Hybrid Bridge & Comment Adapter Architecture
            VStack(alignment: .leading, spacing: 14) {
                SectionBadgeHeader(badge: "HYBRID BRIDGE & ADAPTER", title: "UIKit ↔ SwiftUI 브릿지 & 통합 댓글 어댑터")
                
                Text("1) BaseRepresentable & BaseCollectionView: UIKit 컬렉션뷰가 SwiftUI 계층에 편입될 때 CoordinatorType과 StoreType 주입을 강제하고 CompositionalLayout 팩토리를 재사용합니다.\n2) ContentsCommentAdapter: 서로 다른 도메인(하루덕담 DailyMSGStore, 커뮤니티 CommunityCommentStore)의 상태를 CommentDetailStoreProtocol로 변환하여 단 하나의 댓글 VC로 통합했습니다.")
                    .font(.pretendard(of: .regular, size: 13))
                    .foregroundStyle(Color.gray700)
                    .lineSpacing(3.5)
                    .fixedSize(horizontal: false, vertical: true)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        treeBranchBox(title: "DailyMSGStore\nCommunityStore", subtitle: "서로 다른 도메인 상태", color: .blue100)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                        treeBranchBox(title: "ContentsComment\nAdapter", subtitle: "CommentDetailStore\nProtocol 변환 중계", color: .green200)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                        treeBranchBox(title: "CommentDetail\nViewController", subtitle: "단일 통합 댓글 UI\n(트리 보존·차단·신고)", color: .gray100)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding(18)
            .background(cardBackground)
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.whiteApp)
            .shadow(color: Color.blackApp.opacity(0.05), radius: 8, x: 0, y: 3)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray200, lineWidth: 1))
    }
    
    private func mviNode(title: String, subtitle: String, bg: Color, border: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.pretendard(of: .bold, size: 12))
                .foregroundStyle(Color.blackApp)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.pretendard(of: .regular, size: 11))
                .foregroundStyle(Color.gray700)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: true, vertical: true)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: 1))
    }
    
    private func dependencyArrow(text: String) -> some View {
        HStack {
            Spacer()
            Image(systemName: "arrow.down")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.gray500)
            Text(text)
                .font(.pretendard(of: .medium, size: 11))
                .foregroundStyle(Color.gray600)
            Spacer()
        }
        .padding(.vertical, 2)
    }
    
    private func layerDiagramBox(
        index: Int,
        layerName: String,
        role: String,
        files: String,
        description: String,
        accentColor: Color
    ) -> some View {
        let isSelected = (selectedLayerIndex == index)
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedLayerIndex = index
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 10, height: 10)
                    Text(layerName)
                        .font(.pretendard(of: .bold, size: 14))
                        .foregroundStyle(Color.blackApp)
                    Spacer()
                    Text(role)
                        .font(.pretendard(of: .semiBold, size: 11))
                        .foregroundStyle(Color.gray700)
                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.gray500)
                }
                
                if isSelected {
                    Divider()
                    Text(description)
                        .font(.pretendard(of: .regular, size: 12))
                        .foregroundStyle(Color.gray800)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("📄 \(files)")
                        .font(.pretendard(of: .semiBold, size: 11))
                        .foregroundStyle(Color.blackApp)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(accentColor.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(14)
            .background(isSelected ? Color.gray50 : Color.whiteApp)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.blackApp : Color.gray200, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func treeNodeBox(title: String, subtitle: String, badge: String, bgHex: UInt, textColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.pretendard(of: .bold, size: 14))
                    .foregroundStyle(textColor)
                Spacer()
                Text(badge)
                    .font(.pretendard(of: .bold, size: 11))
                    .foregroundStyle(Color.blackApp)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green400)
                    .clipShape(Capsule())
            }
            Text(subtitle)
                .font(.pretendard(of: .regular, size: 12))
                .foregroundStyle(Color.gray300)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: bgHex))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func treeBranchBox(title: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.pretendard(of: .bold, size: 10))
                .foregroundStyle(Color.blackApp)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.pretendard(of: .regular, size: 9))
                .foregroundStyle(Color.gray700)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: true, vertical: true)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func tabCoordinatorCard(tab: String, name: String, routes: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(tab)
                .font(.pretendard(of: .bold, size: 9))
                .foregroundStyle(Color.blackApp)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(Color.green300)
                .clipShape(Capsule())
            Text(name)
                .font(.pretendard(of: .bold, size: 10))
                .foregroundStyle(Color.blackApp)
            Text(routes)
                .font(.pretendard(of: .regular, size: 8))
                .foregroundStyle(Color.gray700)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.whiteApp)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray200, lineWidth: 1))
    }
    
    private func storeIsolationRow(storeName: String, targetView: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("• \(storeName)")
                .font(.pretendard(of: .bold, size: 12))
                .foregroundStyle(Color.blackApp)
                .frame(width: 115, alignment: .leading)
            Text(targetView)
                .font(.pretendard(of: .regular, size: 12))
                .foregroundStyle(Color.gray700)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
