//
//  CarouselView.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 10/8/26.
//

import SwiftUI

// MARK: - Award Contest Model (From MyWinningView)
public struct MyAwardContest: Identifiable, Equatable, Sendable {
    public var id: Int { contestId }
    public let contestId: Int
    public let contestTitle: String
    public let awardTitle: String
    public let acceptanceSpeech: String
    public let badgeText: String
    public let primaryHex: UInt
    public let secondaryHex: UInt
    public let iconName: String
    
    public static func mockList() -> [MyAwardContest] {
        [
            MyAwardContest(
                contestId: 1,
                contestTitle: "2026 MYKKU 겨울 다꾸 콘테스트",
                awardTitle: "🏆 대상 (1위) 수상작",
                acceptanceSpeech: "“첫 다꾸 콘테스트에서 대상을 받게 되어 정말 행복해요! 함께 응원해 준 마이꾸 덕메들 고마워요 💚”",
                badgeText: "GRAND PRIZE",
                primaryHex: 0x282828,
                secondaryHex: 0x3A3A3A,
                iconName: "crown.fill"
            ),
            MyAwardContest(
                contestId: 2,
                contestTitle: "최애 포토카드 데코 챌린지",
                awardTitle: "🥈 최우수상 수상작",
                acceptanceSpeech: "“네온 그린 테마로 꾸며본 탑로더 데코! 마이꾸 스티커팩 덕분에 완성도가 확 올라갔어요 ✨”",
                badgeText: "EXCELLENCE",
                primaryHex: 0x3C5FC1,
                secondaryHex: 0x618EFF,
                iconName: "sparkles"
            ),
            MyAwardContest(
                contestId: 3,
                contestTitle: "콘서트 티켓북 아카이빙 대전",
                awardTitle: "🥉 인기상 수상작",
                acceptanceSpeech: "“일 년 동안 모은 현장 티켓과 팬노트를 한 권에 정리했어요. 소중한 추억을 기록할 수 있어 뿌듯합니다!”",
                badgeText: "POPULARITY",
                primaryHex: 0xC01D55,
                secondaryHex: 0xFF6DA1,
                iconName: "ticket.fill"
            ),
            MyAwardContest(
                contestId: 4,
                contestTitle: "나만의 굿즈 존(Goods Zone) 자랑대회",
                awardTitle: "🎖️ 특별상 수상작",
                acceptanceSpeech: "“방 한켠의 작은 성지! 조명 배치부터 아크릴 스탠드 각도까지 영혼을 갈아 넣었습니다 🔥”",
                badgeText: "SPECIAL AWARD",
                primaryHex: 0x1C9E1A,
                secondaryHex: 0x53E138,
                iconName: "star.circle.fill"
            )
        ]
    }
}

// MARK: - MYKKU CarouselView
/// 드래그 거리(offset)와 예측 가속도(predictedEndLocation velocity)를 결합한 커스텀 페이징 캐러셀 뷰
/// - 선택된 중앙 아이템은 scale 1.0 / opacity 1.0, 양옆 아이템은 scale 0.84 / opacity 0.6으로 입체감 부여
public struct CarouselView<Item: Identifiable, Content: View>: View {
    
    @Binding public var currentIndex: Int
    @ViewBuilder public var content: (Item) -> Content
    
    @GestureState private var dragOffset: CGFloat = 0
    
    public var items: [Item]
    public var itemWidth: CGFloat
    public var spacing: CGFloat
    
    public init(
        currentIndex: Binding<Int>,
        items: [Item],
        itemWidth: CGFloat,
        spacing: CGFloat,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self._currentIndex = currentIndex
        self.items = items
        self.itemWidth = itemWidth
        self.spacing = spacing
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let screenWidth = proxy.size.width
            let step = itemWidth + spacing
            let initialOffset = (screenWidth - itemWidth) / 2
            let baseOffset = initialOffset - (CGFloat(currentIndex) * step)
            
            HStack(spacing: spacing) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    content(item)
                        .frame(width: itemWidth)
                        .scaleEffect(currentIndex == index ? 1.0 : 0.84)
                        .opacity(currentIndex == index ? 1.0 : 0.6)
                        .zIndex(currentIndex == index ? 10 : 1)
                        .animation(.easeInOut(duration: 0.3), value: currentIndex)
                }
            }
            .offset(x: baseOffset + dragOffset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let offset = value.translation.width
                        let velocity = value.predictedEndLocation.x - value.location.x
                        var newIndex = currentIndex
                        let threshold = itemWidth / 3
                        
                        if offset < -threshold || velocity < -50 {
                            newIndex = min(currentIndex + 1, items.count - 1)
                        } else if offset > threshold || velocity > 50 {
                            newIndex = max(currentIndex - 1, 0)
                        }
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentIndex = newIndex
                        }
                    }
            )
        }
    }
}

// MARK: - MyWinning Carousel Showcase Component (From MyWinningView.swift)
public struct MyWinningCarouselShowcaseView: View {
    @State private var selectedIndex: Int = 0
    private let contests = MyAwardContest.mockList()
    
    private var currentContest: MyAwardContest {
        contests[min(max(selectedIndex, 0), contests.count - 1)]
    }
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .center, spacing: 20) {
            CarouselView(
                currentIndex: $selectedIndex,
                items: contests,
                itemWidth: 210,
                spacing: -6
            ) { contest in
                posterCard(for: contest)
                    .onTapGesture {
                        if let idx = contests.firstIndex(where: { $0.contestId == contest.contestId }) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedIndex = idx
                            }
                        }
                    }
            }
            .frame(height: 276)
            
            // 페이지 인디케이터 도트
            HStack(spacing: 6) {
                ForEach(contests.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == selectedIndex ? Color.blackApp : Color.gray300)
                        .frame(width: index == selectedIndex ? 18 : 6, height: 6)
                        .animation(.spring(response: 0.3), value: selectedIndex)
                }
            }
            
            // 선택된 수상작 정보 (MyWinningView.winningInfo & acceptanceSpeech)
            VStack(alignment: .center, spacing: 6) {
                Text(currentContest.contestTitle)
                    .foregroundStyle(Color.blackApp)
                    .font(.pretendard(of: .bold, size: 16))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(currentContest.awardTitle)
                    .foregroundStyle(Color.gray700)
                    .font(.pretendard(of: .semiBold, size: 13))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
            
            Text(currentContest.acceptanceSpeech)
                .foregroundStyle(Color.blackApp)
                .font(.pretendard(of: .medium, size: 13))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(Color.whiteApp)
                        .shadow(color: Color.blackApp.opacity(0.08), radius: 8, x: 0, y: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray200, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private func posterCard(for contest: MyAwardContest) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: contest.primaryHex), Color(hex: contest.secondaryHex)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green400.opacity(0.6), lineWidth: 1.5)
                )
                .shadow(color: Color.blackApp.opacity(0.2), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(contest.badgeText)
                        .font(.pretendard(of: .bold, size: 11))
                        .foregroundStyle(Color.blackApp)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green400)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Image(systemName: contest.iconName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.green400)
                }
                
                Spacer()
                
                Text(contest.awardTitle)
                    .font(.pretendard(of: .semiBold, size: 12))
                    .foregroundStyle(Color.green200)
                
                Text(contest.contestTitle)
                    .font(.pretendard(of: .bold, size: 16))
                    .foregroundStyle(Color.whiteApp)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
        }
        .frame(width: 210, height: 268)
    }
}
