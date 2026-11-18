//
//  BaseCollectionView.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 11/27/25.
//

import UIKit

/// 앱 전역의 CompositionalLayout 팩토리 메서드를 내장하고 스크롤/키보드 해제 옵션을 표준화한 베이스 컬렉션뷰
open class BaseCollectionView: UICollectionView {
    
    public init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        automaticallyAdjustsScrollIndicatorInsets = false
        contentInsetAdjustmentBehavior = .never
        contentInset.bottom = 20
        keyboardDismissMode = .onDrag
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 공용 CompositionalLayout Factory Methods
public extension BaseCollectionView {
    
    /// 중앙 페이징 캐러셀(`groupPagingCentered`) 레이아웃 생성
    func createCaroucelLayout(viewWidth: CGFloat) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let fractionalWidth = 231 / max(viewWidth, 1)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(fractionalWidth),
            heightDimension: .absolute(327)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 1
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = -7
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    
    /// 기본 수직 리스트 섹션 레이아웃
    func defaultVerticalListLayout(absoluteGroup size: CGFloat = 160) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(size)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        return NSCollectionLayoutSection(group: group)
    }
    
    /// 공용 Section Header 레이아웃 (absolute 높이)
    func createSectionHeaderLayout(absoluteHeight size: CGFloat) -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(size)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading
        )
    }
    
    /// 공용 Section Header 레이아웃 (estimated 동적 높이)
    func createSectionHeaderLayout(estimatedHeight size: CGFloat) -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(size)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading
        )
    }
    
    /// 아이템이 비었을 때 높이가 동적으로 변하는 Empty Footer 레이아웃
    func createEmptyFooterLayout(itemCount: Int) -> NSCollectionLayoutBoundarySupplementaryItem {
        let footerHeight: CGFloat = itemCount == 0 ? 180 : 0.1
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(footerHeight)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
    }
    
    /// 댓글/답글용 동적 높이(`estimated`) 레이아웃
    var commentLayout: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 6
        return section
    }
    
    /// 3열 포스터 그리드 레이아웃
    var compactStandardGridLayout: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(140)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3)
        group.interItemSpacing = .fixed(12)
        return NSCollectionLayoutSection(group: group)
    }
}
