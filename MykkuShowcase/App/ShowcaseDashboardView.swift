//
//  ShowcaseDashboardView.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI

// MARK: - Navigation Routes & Sheets
public enum ShowcaseRoute: Hashable {
    case architectureDemo
    case concurrencyDemo
    case uiInteractionsDemo
    case performanceDemo
    case reportDomainDemo(targetId: Int)
}

public enum ShowcaseSheet: Identifiable {
    case reportComment(id: Int)
    
    public var id: String {
        switch self {
        case .reportComment(let id):
            return "report_\(id)"
        }
    }
}

public final class ShowcaseCoordinator: BaseCoordinator<ShowcaseRoute, ShowcaseSheet> {
    public override func shouldHideTabBar(for route: ShowcaseRoute) -> Bool {
        return true
    }
}

// MARK: - Main Dashboard View
public struct ShowcaseDashboardView: View {
    @EnvironmentObject var diContainer: DIContainer
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject private var coordinator = ShowcaseCoordinator()
    @StateObject private var commentStore = CommunityCommentStore()
    @State private var isNetworkGuardLoading = false
    @State private var hasCheckedInitialPermissions = false
    private let permissionManager = PermissionManager()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: coordinator.path) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    heroHeaderCard
                    
                    VStack(spacing: 14) {
                        ShowcaseModuleCard(
                            badgeText: "ARCHITECTURE & HYBRID BRIDGE",
                            icon: "square.stack.3d.up.fill",
                            title: "Clean Architecture · MVI · Hybrid Bridge",
                            subtitle: "StoreContainer 탭별 격리, BaseRepresentable/BaseCollectionView 하이브리드 브릿지, ContentsCommentAdapter 통합 구조를 시각적으로 확인합니다.",
                            tags: ["StoreContainer", "BaseRepresentable", "BaseCollectionView", "CommentAdapter"]
                        ) {
                            coordinator.push(.architectureDemo)
                        }
                        
                        ShowcaseModuleCard(
                            badgeText: "CONCURRENCY & INFRASTRUCTURE",
                            icon: "arrow.triangle.2.circlepath.circle.fill",
                            title: "TokenRefreshProxy · NetworkGuard · Permission",
                            subtitle: "Swift Actor 기반 동시 401 토큰 재발급 직렬화(단 1회 호출 보장), 실시간 오프라인 복구 가드, async/await 미디어 권한 매니저를 시연합니다.",
                            tags: ["actor TokenRefreshProxy", "AuthInterceptor", "NetworkGuard", "PermissionManager"]
                        ) {
                            coordinator.push(.concurrencyDemo)
                        }
                        
                        ShowcaseModuleCard(
                            badgeText: "UI/UX ENGINEERING",
                            icon: "sparkles.rectangle.stack.fill",
                            title: "StickyHeader · WindowAlert · Carousel · FanNote",
                            subtitle: "applyStickyHeader & 방향성 CATransition 달력, 독립 UIWindow 칭호 팝업, 관성 속도 CarouselView, 3분할 제스처 팬노트 뷰어를 체험합니다.",
                            tags: ["applyStickyHeader", "UIWindow(.alert+1)", "CarouselView", "FanNoteViewer"]
                        ) {
                            coordinator.push(.uiInteractionsDemo)
                        }
                        
                        ShowcaseModuleCard(
                            badgeText: "PERFORMANCE & REACTIVE",
                            icon: "bubble.left.and.exclamationmark.bubble.right.fill",
                            title: "Tap 스로틀링 & 댓글 차단·신고 UI",
                            subtitle: "1초 스로틀링이 내장된 UIControl.tapPublisher와 CommentDetailViewController 기반 실시간 댓글/답글, 낙관적 유저 차단 및 신고 로직을 검증합니다.",
                            tags: ["tapPublisher", "CommentDetailVC", "Optimistic Block", "Diffable"]
                        ) {
                            coordinator.push(.performanceDemo)
                        }
                        
                        ShowcaseModuleCard(
                            badgeText: "DOMAIN SAMPLE",
                            icon: "exclamationmark.shield.fill",
                            title: "ReportDomain (전 계층 MVI 샘플)",
                            subtitle: "Entity ➔ UseCase ➔ Repository(Mock/Default) ➔ @MainActor Store ➔ SwiftUI View로 이어지는 신고 도메인 전체 파이프라인입니다.",
                            tags: ["ReportEntity", "ReportUseCase", "ReportStore", "ReportView"]
                        ) {
                            coordinator.push(.reportDomainDemo(targetId: 1024))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 36)
            }
            .background(Color.gray50.ignoresSafeArea())
            .navigationTitle("MYKKU Showcase")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ShowcaseRoute.self) { route in
                switch route {
                case .architectureDemo:
                    ArchitectureBlueprintView()
                case .concurrencyDemo:
                    ConcurrencyDemoView()
                case .uiInteractionsDemo:
                    UIInteractionsDemoView(coordinator: coordinator)
                case .performanceDemo:
                    PerformanceDemoView(
                        commentStore: commentStore,
                        onReportComment: { commentId in
                            coordinator.presentSheet(.reportComment(id: commentId))
                        }
                    )
                case .reportDomainDemo(let targetId):
                    ReportView(
                        type: .feed,
                        id: targetId,
                        store: diContainer.makeReportStore()
                    )
                }
            }
            .sheet(item: $coordinator.sheet) { sheet in
                switch sheet {
                case .reportComment(let commentId):
                    NavigationStack {
                        ReportView(
                            type: .feedComment,
                            id: commentId,
                            store: diContainer.makeReportStore()
                        )
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("닫기") {
                                    coordinator.dismissSheet()
                                }
                                .font(.pretendard(of: .medium, size: 14))
                                .foregroundStyle(Color.blackApp)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            guard !hasCheckedInitialPermissions else { return }
            hasCheckedInitialPermissions = true
            Task {
                await permissionManager.checkInitialPermissions()
            }
        }
        .networkGuard($isNetworkGuardLoading)
        .preferredColorScheme(.light)
    }
    
    private var heroHeaderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text("MYKKU CORE PORTFOLIO")
                    .font(.pretendard(of: .bold, size: 11))
                    .foregroundStyle(Color.blackApp)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green400)
                    .clipShape(Capsule())
                
                Text("iOS 16.0+ | Swift 5")
                    .font(.pretendard(of: .semiBold, size: 11))
                    .foregroundStyle(Color.green200)
                
                Spacer()
            }
            
            Text("마이꾸(MYKKU)\n핵심 기술 쇼케이스")
                .font(.pretendard(of: .extraBold, size: 21))
                .foregroundStyle(Color.whiteApp)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("MYKKU App의 코어 아키텍처, 동시성 토큰 제어, 커스텀 인터랙션 컴포넌트를 추출한 실행형 프로젝트입니다.")
                .font(.pretendard(of: .regular, size: 13))
                .foregroundStyle(Color.gray200)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.blackApp)
                .shadow(color: Color.blackApp.opacity(0.15), radius: 12, x: 0, y: 6)
        )
    }
}
