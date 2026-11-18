//
//  FanNoteViewerViewController.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 11/9/25.
//

import UIKit
import SwiftUI
import Combine

// MARK: - FanNote Page Model
public struct FanNotePageItem: Equatable, Sendable {
    public let pageNumber: Int
    public let totalPages: Int
    public let badge: String
    public let title: String
    public let body: String
    public let tipText: String
    public let themeHex: UInt
    
    public static func samplePages() -> [FanNotePageItem] {
        [
            FanNotePageItem(
                pageNumber: 1,
                totalPages: 4,
                badge: "CHAPTER 01 · 세계관 입문",
                title: "입덕 필수 가이드:\n공식 응원법 & 팬덤 용어 사전",
                body: "화면 좌측 1/3을 탭하거나 우측으로 스와이프하면 이전 페이지로,\n우측 1/3을 탭하거나 좌측으로 스와이프하면 다음 페이지로 이동합니다.\n\n화면 중앙 1/3 영역을 탭하면 상단 툴바가 나타나며, 3초간 조작이 없으면 타이머에 의해 자동으로 숨겨집니다.",
                tipText: "💡 첫 페이지에서 좌측 1/3을 탭하면 VCToastView('첫 페이지입니다.')가 표시됩니다.",
                themeHex: 0x282828
            ),
            FanNotePageItem(
                pageNumber: 2,
                totalPages: 4,
                badge: "CHAPTER 02 · 오프라인 준비",
                title: "콘서트 티켓팅 & 현장 부스\n100% 즐기는 실전 체크리스트",
                body: "1. 예매처 본인 인증 및 배송지 사전 등록 확인\n2. 공식 응원봉 최신 펌웨어 업데이트 및 건전지 여유분 준비\n3. 팬클럽 부스(M-Zone) 인증용 신분증·모바일 티켓·공식 키트 지참",
                tipText: "💡 중앙 영역을 탭하여 상단 툴바(북마크·공유)를 호출해 보세요!",
                themeHex: 0x3C5FC1
            ),
            FanNotePageItem(
                pageNumber: 3,
                totalPages: 4,
                badge: "CHAPTER 03 · 굿즈 아카이빙",
                title: "변색 없는 포토카드 보관법 &\n바인더 속지 선택 노하우",
                body: "• PVC 소재는 장기간 보관 시 유분기가 올라와 포토카드 인쇄면에 손상을 줄 수 있습니다.\n• 반드시 산성 성분이 없는 PP(폴리프로필렌) 소재의 고투명 슬리브를 이중으로 체결한 뒤 바인더에 보관하세요.",
                tipText: "💡 좌우 스와이프 제스처로도 페이지를 부드럽게 넘길 수 있습니다.",
                themeHex: 0xC01D55
            ),
            FanNotePageItem(
                pageNumber: 4,
                totalPages: 4,
                badge: "CHAPTER 04 · 다꾸 레퍼런스",
                title: "네온 그린 & 하이틴 무드\n탑로더 데코 레이아웃 공식",
                body: "인물의 시선이 향하는 대각선 모서리에 포인트 리본 스티커를 배치하고, 테두리 라인은 작은 별/하트 파츠로 리듬감을 주면 실패 없는 구도가 완성됩니다.",
                tipText: "💡 마지막 페이지에서 우측 1/3을 탭하면 '마지막 페이지입니다.' 토스트가 나타납니다.",
                themeHex: 0x1C9E1A
            )
        ]
    }
}

// MARK: - FanNoteViewerToolBar (From FanNoteViewerToolBar.swift)
public final class FanNoteViewerToolBar: UIView {
    public enum ToolBarTap: Equatable {
        case back
        case bookmark
        case share
    }
    
    private let titleLabel = UILabel(style: .custom(.bold, 15, .whiteApp))
    private let bookmarkButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private var isBookmarked = false
    
    public var onAction: ((ToolBarTap) -> Void)?
    
    public init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.blackApp.withAlphaComponent(0.88)
        layer.cornerRadius = 14
        translatesAutoresizingMaskIntoConstraints = false
        
        bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        bookmarkButton.tintColor = .green400
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        bookmarkButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.isBookmarked.toggle()
            let icon = self.isBookmarked ? "bookmark.fill" : "bookmark"
            self.bookmarkButton.setImage(UIImage(systemName: icon), for: .normal)
            self.onAction?(.bookmark)
        }, for: .touchUpInside)
        
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .whiteApp
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addAction(UIAction { [weak self] _ in
            self?.onAction?(.share)
        }, for: .touchUpInside)
        
        addSubviews(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

// MARK: - FanNoteViewerViewController (From FanNoteViewerViewController.swift)
/// 몰입형 3분할 제스처 및 3초 자동 숨김 타이머 툴바가 탑재된 팬노트 이북(e-Book) 뷰어
/// - 좌측 1/3 탭 또는 우측 스와이프: 이전 페이지 이동 (첫 페이지 시 `VCToastView` 노출)
/// - 우측 1/3 탭 또는 좌측 스와이프: 다음 페이지 이동 (마지막 페이지 시 `VCToastView` 노출)
/// - 중앙 1/3 탭: 상단 툴바(`FanNoteViewerToolBar`) 페이드인/아웃 토글 및 3.0초 후 `Timer` 자동 숨김
public final class FanNoteViewerViewController: BaseViewController {
    
    private let pages = FanNotePageItem.samplePages()
    private var currentImageIndex: Int = 0
    
    private var hideTimer: Timer?
    private let displayDuration: TimeInterval = 3.0
    
    private var previousTapPoint: CGFloat { view.bounds.width / 3.0 }
    private var nextTapPoint: CGFloat { (view.bounds.width / 3.0) * 2.0 }
    
    private let pageCardView = UIView()
    private let badgeLabel = UILabel(style: .custom(.bold, 11, .blackApp))
    private let pageCountLabel = UILabel(style: .custom(.bold, 12, .green400))
    private let titleLabel = UILabel(style: .custom(.extraBold, 20, .whiteApp))
    private let bodyLabel = UILabel(style: .custom(.regular, 14, .gray100))
    private let tipBoxLabel = UILabel(style: .custom(.medium, 12, .green200))
    private let zoneGuideStack = UIStackView()
    private let toolBar = FanNoteViewerToolBar(title: "덕질 노트 뷰어")
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        renderCurrentPage(animated: false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        invalidateTimer()
    }
    
    private func setupUI() {
        view.backgroundColor = .gray50
        toolBar.alpha = 0.0
        
        pageCardView.layer.cornerRadius = 24
        pageCardView.clipsToBounds = true
        pageCardView.translatesAutoresizingMaskIntoConstraints = false
        
        badgeLabel.backgroundColor = .green400
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.clipsToBounds = true
        
        titleLabel.numberOfLines = 0
        bodyLabel.numberOfLines = 0
        tipBoxLabel.numberOfLines = 0
        
        setupZoneGuide()
        
        pageCardView.addSubviews(badgeLabel, pageCountLabel, titleLabel, bodyLabel, tipBoxLabel, zoneGuideStack)
        view.addSubviews(pageCardView, toolBar)
        
        NSLayoutConstraint.activate([
            pageCardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            pageCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pageCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pageCardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            
            toolBar.topAnchor.constraint(equalTo: pageCardView.topAnchor, constant: 14),
            toolBar.leadingAnchor.constraint(equalTo: pageCardView.leadingAnchor, constant: 14),
            toolBar.trailingAnchor.constraint(equalTo: pageCardView.trailingAnchor, constant: -14),
            toolBar.heightAnchor.constraint(equalToConstant: 48),
            
            badgeLabel.topAnchor.constraint(equalTo: pageCardView.topAnchor, constant: 74),
            badgeLabel.leadingAnchor.constraint(equalTo: pageCardView.leadingAnchor, constant: 22),
            badgeLabel.heightAnchor.constraint(equalToConstant: 24),
            
            pageCountLabel.centerYAnchor.constraint(equalTo: badgeLabel.centerYAnchor),
            pageCountLabel.trailingAnchor.constraint(equalTo: pageCardView.trailingAnchor, constant: -22),
            
            titleLabel.topAnchor.constraint(equalTo: badgeLabel.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: pageCardView.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(equalTo: pageCardView.trailingAnchor, constant: -22),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            bodyLabel.leadingAnchor.constraint(equalTo: pageCardView.leadingAnchor, constant: 22),
            bodyLabel.trailingAnchor.constraint(equalTo: pageCardView.trailingAnchor, constant: -22),
            
            tipBoxLabel.leadingAnchor.constraint(equalTo: pageCardView.leadingAnchor, constant: 22),
            tipBoxLabel.trailingAnchor.constraint(equalTo: pageCardView.trailingAnchor, constant: -22),
            tipBoxLabel.bottomAnchor.constraint(equalTo: zoneGuideStack.topAnchor, constant: -18),
            
            zoneGuideStack.leadingAnchor.constraint(equalTo: pageCardView.leadingAnchor, constant: 14),
            zoneGuideStack.trailingAnchor.constraint(equalTo: pageCardView.trailingAnchor, constant: -14),
            zoneGuideStack.bottomAnchor.constraint(equalTo: pageCardView.bottomAnchor, constant: -16),
            zoneGuideStack.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        toolBar.onAction = { [weak self] action in
            switch action {
            case .bookmark:
                self?.showToastView(message: "북마크 상태가 변경되었습니다.")
            case .share:
                self?.showToastView(message: "공유 링크가 복사되었습니다.")
            case .back:
                break
            }
        }
        
        addTapGestureRecognizer()
        addSwipeGestureRecognizers()
    }
    
    private func setupZoneGuide() {
        zoneGuideStack.axis = .horizontal
        zoneGuideStack.distribution = .fillEqually
        zoneGuideStack.spacing = 6
        zoneGuideStack.translatesAutoresizingMaskIntoConstraints = false
        
        let zones = ["◀ 좌측 1/3: 이전", "● 중앙 1/3: 툴바", "우측 1/3: 다음 ▶"]
        for text in zones {
            let lbl = UILabel(style: .custom(.semiBold, 11, .whiteApp))
            lbl.text = text
            lbl.textAlignment = .center
            lbl.backgroundColor = UIColor.white.withAlphaComponent(0.14)
            lbl.layer.cornerRadius = 10
            lbl.clipsToBounds = true
            zoneGuideStack.addArrangedSubview(lbl)
        }
    }
    
    private func addTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func addSwipeGestureRecognizers() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    
    private func showUI(animated: Bool = true) {
        invalidateTimer()
        let duration = animated ? 0.25 : 0.0
        UIView.animate(withDuration: duration) {
            self.toolBar.alpha = 1.0
            self.toolBar.isUserInteractionEnabled = true
        }
        hideTimer = Timer.scheduledTimer(
            timeInterval: displayDuration,
            target: self,
            selector: #selector(autoHideUI),
            userInfo: nil,
            repeats: false
        )
    }
    
    private func hideUI(animated: Bool = true) {
        invalidateTimer()
        let duration = animated ? 0.25 : 0.0
        UIView.animate(withDuration: duration) {
            self.toolBar.alpha = 0.0
            self.toolBar.isUserInteractionEnabled = false
        }
    }
    
    private func invalidateTimer() {
        hideTimer?.invalidate()
        hideTimer = nil
    }
    
    private func moveToPreviousImage() {
        guard (currentImageIndex - 1) >= 0 else {
            showUI()
            showToastView(message: "첫 페이지입니다.")
            return
        }
        currentImageIndex -= 1
        renderCurrentPage(animated: true)
    }
    
    private func moveToNextImage() {
        guard (currentImageIndex + 1) < pages.count else {
            showUI()
            showToastView(message: "마지막 페이지입니다.")
            return
        }
        currentImageIndex += 1
        renderCurrentPage(animated: true)
    }
    
    private func renderCurrentPage(animated: Bool) {
        let item = pages[currentImageIndex]
        let applyBlock = {
            self.pageCardView.backgroundColor = UIColor(hex: item.themeHex)
            self.badgeLabel.text = "  \(item.badge)  "
            self.pageCountLabel.text = "\(item.pageNumber) / \(item.totalPages)"
            self.titleLabel.setupParagraphStyleText(item.title, ratio: 0.28)
            self.bodyLabel.setupParagraphStyleText(item.body, ratio: 0.45)
            self.tipBoxLabel.setupParagraphStyleText(item.tipText, ratio: 0.3)
        }
        if animated {
            UIView.transition(with: pageCardView, duration: 0.28, options: .transitionCrossDissolve, animations: applyBlock)
        } else {
            applyBlock()
        }
    }
    
    @objc private func autoHideUI() {
        hideUI(animated: true)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        let tapX = location.x
        
        if tapX <= previousTapPoint {
            moveToPreviousImage()
        } else if tapX >= nextTapPoint {
            moveToNextImage()
        } else {
            toolBar.alpha == 0 ? showUI() : hideUI()
        }
    }
    
    @objc private func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left: moveToNextImage()
        case .right: moveToPreviousImage()
        default: break
        }
    }
}

public struct FanNoteViewerRepresentable: UIViewControllerRepresentable {
    public init() {}
    public func makeUIViewController(context: Context) -> FanNoteViewerViewController {
        FanNoteViewerViewController()
    }
    public func updateUIViewController(_ uiViewController: FanNoteViewerViewController, context: Context) {}
}
