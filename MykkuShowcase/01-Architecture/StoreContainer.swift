//
//  StoreContainer.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 7/4/26.
//

import SwiftUI

/// 탭 및 기능 도메인별 단방향 Store의 생명주기를 독립적으로 격리하는 전역 컨테이너
/// - 도입 배경: 단일 MainStore가 여러 하위 탭의 상태를 일괄 소유할 때 발생하던 비대화와 불필요한 전파(Over-rendering) 방지
/// - 해결 전략: 각 도메인 Store 인스턴스를 DIContainer 팩토리로부터 주입받아 격리 소유하며,
///   부모 뷰는 필요한 도메인 Store만 구독함으로써 메모리 효율과 모듈 결합도를 최적화
@MainActor
public final class StoreContainer: ObservableObject {
    public let reportStore: ReportStore
    public let communityCommentStore: CommunityCommentStore
    
    public init(diContainer: DIContainer) {
        self.reportStore = diContainer.makeReportStore()
        self.communityCommentStore = diContainer.makeCommunityCommentStore()
    }
}
