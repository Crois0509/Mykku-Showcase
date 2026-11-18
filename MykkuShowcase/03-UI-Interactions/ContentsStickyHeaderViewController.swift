//
//  ContentsStickyHeaderViewController.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 10/23/25.
//

import UIKit
import SwiftUI
import Combine

// MARK: - Calendar Domain Model (From CalendarDay.swift)
public enum CalendarViewType: Hashable, Sendable {
    case week
    case month
}

public struct CalendarDay: Hashable, Sendable {
    public let id = UUID()
    public let date: Date
    public let event: String
    public let isCurrentMonth: Bool
    
    public init(date: Date, event: String, isCurrentMonth: Bool = true) {
        self.date = date
        self.event = event
        self.isCurrentMonth = isCurrentMonth
    }
}

// MARK: - ContentsLogoHeaderView (From ContentsLogoHeaderView.swift)
public final class ContentsLogoHeaderView: UIView {
    private let logoBadge = UILabel(style: .custom(.black, 20, .blackApp))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .whiteApp
        translatesAutoresizingMaskIntoConstraints = false
        
        logoBadge.text = "MYKKU"
        
        addSubview(logoBadge)
        NSLayoutConstraint.activate([
            logoBadge.leadingAnchor.constraint(equalTo: leadingAnchor),
            logoBadge.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

// MARK: - MoreButtonTitleView (From MoreButtonTitleView.swift)
public final class MoreButtonTitleView: UIView {
    public var moreButtonTapped: (() -> Void)?
    
    private let titleView = UILabel(style: .custom(.bold, 17, .blackApp))
    private let moreButton = UIButton(type: .system)
    
    public init(title: String? = nil) {
        super.init(frame: .zero)
        titleView.setupParagraphStyleText(title ?? " ")
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        titleView.numberOfLines = 1
        
        moreButton.setTitle("더보기", for: .normal)
        moreButton.setTitleColor(.gray600, for: .normal)
        moreButton.titleLabel?.font = .pretendard(of: .medium, size: 13)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.addAction(UIAction { [weak self] _ in
            self?.moreButtonTapped?()
        }, for: .touchUpInside)
        
        addSubviews(titleView, moreButton)
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            titleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            moreButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: - ContentsCalendarCell (From ContentsCalendarCell.swift)
public final class ContentsCalendarCell: UICollectionViewCell {
    private enum CalendarUIStyle {
        case normalDay(Bool)
        case eventDay(Bool)
        case today
    }
    
    public var doNotApplySelectedUI: Bool = false
    private var cellDate: Date = Date()
    
    private let dayLabel = UILabel(style: .custom(.bold, 13, .blackApp))
    private let eventLabel = UILabel(style: .custom(.medium, 11, .gray700))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        dayLabel.layoutIfNeeded()
        dayLabel.layer.cornerRadius = 16
    }
    
    public func configCell(_ data: CalendarDay) {
        cellDate = data.date
        let isToday = Calendar.current.isDateInToday(data.date)
        let isCurrentMonth = data.isCurrentMonth
        let day = Calendar.current.component(.day, from: data.date)
        
        updateUI(for: isToday ? .today : data.event.isEmpty ? .normalDay(isCurrentMonth) : .eventDay(isCurrentMonth))
        eventLabel.text = data.event.isEmpty ? " " : data.event
        eventLabel.isHidden = data.event.isEmpty
        dayLabel.text = "\(day)"
    }
    
    private func setupUI() {
        backgroundColor = .clear
        dayLabel.numberOfLines = 1
        dayLabel.textAlignment = .center
        dayLabel.clipsToBounds = true
        
        eventLabel.numberOfLines = 1
        eventLabel.textAlignment = .center
        
        contentView.addSubviews(dayLabel, eventLabel)
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.widthAnchor.constraint(equalToConstant: 32),
            dayLabel.heightAnchor.constraint(equalToConstant: 32),
            
            eventLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 3),
            eventLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            eventLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            eventLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    private func updateUI(for style: CalendarUIStyle) {
        switch style {
        case .normalDay(let isCurrentMonth):
            dayLabel.textColor = isCurrentMonth ? .blackApp : .gray400
            dayLabel.backgroundColor = .clear
        case .eventDay(let isCurrentMonth):
            dayLabel.textColor = isCurrentMonth ? .pink600 : .pink600.withAlphaComponent(0.5)
            dayLabel.backgroundColor = isCurrentMonth ? .pink50 : .pink50.withAlphaComponent(0.5)
        case .today:
            dayLabel.textColor = .blackApp
            dayLabel.backgroundColor = .green400
        }
    }
}

// MARK: - WeekCalendarView (From WeekCalendarView.swift & EventCalendarViewController.swift)
public final class WeekCalendarView: UIView {
    private let titleLabel = UILabel(style: .custom(.bold, 16, .blackApp))
    private let prevWeekButton = UIButton(type: .system)
    private let nextWeekButton = UIButton(type: .system)
    private let dayOfWeekStack = UIStackView()
    private(set) lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private var dataSource: UICollectionViewDiffableDataSource<CalendarViewType, CalendarDay>!
    private var baseDate: Date = Date()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupDataSource()
        addSwipeGestureRecognizers()
        loadSampleWeekEvents(for: baseDate)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .whiteApp
        translatesAutoresizingMaskIntoConstraints = false
        
        prevWeekButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevWeekButton.tintColor = .blackApp
        prevWeekButton.translatesAutoresizingMaskIntoConstraints = false
        prevWeekButton.addAction(UIAction { [weak self] _ in
            self?.moveWeek(by: -1)
        }, for: .touchUpInside)
        
        nextWeekButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextWeekButton.tintColor = .blackApp
        nextWeekButton.translatesAutoresizingMaskIntoConstraints = false
        nextWeekButton.addAction(UIAction { [weak self] _ in
            self?.moveWeek(by: 1)
        }, for: .touchUpInside)
        
        dayOfWeekStack.axis = .horizontal
        dayOfWeekStack.distribution = .fillEqually
        dayOfWeekStack.translatesAutoresizingMaskIntoConstraints = false
        
        let days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        for day in days {
            let label = UILabel(style: .custom(.semiBold, 11, .blackApp))
            label.text = day
            label.textAlignment = .center
            if day == "SUN" { label.textColor = .red500 }
            else if day == "SAT" { label.textColor = .blue600 }
            dayOfWeekStack.addArrangedSubview(label)
        }
        
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ContentsCalendarCell.self)
        
        addSubviews(titleLabel, prevWeekButton, nextWeekButton, dayOfWeekStack, collectionView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            nextWeekButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            nextWeekButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            nextWeekButton.widthAnchor.constraint(equalToConstant: 28),
            nextWeekButton.heightAnchor.constraint(equalToConstant: 28),
            
            prevWeekButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            prevWeekButton.trailingAnchor.constraint(equalTo: nextWeekButton.leadingAnchor, constant: -4),
            prevWeekButton.widthAnchor.constraint(equalToConstant: 28),
            prevWeekButton.heightAnchor.constraint(equalToConstant: 28),
            
            dayOfWeekStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dayOfWeekStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayOfWeekStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            dayOfWeekStack.heightAnchor.constraint(equalToConstant: 20),
            
            collectionView.topAnchor.constraint(equalTo: dayOfWeekStack.bottomAnchor, constant: 2),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func addSwipeGestureRecognizers() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe))
        leftSwipe.direction = .left
        addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
        rightSwipe.direction = .right
        addGestureRecognizer(rightSwipe)
    }
    
    @objc private func handleLeftSwipe() { moveWeek(by: 1) }
    @objc private func handleRightSwipe() { moveWeek(by: -1) }
    
    /// EventCalendarViewController의 방향성 CATransition 푸시 애니메이션 적용
    public func moveWeek(by value: Int) {
        guard let newDate = Calendar.current.date(byAdding: .weekOfYear, value: value, to: baseDate) else { return }
        baseDate = newDate
        
        let transition = CATransition()
        transition.type = .push
        transition.subtype = value > 0 ? .fromRight : .fromLeft
        transition.duration = 0.28
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        collectionView.layer.add(transition, forKey: "calendar_slide")
        
        loadSampleWeekEvents(for: newDate)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 7.0), heightDimension: .absolute(62))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(62))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupDataSource() {
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(ContentsCalendarCell.self, for: indexPath)
            cell.configCell(item)
            cell.doNotApplySelectedUI = true
            return cell
        }
    }
    
    public func loadSampleWeekEvents(for targetDate: Date) {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: targetDate) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        let weekOfMonth = calendar.component(.weekOfMonth, from: targetDate)
        titleLabel.text = "이번주의 소식 (\(formatter.string(from: targetDate)) \(weekOfMonth)주차)"
        
        var weekItems: [CalendarDay] = []
        let sampleLabels = [1: "팬미팅", 3: "굿즈오픈", 5: "콘테스트", 6: "생일카페"]
        for offset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: offset, to: weekInterval.start) {
                let isToday = calendar.isDateInToday(date)
                let label = isToday ? "오늘" : (sampleLabels[offset] ?? "")
                weekItems.append(CalendarDay(date: date, event: label, isCurrentMonth: true))
            }
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<CalendarViewType, CalendarDay>()
        snapshot.appendSections([.week])
        snapshot.appendItems(weekItems, toSection: .week)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - ContentsSummaryHeaderView (From ContentsSummaryHeaderView.swift)
public final class ContentsSummaryHeaderView: UIView {
    public var changePage: ((Int) -> Void)?
    public var currentIndex: Int = 0 {
        didSet {
            updateSelectTitle()
            updateIndicatorFrame()
        }
    }
    
    private let segmentTitles: [String]
    private var indicatorLeadingConstraint: NSLayoutConstraint?
    private var indicatorWidthConstraint: NSLayoutConstraint?
    
    private let indicatorBgView = UIView()
    private let indicator = UIView()
    private let segmentView = UIStackView()
    
    public init(segments: [String]) {
        self.segmentTitles = segments
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard !segmentTitles.isEmpty else { return }
        let width = bounds.width / CGFloat(segmentTitles.count)
        indicatorWidthConstraint?.constant = width
        indicatorLeadingConstraint?.constant = width * CGFloat(currentIndex)
    }
    
    private func setupUI() {
        backgroundColor = .whiteApp
        translatesAutoresizingMaskIntoConstraints = false
        
        segmentView.axis = .horizontal
        segmentView.distribution = .fillEqually
        segmentView.translatesAutoresizingMaskIntoConstraints = false
        
        for (idx, title) in segmentTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .pretendard(of: idx == 0 ? .bold : .medium, size: 14)
            button.setTitleColor(idx == 0 ? .blackApp : .gray400, for: .normal)
            button.tag = idx
            button.addAction(UIAction { [weak self] _ in
                self?.currentIndex = idx
                self?.changePage?(idx)
            }, for: .touchUpInside)
            segmentView.addArrangedSubview(button)
        }
        
        indicatorBgView.backgroundColor = .gray200
        indicatorBgView.translatesAutoresizingMaskIntoConstraints = false
        
        indicator.backgroundColor = .green400
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(segmentView, indicatorBgView, indicator)
        
        let leading = indicator.leadingAnchor.constraint(equalTo: indicatorBgView.leadingAnchor)
        let width = indicator.widthAnchor.constraint(equalToConstant: 100)
        indicatorLeadingConstraint = leading
        indicatorWidthConstraint = width
        
        NSLayoutConstraint.activate([
            segmentView.topAnchor.constraint(equalTo: topAnchor),
            segmentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentView.heightAnchor.constraint(equalToConstant: 40),
            
            indicatorBgView.topAnchor.constraint(equalTo: segmentView.bottomAnchor),
            indicatorBgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            indicatorBgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            indicatorBgView.bottomAnchor.constraint(equalTo: bottomAnchor),
            indicatorBgView.heightAnchor.constraint(equalToConstant: 3),
            
            leading,
            width,
            indicator.topAnchor.constraint(equalTo: indicatorBgView.topAnchor),
            indicator.bottomAnchor.constraint(equalTo: indicatorBgView.bottomAnchor)
        ])
    }
    
    private func updateIndicatorFrame() {
        guard !segmentTitles.isEmpty else { return }
        let width = bounds.width / CGFloat(segmentTitles.count)
        indicatorLeadingConstraint?.constant = width * CGFloat(currentIndex)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.layoutIfNeeded()
        }
    }
    
    private func updateSelectTitle() {
        for (idx, view) in segmentView.arrangedSubviews.compactMap({ $0 as? UIButton }).enumerated() {
            view.titleLabel?.font = .pretendard(of: idx == currentIndex ? .bold : .medium, size: 14)
            view.setTitleColor(idx == currentIndex ? .blackApp : .gray400, for: .normal)
        }
    }
}

// MARK: - Feed Item Cell for Sticky Header Scroll Demo
private struct StickyDemoItem: Hashable {
    let id = UUID()
    let category: String
    let title: String
    let subtitle: String
    let dateText: String
    let badgeColorHex: UInt
}

private final class StickyDemoItemCell: UICollectionViewCell {
    private let badgeLabel = UILabel(style: .custom(.bold, 11, .blackApp))
    private let titleLabel = UILabel(style: .custom(.bold, 15, .blackApp))
    private let subtitleLabel = UILabel(style: .custom(.regular, 13, .gray700))
    private let dateLabel = UILabel(style: .custom(.medium, 11, .gray500))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .gray50
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.gray200.cgColor
        
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.clipsToBounds = true
        
        titleLabel.numberOfLines = 2
        subtitleLabel.numberOfLines = 2
        
        contentView.addSubviews(badgeLabel, dateLabel, titleLabel, subtitleLabel)
        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            badgeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            badgeLabel.heightAnchor.constraint(equalToConstant: 22),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
            
            dateLabel.centerYAnchor.constraint(equalTo: badgeLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: badgeLabel.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -14)
        ])
    }
    
    func configure(_ item: StickyDemoItem) {
        badgeLabel.text = "\(item.category)"
        badgeLabel.backgroundColor = UIColor(hex: item.badgeColorHex)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        dateLabel.text = item.dateText
    }
}

// MARK: - ContentsViewController Sticky Header Implementation
/// MYKKU의 `ContentsViewController`에서 스크롤 비율(`scrollRatio`)에 따라 `calendarView`를 숨기고
/// `summaryHeader`를 상단에 고정하는 Sticky Header 컨트롤러 (`applyStickyHeader(_:)` 그대로 적용)
public final class ContentsStickyHeaderViewController: UIViewController, UICollectionViewDelegate {
    
    @Published public private(set) var currentScrollRatio: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()
    private let calendarViewHeight: CGFloat = 128
    private var calendarTopConstraint: NSLayoutConstraint?
    public var onScrollRatioChanged: ((CGFloat) -> Void)?
    
    private let contentsHeaderView = ContentsLogoHeaderView()
    private let calendarView = WeekCalendarView()
    private let summaryHeader = ContentsSummaryHeaderView(segments: ["덕질공부", "이벤트", "콘테스트"])
    private lazy var contentCollectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(114))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(114))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 28, trailing: 20)
        let layout = UICollectionViewCompositionalLayout(section: section)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .whiteApp
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        return cv
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, StickyDemoItem>!
    private var currentSegment: Int = 0
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSource()
        bind()
        reloadSegmentItems(for: 0)
    }
    
    private func setupUI() {
        view.backgroundColor = .whiteApp
        view.clipsToBounds = true
        
        view.addSubviews(calendarView, contentsHeaderView, summaryHeader, contentCollectionView)
        
        let calTop = calendarView.topAnchor.constraint(equalTo: contentsHeaderView.bottomAnchor)
        self.calendarTopConstraint = calTop
        
        NSLayoutConstraint.activate([
            contentsHeaderView.topAnchor.constraint(equalTo: view.topAnchor),
            contentsHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentsHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentsHeaderView.heightAnchor.constraint(equalToConstant: 52),
            
            calTop,
            calendarView.leadingAnchor.constraint(equalTo: contentsHeaderView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: contentsHeaderView.trailingAnchor),
            calendarView.heightAnchor.constraint(equalToConstant: calendarViewHeight),
            
            summaryHeader.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 4),
            summaryHeader.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
            summaryHeader.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor),
            summaryHeader.heightAnchor.constraint(equalToConstant: 43),
            
            contentCollectionView.topAnchor.constraint(equalTo: summaryHeader.bottomAnchor, constant: 4),
            contentCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 캘린더가 위로 접힐 때 로고 헤더 뒤로 자연스럽게 들어가도록 Z-Order 설정
        view.bringSubviewToFront(contentsHeaderView)
        
        summaryHeader.changePage = { [weak self] index in
            self?.currentSegment = index
            self?.reloadSegmentItems(for: index)
        }
    }
    
    /// 원본 `ContentsViewController.applyStickyHeader(_:)` 핵심 로직
    public func applyStickyHeader(_ scrollRatio: CGFloat) {
        let referenceRatio = 1.0 - scrollRatio
        let newCalendarHeight = -(calendarViewHeight * scrollRatio)
        let hideHeight = -(calendarViewHeight + 2)
        
        if scrollRatio >= 0.8 {
            calendarView.alpha = 0
            calendarTopConstraint?.constant = hideHeight
        } else if scrollRatio <= 0.1 {
            calendarView.alpha = 1.0
            calendarTopConstraint?.constant = 0
        } else {
            calendarView.alpha = referenceRatio
            calendarTopConstraint?.constant = newCalendarHeight
        }
        onScrollRatioChanged?(scrollRatio)
    }
    
    private func bind() {
        $currentScrollRatio
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ratio in
                self?.applyStickyHeader(ratio)
            }
            .store(in: &cancellables)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollSize = max(scrollView.contentSize.height - scrollView.bounds.height, 128)
        let rawOffset = max(0, scrollView.contentOffset.y)
        let scrollRatio = rawOffset / min(scrollSize, 128)
        currentScrollRatio = min(max(scrollRatio, 0.0), 1.0)
    }
    
    private func setupDataSource() {
        contentCollectionView.register(StickyDemoItemCell.self)
        dataSource = .init(collectionView: contentCollectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(StickyDemoItemCell.self, for: indexPath)
            cell.configure(item)
            return cell
        }
    }
    
    private func reloadSegmentItems(for segment: Int) {
        let items: [StickyDemoItem]
        switch segment {
        case 0:
            items = [
                StickyDemoItem(category: "팬노트 #1", title: "입덕 필수 가이드: 세계관 & 응원법 총정리", subtitle: "아래로 스크롤하면 주간 달력(WeekCalendarView)이 부드럽게 접힙니다.", dateText: "2026.11.18", badgeColorHex: 0x8CFF58),
                StickyDemoItem(category: "하루덕담", title: "오늘도 최애와 함께 행복한 하루 보내세요 💚", subtitle: "scrollRatio >= 0.8 시점에 캘린더가 완전히 숨겨지고 탭 헤더가 고정됩니다.", dateText: "실시간", badgeColorHex: 0xBCFF88),
                StickyDemoItem(category: "팬노트 #2", title: "콘서트 티켓팅 성공을 위한 사전 체크리스트", subtitle: "본인 인증부터 예매처별 서버 시계 확인 팁까지 한눈에 보기", dateText: "2026.11.16", badgeColorHex: 0x8CFF58),
                StickyDemoItem(category: "팬노트 #3", title: "포토카드 보관 & 바인더 속지 고르는 법", subtitle: "변색 없는 PP/PVC 프리 속지 비교 분석 노트", dateText: "2026.11.14", badgeColorHex: 0x8CFF58),
                StickyDemoItem(category: "팬노트 #4", title: "생일 카페 투어 코스 짜는 꿀팁 모음", subtitle: "홍대·성수 동선 최적화 및 럭키드로우 보관 노하우", dateText: "2026.11.10", badgeColorHex: 0x8CFF58),
                StickyDemoItem(category: "팬노트 #5", title: "나만의 예쁜 예절샷 촬영 구도 레퍼런스", subtitle: "인형과 포토카드가 모두 선명하게 나오는 초점 맞추기 팁", dateText: "2026.11.05", badgeColorHex: 0x8CFF58)
            ]
        case 1:
            items = [
                StickyDemoItem(category: "진행중", title: "2026 겨울 시즌 그리팅 언박싱 인증 이벤트", subtitle: "커뮤니티에 후기를 남기면 추첨을 통해 스페셜 폴라로이드 증정", dateText: "D-5", badgeColorHex: 0xFFA1C1),
                StickyDemoItem(category: "진행중", title: "하루덕담 7일 연속 출석 챌린지", subtitle: "한정판 '성실한 덕후' 칭호를 획득할 수 있는 찬스!", dateText: "D-12", badgeColorHex: 0xFFA1C1),
                StickyDemoItem(category: "오픈예정", title: "연말 가요대전 현장 응원 슬로건 배포", subtitle: "현장 인증 부스 위치 및 수령 시간 안내", dateText: "12월 예정", badgeColorHex: 0xDDE7FF),
                StickyDemoItem(category: "종료", title: "가을 소풍 컨셉 포토카드 프레임 증정 이벤트", subtitle: "총 1,420명의 마이꾸 유저가 참여했어요!", dateText: "종료됨", badgeColorHex: 0xE8E8E8),
                StickyDemoItem(category: "종료", title: "여름 여행 컨셉 포토카드 프레임 증정 이벤트", subtitle: "총 1,021명의 마이꾸 유저가 참여했어요!", dateText: "종료됨", badgeColorHex: 0xE8E8E8),
                StickyDemoItem(category: "종료", title: "봄 새학기 컨셉 포토카드 프레임 증정 이벤트", subtitle: "총 2,100명의 마이꾸 유저가 참여했어요!", dateText: "종료됨", badgeColorHex: 0xE8E8E8)
            ]
        default:
            items = [
                StickyDemoItem(category: "콘테스트", title: "제 4회 MYKKU 탑로더 데코 콘테스트", subtitle: "네온 그린 & 화이트 테마로 나만의 탑로더를 꾸며보세요!", dateText: "심사중", badgeColorHex: 0x9ABEFF),
                StickyDemoItem(category: "수상발표", title: "2026 팬아트 일러스트 어워즈 수상작 공개", subtitle: "대상·최우수상·인기상 수상작을 아카이브에서 만나보세요.", dateText: "발표완료", badgeColorHex: 0x8CFF58),
                StickyDemoItem(category: "콘테스트", title: "콘서트 티켓북 & 다꾸 다이어리 자랑 대회", subtitle: "가장 감각적인 아카이빙 노트를 선정합니다.", dateText: "모집중", badgeColorHex: 0x9ABEFF),
                StickyDemoItem(category: "콘테스트", title: "최애 생일 기념 미니 케이크 디자인 공모", subtitle: "우승 디자인은 실제 생일 카페 특전으로 제작됩니다.", dateText: "모집중", badgeColorHex: 0x9ABEFF),
                StickyDemoItem(category: "콘테스트", title: "제 3회 MYKKU 탑로더 데코 콘테스트", subtitle: "코랄 핑크 & 화이트 테마로 나만의 탑로더를 꾸며보세요!", dateText: "발표완료", badgeColorHex: 0x8CFF58),
                StickyDemoItem(category: "콘테스트", title: "최고의 팬을 찾아라! 콘테스트", subtitle: "여러분이 각 분야의 최고의 팬임을 증명해 주세요!", dateText: "발표완료", badgeColorHex: 0x8CFF58)
            ]
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, StickyDemoItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - SwiftUI Wrapper for ContentsStickyHeaderViewController
public struct ContentsStickyHeaderRepresentable: UIViewControllerRepresentable {
    @Binding public var scrollRatio: CGFloat
    
    public init(scrollRatio: Binding<CGFloat>) {
        self._scrollRatio = scrollRatio
    }
    
    public func makeUIViewController(context: Context) -> ContentsStickyHeaderViewController {
        let vc = ContentsStickyHeaderViewController()
        vc.onScrollRatioChanged = { ratio in
            DispatchQueue.main.async {
                self.scrollRatio = ratio
            }
        }
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: ContentsStickyHeaderViewController, context: Context) {}
}
