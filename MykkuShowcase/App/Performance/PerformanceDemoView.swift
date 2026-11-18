//
//  PerformanceDemoView.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI
import Combine

/// 1번: UIControl.tapPublisher (1초 스로틀링 내장 Combine 탭 스트림)
/// 2번: CommentDetailViewController 기반 댓글 목록 UI + 낙관적 유저 차단 & 신고 로직
struct PerformanceDemoView: View {
    @ObservedObject var commentStore: CommunityCommentStore
    let onReportComment: (Int) -> Void
    
    @State private var throttledTapCount = 0
    @State private var lastAcceptedTimeText = "아직 탭하지 않음"
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. 상단 UIControl.tapPublisher 1초 스로틀링 섹션
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("1. UIControl.tapPublisher")
                        .font(.pretendard(of: .bold, size: 14))
                        .foregroundStyle(Color.blackApp)
                    Spacer()
                    Text("유효 실행: \(throttledTapCount)회")
                        .font(.pretendard(of: .bold, size: 12))
                        .foregroundStyle(Color.blackApp)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.gray100)
                        .clipShape(Capsule())
                }
                
                ThrottledUIButtonRepresentable {
                    throttledTapCount += 1
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm:ss.SSS"
                    lastAcceptedTimeText = "마지막 통과 시각: \(formatter.string(from: Date()))"
                }
                .frame(height: 44)
                
                Text(lastAcceptedTimeText)
                    .font(.pretendard(of: .medium, size: 11))
                    .foregroundStyle(Color.gray600)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.whiteApp)
            
            Divider()
            
            // 2. 하단 CommentDetailViewController (댓글 목록 + 유저 차단 & 신고)
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("2. CommentDetailViewController")
                            .font(.pretendard(of: .bold, size: 14))
                            .foregroundStyle(Color.blackApp)
                        Text("우측 ••• 버튼(또는 길게 누르기)으로 차단하기·신고하기·수정·삭제를 실행해 보세요.")
                            .font(.pretendard(of: .regular, size: 11))
                            .foregroundStyle(Color.gray600)
                    }
                    Spacer()
                    if !commentStore.blockedMemberIds.isEmpty {
                        Button("차단 해제(\(commentStore.blockedMemberIds.count))") {
                            commentStore.resetSampleData()
                        }
                        .font(.pretendard(of: .bold, size: 11))
                        .foregroundStyle(Color.whiteApp)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red500)
                        .clipShape(Capsule())
                    } else {
                        Button("목록 초기화") {
                            commentStore.resetSampleData()
                        }
                        .font(.pretendard(of: .semiBold, size: 11))
                        .foregroundStyle(Color.gray700)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.gray100)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color.green50)
                
                CommunityCommentDetailView(
                    store: commentStore,
                    pushContentReport: { _, commentId in
                        onReportComment(commentId)
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Performance & Reactive")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ThrottledUIButtonRepresentable: UIViewRepresentable {
    let onTap: () -> Void
    
    func makeUIView(context: Context) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(
            "빠르게 연타해 보세요! (1.0초 스로틀링 적용 버튼)",
            attributes: AttributeContainer([
                .font: UIFont.pretendard(of: .bold, size: 13),
                .foregroundColor: UIColor.blackApp
            ])
        )
        config.baseBackgroundColor = .green400
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        
        button.tapPublisher
            .sink {
                onTap()
            }
            .store(in: &context.coordinator.cancellables)
        
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    final class Coordinator {
        var cancellables = Set<AnyCancellable>()
    }
}
