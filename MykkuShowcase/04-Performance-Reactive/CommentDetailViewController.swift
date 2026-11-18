//
//  CommentDetailViewController.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 4/9/26.
//

import UIKit
import SwiftUI
import Combine

// MARK: - Comment Domain Models (From CommentList.swift & Author.swift)
public struct CommentAuthor: Hashable, Sendable {
    public let memberId: String
    public let nickname: String
    public let roleTitle: String
    public let avatarColorHex: UInt
    
    public init(memberId: String, nickname: String, roleTitle: String, avatarColorHex: UInt) {
        self.memberId = memberId
        self.nickname = nickname
        self.roleTitle = roleTitle
        self.avatarColorHex = avatarColorHex
    }
}

public struct ReplyComment: Hashable, Sendable {
    public let id: Int
    public var content: String
    public let author: CommentAuthor
    public var likeCount: Int
    public var isLiked: Bool
    public let createdAt: String
    
    public init(
        id: Int,
        content: String,
        author: CommentAuthor,
        likeCount: Int,
        isLiked: Bool,
        createdAt: String
    ) {
        self.id = id
        self.content = content
        self.author = author
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.createdAt = createdAt
    }
}

public struct CommentDetail: Hashable, Sendable {
    public let id: Int
    public var content: String
    public let author: CommentAuthor
    public var likeCount: Int
    public var isLiked: Bool
    public var replies: [ReplyComment]
    public var replyCount: Int { replies.count }
    public let createdAt: String
    
    public init(
        id: Int,
        content: String,
        author: CommentAuthor,
        likeCount: Int,
        isLiked: Bool,
        replies: [ReplyComment],
        createdAt: String
    ) {
        self.id = id
        self.content = content
        self.author = author
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.replies = replies
        self.createdAt = createdAt
    }
}

public struct CommentList: Hashable, Sendable {
    public var comments: [CommentDetail]
    public let totalElements: Int
    public let currentPage: Int
    public let pageSize: Int
    public let hasNext: Bool
    
    public init(
        comments: [CommentDetail],
        totalElements: Int = 0,
        currentPage: Int = 1,
        pageSize: Int = 20,
        hasNext: Bool = false
    ) {
        self.comments = comments
        self.totalElements = totalElements
        self.currentPage = currentPage
        self.pageSize = pageSize
        self.hasNext = hasNext
    }
    
    public static func initialSample() -> CommentList {
        let user1 = CommentAuthor(memberId: "user_kpop_01", nickname: "꾸꾸마스터", roleTitle: "도키도키 아카이버", avatarColorHex: 0x8CFF58)
        let user2 = CommentAuthor(memberId: "user_spam_99", nickname: "광고봇계정", roleTitle: "새내기 등장", avatarColorHex: 0xFF8A8A)
        let user3 = CommentAuthor(memberId: "user_fan_02", nickname: "다꾸러버", roleTitle: "성실한 덕후", avatarColorHex: 0x9ABEFF)
        let meUser = CommentAuthor(memberId: "my_user_id", nickname: "나(마이꾸)", roleTitle: "첫 만남", avatarColorHex: 0xBCFF88)
        
        return CommentList(
            comments: [
                CommentDetail(
                    id: 101,
                    content: "이번 콘테스트 수상작들 진짜 다 너무 예뻐요!! 특히 네온 그린 스티커 배치가 예술이네요 💚",
                    author: user1,
                    likeCount: 24,
                    isLiked: true,
                    replies: [
                        ReplyComment(
                            id: 1001,
                            content: "맞아요! 저도 보자마자 저장했어요 ㅎㅎ 다음 시즌엔 꼭 같이 참여해요!",
                            author: user3,
                            likeCount: 5,
                            isLiked: false,
                            createdAt: "10분 전"
                        ),
                        ReplyComment(
                            id: 1002,
                            content: "댓글 우측 ••• 버튼이나 길게 누르기(Long Press)로 수정·삭제·차단·신고를 테스트해 보세요!",
                            author: meUser,
                            likeCount: 3,
                            isLiked: true,
                            createdAt: "방금 전"
                        )
                    ],
                    createdAt: "15분 전"
                ),
                CommentDetail(
                    id: 102,
                    content: "[홍보/스팸 샘플] 부적절한 광고 댓글입니다. 우측 ••• 메뉴에서 '차단하기' 또는 '신고하기'를 눌러보세요!",
                    author: user2,
                    likeCount: 0,
                    isLiked: false,
                    replies: [
                        ReplyComment(
                            id: 1003,
                            content: "광고봇계정이 작성한 답글입니다. 유저 차단 시 댓글과 답글에서 모두 즉시 필터링됩니다.",
                            author: user2,
                            likeCount: 0,
                            isLiked: false,
                            createdAt: "5분 전"
                        )
                    ],
                    createdAt: "8분 전"
                ),
                CommentDetail(
                    id: 103,
                    content: "내가 작성한 댓글입니다. 우측 ••• 메뉴를 누르면 '수정하기'와 '삭제하기' 메뉴가 나타납니다.",
                    author: meUser,
                    likeCount: 12,
                    isLiked: false,
                    replies: [],
                    createdAt: "3분 전"
                )
            ],
            totalElements: 3
        )
    }
}

public enum CommentSortType: Sendable {
    case likeCountFirst
    case newFirst
}

public enum CommentSection: Hashable, Sendable {
    case comment(Int)
}

// MARK: - CommentDelegate & CommentDetailStoreProtocol
@MainActor
public protocol CommentDelegate: AnyObject {
    func writingReply(for commentId: Int)
    func updateReplyItems(for commentId: Int)
    func sortComments(for sortType: CommentSortType)
    func toggleLike(isLike: Bool, for commentId: Int)
}

@MainActor
public protocol CommentDetailStoreProtocol: AnyObject {
    var commentPublisher: AnyPublisher<CommentList?, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var isErrorPublisher: AnyPublisher<Error?, Never> { get }
    
    func submitComment(content: String, parentCommentId: Int?)
    func editComment(commentId: String, content: String)
    func deleteComment(commentId: String)
    func changeSort(_ sortType: CommentSortType)
    func toggleLike(commentId: Int)
    func blockMember(_ memberId: String)
    func clearError()
}

// MARK: - ContentsCommentAdapter (From ContentsCommentAdapter.swift)
/// 서로 다른 도메인의 Store(예: DailyMSGStore, CommunityCommentStore)를 `CommentDetailStoreProtocol`로 변환 중계하는 어댑터
/// - 단 하나의 `CommentDetailViewController`로 하루덕담 댓글과 커뮤니티 피드 댓글 시트를 중복 없이 통합 재사용
@MainActor
public final class ContentsCommentAdapter: CommentDetailStoreProtocol {
    private let underlyingStore: CommunityCommentStore
    
    public init(store: CommunityCommentStore) {
        self.underlyingStore = store
    }
    
    public var commentPublisher: AnyPublisher<CommentList?, Never> {
        underlyingStore.$commentList
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        underlyingStore.$isLoading.eraseToAnyPublisher()
    }
    
    public var isErrorPublisher: AnyPublisher<Error?, Never> {
        underlyingStore.$error.eraseToAnyPublisher()
    }
    
    public func submitComment(content: String, parentCommentId: Int?) {
        underlyingStore.submitComment(content: content, parentCommentId: parentCommentId)
    }
    
    public func editComment(commentId: String, content: String) {
        underlyingStore.editComment(commentId: commentId, content: content)
    }
    
    public func deleteComment(commentId: String) {
        underlyingStore.deleteComment(commentId: commentId)
    }
    
    public func changeSort(_ sortType: CommentSortType) {
        underlyingStore.changeSort(sortType)
    }
    
    public func toggleLike(commentId: Int) {
        underlyingStore.toggleLike(commentId: commentId)
    }
    
    public func blockMember(_ memberId: String) {
        underlyingStore.blockMember(memberId)
    }
    
    public func clearError() {
        underlyingStore.clearError()
    }
}

// MARK: - CommunityCommentStore (From CommunityCommentStore.swift)
/// 커뮤니티 댓글 시트(`CommentDetailViewController`)용 Store
/// - 핵심 기법:
///   1. 낙관적 UI (Optimistic UI) 유저 차단(`blockMember`): 서버 응답 대기 없이 인메모리 댓글 및 답글 리스트에서 차단 유저의 글을 즉시 필터링하여 제거
///   2. 낙관적 좋아요(`toggleLike`): 즉시 UI 카운트 및 하트 색상을 반영하여 지연 없는 반응성 확보
@MainActor
public final class CommunityCommentStore: ObservableObject, CommentDetailStoreProtocol {
    
    @Published public private(set) var commentList: CommentList?
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var error: Error?
    @Published public private(set) var blockedMemberIds: Set<String> = []
    
    public static let currentUserId = "my_user_id"
    private var nextGeneratedId = 2000
    
    public init() {
        resetSampleData()
    }
    
    public func resetSampleData() {
        blockedMemberIds.removeAll()
        commentList = CommentList.initialSample()
    }
    
    public func submitComment(content: String, parentCommentId: Int?) {
        guard var current = commentList else { return }
        nextGeneratedId += 1
        let me = CommentAuthor(
            memberId: Self.currentUserId,
            nickname: "나(마이꾸)",
            roleTitle: "첫 만남",
            avatarColorHex: 0xBCFF88
        )
        
        if let parentId = parentCommentId,
           let idx = current.comments.firstIndex(where: { $0.id == parentId }) {
            let newReply = ReplyComment(
                id: nextGeneratedId,
                content: content,
                author: me,
                likeCount: 0,
                isLiked: false,
                createdAt: "방금 전"
            )
            current.comments[idx].replies.append(newReply)
        } else {
            let newComment = CommentDetail(
                id: nextGeneratedId,
                content: content,
                author: me,
                likeCount: 0,
                isLiked: false,
                replies: [],
                createdAt: "방금 전"
            )
            current.comments.append(newComment)
        }
        self.commentList = current
    }
    
    public func editComment(commentId: String, content: String) {
        guard var current = commentList, let targetId = Int(commentId) else { return }
        for i in current.comments.indices {
            if current.comments[i].id == targetId {
                current.comments[i].content = content
                self.commentList = current
                return
            }
            if let rIdx = current.comments[i].replies.firstIndex(where: { $0.id == targetId }) {
                current.comments[i].replies[rIdx].content = content
                self.commentList = current
                return
            }
        }
    }
    
    public func deleteComment(commentId: String) {
        guard var current = commentList, let targetId = Int(commentId) else { return }
        current.comments.removeAll { $0.id == targetId }
        for i in current.comments.indices {
            current.comments[i].replies.removeAll { $0.id == targetId }
        }
        self.commentList = current
    }
    
    public func changeSort(_ sortType: CommentSortType) {
        guard let commentList else { return }
        let sorted = commentList.comments.sorted {
            switch sortType {
            case .likeCountFirst: return $0.likeCount > $1.likeCount
            case .newFirst: return $0.id > $1.id
            }
        }
        self.commentList = CommentList(comments: sorted, totalElements: sorted.count)
    }
    
    public func toggleLike(commentId: Int) {
        guard var current = commentList else { return }
        for i in current.comments.indices {
            if current.comments[i].id == commentId {
                current.comments[i].isLiked.toggle()
                current.comments[i].likeCount += current.comments[i].isLiked ? 1 : -1
                self.commentList = current
                return
            }
            if let rIdx = current.comments[i].replies.firstIndex(where: { $0.id == commentId }) {
                current.comments[i].replies[rIdx].isLiked.toggle()
                current.comments[i].replies[rIdx].likeCount += current.comments[i].replies[rIdx].isLiked ? 1 : -1
                self.commentList = current
                return
            }
        }
    }
    
    /// 낙관적 UI (Optimistic UI) 기반 사용자 차단 즉시 필터링
    public func blockMember(_ memberId: String) {
        guard let commentList, !commentList.comments.isEmpty else { return }
        blockedMemberIds.insert(memberId)
        
        var filteredComments = commentList.comments.filter { $0.author.memberId != memberId }
        filteredComments = filteredComments.map { comment in
            var newComment = comment
            newComment.replies = comment.replies.filter { $0.author.memberId != memberId }
            return newComment
        }
        
        self.commentList?.comments = filteredComments
    }
    
    public func clearError() {
        error = nil
    }
    
    public var commentPublisher: AnyPublisher<CommentList?, Never> {
        $commentList.eraseToAnyPublisher()
    }
    
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    
    public var isErrorPublisher: AnyPublisher<Error?, Never> {
        $error.eraseToAnyPublisher()
    }
}

// MARK: - DailyMSGCommentView (Section Header - From DailyMSGCommentView.swift)
public final class DailyMSGCommentView: UICollectionReusableView {
    
    public weak var delegate: CommentDelegate?
    
    private var commentId: Int?
    private var isReplyExpanded = false
    private var isLiked: Bool = false
    private var likeCountValue = 0
    private var isMyComment: Bool = false
    
    public var onEditTapped: (() -> Void)?
    public var onDeleteTapped: (() -> Void)?
    public var onBlokedTapped: (() -> Void)?
    public var onReportTapped: (() -> Void)?
    
    private let avatarView = UILabel(style: .custom(.bold, 15, .blackApp))
    private let nameView = UILabel(style: .custom(.bold, 14, .blackApp))
    private let roleBadge = UILabel(style: .custom(.semiBold, 11, .gray700))
    private let stateView = UILabel(style: .custom(.medium, 11, .gray600))
    private let moreMenuButton = UIButton(type: .system)
    private let commentLabel = UILabel(style: .custom(.regular, 14, .blackApp))
    private let writingReplyButton = UIButton(type: .system)
    private let replyButton = UIButton(type: .system)
    private let replyChevronImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: config))
        imageView.tintColor = .gray700
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.layer.zPosition = 1
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let likeButton = UIButton(type: .system)
    private let likeCountLabel = UILabel(style: .custom(.medium, 11, .gray600))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configSection(_ item: CommentDetail, isExpanded: Bool = false) {
        commentId = item.id
        isLiked = item.isLiked
        likeCountValue = item.likeCount
        isMyComment = item.author.memberId == CommunityCommentStore.currentUserId
        
        avatarView.text = String(item.author.nickname.prefix(1))
        avatarView.backgroundColor = UIColor(hex: item.author.avatarColorHex)
        
        nameView.text = item.author.nickname
        roleBadge.text = "  \(item.author.roleTitle)  "
        stateView.text = item.createdAt
        commentLabel.setupParagraphStyleText(item.content)
        likeCountLabel.text = item.likeCount.shortFormat
        
        let heartImage = UIImage(systemName: item.isLiked ? "heart.fill" : "heart")
        likeButton.setImage(heartImage, for: .normal)
        likeButton.tintColor = item.isLiked ? .red500 : .gray400
        
        if item.replies.isEmpty {
            replyButton.isHidden = true
            isReplyExpanded = false
            replyChevronImageView.transform = .identity
        } else {
            replyButton.isHidden = false
            setReplyExpanded(isExpanded, replyCount: item.replyCount, animated: false)
        }
        
        rebuildMenu()
    }
    
    public func setReplyExpanded(_ isExpanded: Bool, replyCount: Int, animated: Bool) {
        isReplyExpanded = isExpanded
        replyButton.configuration?.attributedTitle = chipTitle("답글 \(isExpanded ? "접기" : "보기") (\(replyCount.shortFormat))")
        
        let targetTransform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
                self.replyChevronImageView.transform = targetTransform
            }
        } else {
            replyChevronImageView.transform = targetTransform
        }
    }
    
    private func setupUI() {
        backgroundColor = .whiteApp
        
        avatarView.textAlignment = .center
        avatarView.layer.cornerRadius = 21
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.gray300.cgColor
        avatarView.clipsToBounds = true
        
        roleBadge.backgroundColor = .gray100
        roleBadge.layer.cornerRadius = 6
        roleBadge.clipsToBounds = true
        
        commentLabel.numberOfLines = 0
        likeCountLabel.textAlignment = .center
        
        moreMenuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreMenuButton.tintColor = .gray500
        moreMenuButton.showsMenuAsPrimaryAction = true
        moreMenuButton.translatesAutoresizingMaskIntoConstraints = false
        
        setupWritingReplyButton()
        setupReplyButton()
        setupLikeButton()
        
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        
        addSubviews(
            avatarView,
            nameView,
            roleBadge,
            stateView,
            moreMenuButton,
            commentLabel,
            writingReplyButton,
            replyButton,
            likeButton,
            likeCountLabel
        )
        
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 42),
            avatarView.heightAnchor.constraint(equalToConstant: 42),
            
            nameView.topAnchor.constraint(equalTo: avatarView.topAnchor),
            nameView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            
            roleBadge.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            roleBadge.leadingAnchor.constraint(equalTo: nameView.trailingAnchor, constant: 6),
            roleBadge.heightAnchor.constraint(equalToConstant: 20),
            
            stateView.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            stateView.leadingAnchor.constraint(equalTo: roleBadge.trailingAnchor, constant: 6),
            
            moreMenuButton.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            moreMenuButton.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -6),
            moreMenuButton.widthAnchor.constraint(equalToConstant: 28),
            moreMenuButton.heightAnchor.constraint(equalToConstant: 24),
            
            likeButton.topAnchor.constraint(equalTo: avatarView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 28),
            likeButton.heightAnchor.constraint(equalToConstant: 24),
            
            likeCountLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 2),
            likeCountLabel.centerXAnchor.constraint(equalTo: likeButton.centerXAnchor),
            
            commentLabel.topAnchor.constraint(equalTo: nameView.bottomAnchor, constant: 6),
            commentLabel.leadingAnchor.constraint(equalTo: nameView.leadingAnchor),
            commentLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -10),
            
            writingReplyButton.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 10),
            writingReplyButton.leadingAnchor.constraint(equalTo: nameView.leadingAnchor),
            writingReplyButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            writingReplyButton.heightAnchor.constraint(equalToConstant: 26),
            
            replyButton.centerYAnchor.constraint(equalTo: writingReplyButton.centerYAnchor),
            replyButton.leadingAnchor.constraint(equalTo: writingReplyButton.trailingAnchor, constant: 8),
            replyButton.heightAnchor.constraint(equalToConstant: 26)
        ])
    }
    
    private func chipTitle(_ text: String) -> AttributedString {
        AttributedString(text, attributes: AttributeContainer([
            .font: UIFont.pretendard(of: .medium, size: 11),
            .foregroundColor: UIColor.gray700
        ]))
    }
    
    private func setupWritingReplyButton() {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = chipTitle("답글 쓰기")
        config.baseBackgroundColor = .gray100
        config.baseForegroundColor = .gray700
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "arrowshape.turn.up.left")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold))
        config.imagePadding = 5
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
        writingReplyButton.configuration = config
        writingReplyButton.translatesAutoresizingMaskIntoConstraints = false
        writingReplyButton.addAction(UIAction { [weak self] _ in
            guard let self, let id = self.commentId else { return }
            self.delegate?.writingReply(for: id)
        }, for: .touchUpInside)
    }
    
    private func setupReplyButton() {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = chipTitle("답글 보기")
        config.baseBackgroundColor = .whiteApp
        config.baseForegroundColor = .gray700
        config.cornerStyle = .capsule
        config.background.strokeWidth = 1.0
        config.background.strokeColor = .gray300
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 28, bottom: 4, trailing: 10)
        
        replyButton.configuration = config
        replyButton.translatesAutoresizingMaskIntoConstraints = false
        replyButton.addSubview(replyChevronImageView)
        NSLayoutConstraint.activate([
            replyChevronImageView.leadingAnchor.constraint(equalTo: replyButton.leadingAnchor, constant: 10),
            replyChevronImageView.centerYAnchor.constraint(equalTo: replyButton.centerYAnchor),
            replyChevronImageView.widthAnchor.constraint(equalToConstant: 12),
            replyChevronImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
        replyButton.addAction(UIAction { [weak self] _ in
            guard let self, let id = self.commentId else { return }
            self.delegate?.updateReplyItems(for: id)
        }, for: .touchUpInside)
    }
    
    private func setupLikeButton() {
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.addAction(UIAction { [weak self] _ in
            guard let self, let id = self.commentId else { return }
            self.delegate?.toggleLike(isLike: !self.isLiked, for: id)
        }, for: .touchUpInside)
    }
    
    private func rebuildMenu() {
        if isMyComment {
            let edit = UIAction(title: "수정하기", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.onEditTapped?()
            }
            let delete = UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.onDeleteTapped?()
            }
            moreMenuButton.menu = UIMenu(title: "내 댓글 관리", children: [edit, delete])
        } else {
            let block = UIAction(title: "차단하기", image: UIImage(systemName: "hand.raised.slash")) { [weak self] _ in
                self?.onBlokedTapped?()
            }
            let report = UIAction(title: "신고하기", image: UIImage(systemName: "exclamationmark.bubble"), attributes: .destructive) { [weak self] _ in
                self?.onReportTapped?()
            }
            moreMenuButton.menu = UIMenu(title: "댓글 옵션", children: [block, report])
        }
    }
}

extension DailyMSGCommentView: UIContextMenuInteractionDelegate {
    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            self?.moreMenuButton.menu
        }
    }
}

// MARK: - DailyMSGReplyCell (Reply Cell - From DailyMSGReplyCell.swift)
public final class DailyMSGReplyCell: UICollectionViewCell {
    
    public weak var delegate: CommentDelegate?
    
    private var commentId: Int?
    private var isLiked: Bool = false
    private var userId: String = ""
    
    public var onEditTapped: (() -> Void)?
    public var onDeleteTapped: (() -> Void)?
    public var onBlockedTapped: (() -> Void)?
    public var onReportTapped: (() -> Void)?
    
    private let avatarView = UILabel(style: .custom(.bold, 13, .blackApp))
    private let nameView = UILabel(style: .custom(.bold, 13, .blackApp))
    private let stateView = UILabel(style: .custom(.medium, 11, .gray600))
    private let moreMenuButton = UIButton(type: .system)
    private let commentLabel = UILabel(style: .custom(.regular, 13, .blackApp))
    private let likeButton = UIButton(type: .system)
    private let likeCountLabel = UILabel(style: .custom(.medium, 11, .gray600))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configCell(_ item: ReplyComment) {
        commentId = item.id
        isLiked = item.isLiked
        userId = item.author.memberId
        
        avatarView.text = String(item.author.nickname.prefix(1))
        avatarView.backgroundColor = UIColor(hex: item.author.avatarColorHex)
        
        nameView.text = item.author.nickname
        stateView.text = item.createdAt
        commentLabel.setupParagraphStyleText(item.content)
        likeCountLabel.text = item.likeCount.shortFormat
        
        let heartImage = UIImage(systemName: item.isLiked ? "heart.fill" : "heart")
        likeButton.setImage(heartImage, for: .normal)
        likeButton.tintColor = item.isLiked ? .red500 : .gray400
        
        rebuildMenu()
    }
    
    public func getReplyInfo() -> (userId: String, commentId: Int?, comment: String?) {
        return (userId, commentId, commentLabel.text)
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .gray50
        contentView.layer.cornerRadius = 14
        
        avatarView.textAlignment = .center
        avatarView.layer.cornerRadius = 16
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.gray300.cgColor
        avatarView.clipsToBounds = true
        
        commentLabel.numberOfLines = 0
        likeCountLabel.textAlignment = .center
        
        moreMenuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreMenuButton.tintColor = .gray500
        moreMenuButton.showsMenuAsPrimaryAction = true
        moreMenuButton.translatesAutoresizingMaskIntoConstraints = false
        
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.addAction(UIAction { [weak self] _ in
            guard let self, let id = self.commentId else { return }
            self.delegate?.toggleLike(isLike: !self.isLiked, for: id)
        }, for: .touchUpInside)
        
        contentView.addSubviews(
            avatarView,
            nameView,
            stateView,
            moreMenuButton,
            commentLabel,
            likeButton,
            likeCountLabel
        )
        
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 42),
            avatarView.widthAnchor.constraint(equalToConstant: 32),
            avatarView.heightAnchor.constraint(equalToConstant: 32),
            
            nameView.topAnchor.constraint(equalTo: avatarView.topAnchor),
            nameView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10),
            
            stateView.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            stateView.leadingAnchor.constraint(equalTo: nameView.trailingAnchor, constant: 6),
            
            moreMenuButton.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            moreMenuButton.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -4),
            moreMenuButton.widthAnchor.constraint(equalToConstant: 26),
            moreMenuButton.heightAnchor.constraint(equalToConstant: 22),
            
            likeButton.topAnchor.constraint(equalTo: avatarView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            likeButton.widthAnchor.constraint(equalToConstant: 24),
            likeButton.heightAnchor.constraint(equalToConstant: 22),
            
            likeCountLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 2),
            likeCountLabel.centerXAnchor.constraint(equalTo: likeButton.centerXAnchor),
            
            commentLabel.topAnchor.constraint(equalTo: nameView.bottomAnchor, constant: 4),
            commentLabel.leadingAnchor.constraint(equalTo: nameView.leadingAnchor),
            commentLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -8),
            commentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func rebuildMenu() {
        let isMyReply = (userId == CommunityCommentStore.currentUserId)
        if isMyReply {
            let edit = UIAction(title: "수정하기", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.onEditTapped?()
            }
            let delete = UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.onDeleteTapped?()
            }
            moreMenuButton.menu = UIMenu(title: "내 답글 관리", children: [edit, delete])
        } else {
            let block = UIAction(title: "차단하기", image: UIImage(systemName: "hand.raised.slash")) { [weak self] _ in
                self?.onBlockedTapped?()
            }
            let report = UIAction(title: "신고하기", image: UIImage(systemName: "exclamationmark.bubble"), attributes: .destructive) { [weak self] _ in
                self?.onReportTapped?()
            }
            moreMenuButton.menu = UIMenu(title: "답글 옵션", children: [block, report])
        }
    }
}

// MARK: - CommentTextInputView (From CommentTextInputView.swift)
public final class PaddedTextField: UITextField {
    private let padding = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 24)
    public override func textRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: padding) }
    public override func editingRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: padding) }
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: padding) }
}

public final class CommentTextInputView: UIView {
    private let avatarBadge = UILabel(style: .custom(.bold, 13, .blackApp))
    public private(set) var textField = PaddedTextField()
    public private(set) var triggerButton = UIButton(type: .system)
    private let containerView = UIView()
    private let replyBannerView = UIView()
    private let replyLabel = UILabel(style: .custom(.medium, 12, .gray700))
    private let replyCloseButton = UIButton(type: .system)
    private var replyBannerHeightConstraint: NSLayoutConstraint?
    
    public var onSubmit: (() -> Void)?
    public var onCancelReply: (() -> Void)?
    
    public init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        textField.layer.cornerRadius = 18
        avatarBadge.layer.cornerRadius = 18
    }
    
    public func showReplyBanner(nickname: String) {
        replyLabel.text = "@\(nickname) 님께 답글 쓰는 중"
        replyBannerHeightConstraint?.constant = 36
        replyBannerView.isHidden = false
    }
    
    public func hideReplyBanner() {
        replyBannerHeightConstraint?.constant = 0
        replyBannerView.isHidden = true
    }
    
    public func buttonActivation(_ inputIsNotEmpty: Bool) {
        triggerButton.isEnabled = inputIsNotEmpty
        let targetColor: UIColor = inputIsNotEmpty ? .blackApp : .gray600
        let attrTitle = AttributedString("등록", attributes: AttributeContainer([
            .font: UIFont.pretendard(of: .bold, size: 13),
            .foregroundColor: targetColor
        ]))
        
        UIView.transition(with: triggerButton, duration: 0.2, options: .transitionCrossDissolve) {
            guard var config = self.triggerButton.configuration else { return }
            config.baseBackgroundColor = inputIsNotEmpty ? .green400 : .gray100
            config.attributedTitle = attrTitle
            self.triggerButton.configuration = config
        }
    }
    
    public func checkCurrentInput() -> String { textField.text ?? "" }
    public func removeTextField() { textField.text = "" }
    
    private func setupUI() {
        backgroundColor = .whiteApp
        translatesAutoresizingMaskIntoConstraints = false
        
        replyBannerView.backgroundColor = .gray100
        replyBannerView.clipsToBounds = true
        replyBannerView.isHidden = true
        replyBannerView.translatesAutoresizingMaskIntoConstraints = false
        
        replyCloseButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        replyCloseButton.tintColor = .gray600
        replyCloseButton.translatesAutoresizingMaskIntoConstraints = false
        replyCloseButton.addAction(UIAction { [weak self] _ in
            self?.hideReplyBanner()
            self?.onCancelReply?()
        }, for: .touchUpInside)
        
        containerView.backgroundColor = .whiteApp
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.gray200.cgColor
        
        avatarBadge.text = "나"
        avatarBadge.backgroundColor = .green200
        avatarBadge.textAlignment = .center
        avatarBadge.clipsToBounds = true
        
        textField.setupPlaceholder("댓글을 입력해 주세요.", .pretendard(of: .regular, size: 13), .gray500)
        textField.textColor = .blackApp
        textField.font = .pretendard(of: .regular, size: 13)
        textField.backgroundColor = .gray50
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString("등록", attributes: AttributeContainer([
            .font: UIFont.pretendard(of: .bold, size: 13),
            .foregroundColor: UIColor.gray600
        ]))
        config.baseBackgroundColor = .gray100
        config.cornerStyle = .capsule
        triggerButton.configuration = config
        triggerButton.isEnabled = false
        triggerButton.translatesAutoresizingMaskIntoConstraints = false
        triggerButton.addAction(UIAction { [weak self] _ in
            self?.onSubmit?()
        }, for: .touchUpInside)
        
        addSubviews(replyBannerView, containerView)
        replyBannerView.addSubviews(replyLabel, replyCloseButton)
        containerView.addSubviews(avatarBadge, textField, triggerButton)
        
        let bannerH = replyBannerView.heightAnchor.constraint(equalToConstant: 0)
        self.replyBannerHeightConstraint = bannerH
        
        NSLayoutConstraint.activate([
            replyBannerView.topAnchor.constraint(equalTo: topAnchor),
            replyBannerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            replyBannerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bannerH,
            
            replyLabel.centerYAnchor.constraint(equalTo: replyBannerView.centerYAnchor),
            replyLabel.leadingAnchor.constraint(equalTo: replyBannerView.leadingAnchor, constant: 16),
            
            replyCloseButton.centerYAnchor.constraint(equalTo: replyBannerView.centerYAnchor),
            replyCloseButton.trailingAnchor.constraint(equalTo: replyBannerView.trailingAnchor, constant: -16),
            replyCloseButton.widthAnchor.constraint(equalToConstant: 22),
            replyCloseButton.heightAnchor.constraint(equalToConstant: 22),
            
            containerView.topAnchor.constraint(equalTo: replyBannerView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 56),
            
            avatarBadge.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarBadge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarBadge.widthAnchor.constraint(equalToConstant: 36),
            avatarBadge.heightAnchor.constraint(equalToConstant: 36),
            
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: avatarBadge.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: triggerButton.leadingAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 36),
            
            triggerButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            triggerButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            triggerButton.widthAnchor.constraint(equalToConstant: 58),
            triggerButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
}

// MARK: - CommentDetailCollectionView (From CommentDetailCollectionView.swift)
public final class CommentDetailCollectionView: BaseCollectionView {
    public override init() {
        super.init()
        backgroundColor = .whiteApp
        keyboardDismissMode = .onDrag
        collectionViewLayout = baseLayout
        register(DailyMSGReplyCell.self, forCellWithReuseIdentifier: DailyMSGReplyCell.id)
        register(
            DailyMSGCommentView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DailyMSGCommentView.id
        )
    }
    
    private var baseLayout: UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] _, _ in
            guard let self else { return nil }
            let section = self.commentLayout
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
            let header = self.createSectionHeaderLayout(estimatedHeight: 130)
            section.boundarySupplementaryItems = [header]
            return section
        }
    }
}

// MARK: - CommentDetailViewController (From CommentDetailViewController.swift)
/// MYKKU의 `CommentDetailViewController` 구현체
/// - DiffableDataSource 섹션 헤더(`DailyMSGCommentView`)와 답글 셀(`DailyMSGReplyCell`)을 결합한 계층형 댓글 UI
/// - 낙관적 UI 기반 실시간 유저 차단(`blockMember`) 및 신고하기(`reportAction`) 파이프라인 연동
public final class CommentDetailViewController: UIViewController {
    
    public var reportAction: ((Int) -> Void)?
    
    private let store: any CommentDetailStoreProtocol
    private var dataSource: UICollectionViewDiffableDataSource<CommentSection, ReplyComment>!
    private var cancellables = Set<AnyCancellable>()
    
    private var commentItem: CommentList?
    private var replyTargetId: Int?
    private var pendingExpandCommentId: Int? = 101 // 첫 번째 댓글 답글을 기본 펼쳐서 보여줌
    private var isEditComment: Bool = false
    private var editCommentId: Int?
    
    private let commentList = CommentDetailCollectionView()
    private let commentInputTextView = CommentTextInputView()
    private let emptyLabel = UILabel(style: .custom(.medium, 14, .gray500))
    
    public init(store: any CommentDetailStoreProtocol) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .whiteApp
        
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 2
        emptyLabel.setupParagraphStyleText("아직 작성된 댓글이 없어요.\n첫 번째 댓글로 소통을 시작해보세요!")
        emptyLabel.isHidden = true
        
        commentList.delegate = self
        commentInputTextView.onSubmit = { [weak self] in self?.submitComment() }
        commentInputTextView.onCancelReply = { [weak self] in
            self?.replyTargetId = nil
            self?.isEditComment = false
            self?.editCommentId = nil
            self?.commentInputTextView.textField.resignFirstResponder()
        }
        commentInputTextView.textField.delegate = self
        
        view.addSubviews(commentList, emptyLabel, commentInputTextView)
        NSLayoutConstraint.activate([
            commentList.topAnchor.constraint(equalTo: view.topAnchor),
            commentList.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            commentList.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            commentList.bottomAnchor.constraint(equalTo: commentInputTextView.topAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: commentList.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: commentList.centerYAnchor),
            
            commentInputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentInputTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            commentInputTextView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
        
        setupDataSource()
        bind()
    }
    
    private func setupDataSource() {
        dataSource = .init(collectionView: commentList) { [weak self] collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyMSGReplyCell.id, for: indexPath) as? DailyMSGReplyCell else {
                return UICollectionViewCell()
            }
            cell.configCell(item)
            cell.delegate = self
            
            cell.onEditTapped = { [weak self] in
                self?.isEditComment = true
                self?.editCommentId = item.id
                self?.commentInputTextView.showReplyBanner(nickname: "답글 수정 중")
                self?.commentInputTextView.textField.text = item.content
                self?.commentInputTextView.buttonActivation(true)
                self?.commentInputTextView.textField.becomeFirstResponder()
            }
            cell.onDeleteTapped = { [weak self] in
                self?.showTriggerAlert(title: "정말 삭제하시겠습니까?", message: "삭제된 답글은 복구할 수 없습니다.", distructive: true) {
                    self?.store.deleteComment(commentId: String(item.id))
                }
            }
            cell.onBlockedTapped = { [weak self] in
                self?.showTriggerAlert(
                    title: "정말 차단하시겠습니까?",
                    message: "차단한 유저(\(item.author.nickname))의 댓글과 답글은 즉시 숨겨집니다.",
                    distructive: true
                ) {
                    self?.store.blockMember(item.author.memberId)
                }
            }
            cell.onReportTapped = { [weak self] in
                self?.reportAction?(item.id)
            }
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: DailyMSGCommentView.id,
                    for: indexPath
                  ) as? DailyMSGCommentView,
                  let comment = self?.commentItem,
                  indexPath.section < comment.comments.count
            else { return nil }
            
            let item = comment.comments[indexPath.section]
            let isExpanded = !(self?.dataSource.snapshot().itemIdentifiers(inSection: .comment(item.id)).isEmpty ?? true)
            supplementaryView.configSection(item, isExpanded: isExpanded)
            supplementaryView.delegate = self
            
            supplementaryView.onEditTapped = { [weak self] in
                self?.isEditComment = true
                self?.editCommentId = item.id
                self?.commentInputTextView.showReplyBanner(nickname: "댓글 수정 중")
                self?.commentInputTextView.textField.text = item.content
                self?.commentInputTextView.buttonActivation(true)
                self?.commentInputTextView.textField.becomeFirstResponder()
            }
            supplementaryView.onDeleteTapped = { [weak self] in
                self?.showTriggerAlert(title: "정말 삭제하시겠습니까?", message: "삭제된 댓글은 복구할 수 없습니다.", distructive: true) {
                    self?.store.deleteComment(commentId: String(item.id))
                }
            }
            supplementaryView.onBlokedTapped = { [weak self] in
                self?.showTriggerAlert(
                    title: "정말 차단하시겠습니까?",
                    message: "차단한 유저(\(item.author.nickname))의 댓글과 답글은 즉시 보이지 않습니다.\n차단 유저는 설정에서 관리할 수 있습니다.",
                    distructive: true
                ) {
                    self?.store.blockMember(item.author.memberId)
                }
            }
            supplementaryView.onReportTapped = { [weak self] in
                self?.reportAction?(item.id)
            }
            
            return supplementaryView
        }
    }
    
    private func bind() {
        store.commentPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] commentList in
                self?.commentItem = commentList
                self?.applySnapShot()
            }
            .store(in: &cancellables)
    }
    
    private func applySnapShot() {
        guard let commentItem = self.commentItem else { return }
        emptyLabel.isHidden = !commentItem.comments.isEmpty
        
        let previousSnapshot = dataSource.snapshot()
        var expandedIds = Set(previousSnapshot.sectionIdentifiers.compactMap { section -> Int? in
            guard case .comment(let id) = section, !previousSnapshot.itemIdentifiers(inSection: section).isEmpty else { return nil }
            return id
        })
        
        if let pendingExpandCommentId {
            expandedIds.insert(pendingExpandCommentId)
            self.pendingExpandCommentId = nil
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<CommentSection, ReplyComment>()
        for comment in commentItem.comments {
            let section = CommentSection.comment(comment.id)
            snapshot.appendSections([section])
            snapshot.appendItems(expandedIds.contains(comment.id) ? comment.replies : [], toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.commentList.reloadData()
        }
    }
    
    private func showReplyItems(_ sectionId: Int) {
        var snapshot = dataSource.snapshot()
        guard snapshot.sectionIdentifiers.contains(.comment(sectionId)),
              let comment = commentItem?.comments.first(where: { $0.id == sectionId }) else { return }
        let oldItems = snapshot.itemIdentifiers(inSection: .comment(sectionId))
        let willExpand = oldItems.isEmpty
        
        if willExpand {
            guard !comment.replies.isEmpty else {
                writingReply(for: sectionId)
                return
            }
            snapshot.appendItems(comment.replies, toSection: .comment(sectionId))
        } else {
            snapshot.deleteItems(oldItems)
        }
        
        if let sectionIndex = snapshot.indexOfSection(.comment(sectionId)),
           let headerView = commentList.supplementaryView(
               forElementKind: UICollectionView.elementKindSectionHeader,
               at: IndexPath(item: 0, section: sectionIndex)
           ) as? DailyMSGCommentView {
            headerView.setReplyExpanded(willExpand, replyCount: comment.replyCount, animated: true)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func submitComment() {
        let content = commentInputTextView.checkCurrentInput().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        if isEditComment, let editId = editCommentId {
            store.editComment(commentId: String(editId), content: content)
            isEditComment = false
            editCommentId = nil
        } else {
            pendingExpandCommentId = replyTargetId
            store.submitComment(content: content, parentCommentId: replyTargetId)
        }
        
        commentInputTextView.removeTextField()
        commentInputTextView.buttonActivation(false)
        commentInputTextView.hideReplyBanner()
        commentInputTextView.textField.resignFirstResponder()
        replyTargetId = nil
    }
}

extension CommentDetailViewController: CommentDelegate {
    public func writingReply(for commentId: Int) {
        isEditComment = false
        editCommentId = nil
        replyTargetId = commentId
        
        UIView.animate(withDuration: 0.3, animations: {
            self.commentInputTextView.textField.becomeFirstResponder()
            if let nickname = self.commentItem?.comments.first(where: { $0.id == commentId })?.author.nickname {
                self.commentInputTextView.showReplyBanner(nickname: nickname)
            }
        }, completion: { _ in
            // 부모 댓글 헤더의 레이아웃 프레임 Y 좌표를 계산해 키보드 위쪽으로 자동 포커싱 스크롤
            if let section = self.dataSource.snapshot().indexOfSection(.comment(commentId)) {
                let targetIndexPath = IndexPath(item: 0, section: section)
                if let headerAttributes = self.commentList.layoutAttributesForSupplementaryElement(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    at: targetIndexPath
                ) {
                    let headerY = headerAttributes.frame.origin.y
                    let maxOffset = max(0, self.commentList.contentSize.height - self.commentList.bounds.height)
                    let targetPointY = max(0, min(maxOffset, headerY))
                    self.commentList.setContentOffset(CGPoint(x: 0, y: targetPointY), animated: true)
                }
            }
        })
    }
    
    public func updateReplyItems(for commentId: Int) {
        showReplyItems(commentId)
    }
    
    public func sortComments(for sortType: CommentSortType) {
        store.changeSort(sortType)
    }
    
    public func toggleLike(isLike: Bool, for commentId: Int) {
        store.toggleLike(commentId: commentId)
    }
}

extension CommentDetailViewController: UITextFieldDelegate {
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        commentInputTextView.buttonActivation(!text.isEmpty)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitComment()
        return true
    }
}

extension CommentDetailViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let itemIndexPath = collectionView.indexPathForItem(at: point),
              indexPaths.contains(itemIndexPath),
              let cell = collectionView.cellForItem(at: itemIndexPath) as? DailyMSGReplyCell
        else { return nil }
        
        let replyInfo = cell.getReplyInfo()
        let isMyReply = (replyInfo.userId == CommunityCommentStore.currentUserId)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            if isMyReply {
                let edit = UIAction(title: "수정하기", image: UIImage(systemName: "pencil")) { _ in
                    self?.isEditComment = true
                    self?.editCommentId = replyInfo.commentId
                    self?.commentInputTextView.showReplyBanner(nickname: "답글 수정 중")
                    self?.commentInputTextView.textField.text = replyInfo.comment
                    self?.commentInputTextView.buttonActivation(true)
                    self?.commentInputTextView.textField.becomeFirstResponder()
                }
                let delete = UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                    if let id = replyInfo.commentId {
                        self?.showTriggerAlert(title: "정말 삭제하시겠습니까?", message: "삭제된 답글은 복구할 수 없습니다.", distructive: true) {
                            self?.store.deleteComment(commentId: String(id))
                        }
                    }
                }
                return UIMenu(title: "내 답글 관리", children: [edit, delete])
            } else {
                let block = UIAction(title: "차단하기", image: UIImage(systemName: "hand.raised.slash")) { _ in
                    self?.showTriggerAlert(
                        title: "정말 차단하시겠습니까?",
                        message: "차단한 유저의 댓글과 답글은 보이지 않습니다.",
                        distructive: true
                    ) {
                        self?.store.blockMember(replyInfo.userId)
                    }
                }
                let report = UIAction(title: "신고하기", image: UIImage(systemName: "exclamationmark.bubble"), attributes: .destructive) { _ in
                    if let id = replyInfo.commentId {
                        self?.reportAction?(id)
                    }
                }
                return UIMenu(title: "답글 옵션", children: [block, report])
            }
        }
    }
}

// MARK: - SwiftUI Representable (From CommunityCommentDetailView.swift)
public struct CommunityCommentDetailView: UIViewControllerRepresentable {
    public let store: CommunityCommentStore
    public let pushContentReport: (ReportTargetType, Int) -> Void
    
    public init(store: CommunityCommentStore, pushContentReport: @escaping (ReportTargetType, Int) -> Void) {
        self.store = store
        self.pushContentReport = pushContentReport
    }
    
    public func makeUIViewController(context: Context) -> CommentDetailViewController {
        let adapter = ContentsCommentAdapter(store: store)
        let vc = CommentDetailViewController(store: adapter)
        vc.reportAction = { id in
            pushContentReport(.feedComment, id)
        }
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: CommentDetailViewController, context: Context) {}
}
