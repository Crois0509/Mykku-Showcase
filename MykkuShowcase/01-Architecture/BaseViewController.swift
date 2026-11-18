//
//  BaseViewController.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 11/2/25.
//

import UIKit

/// 코드 기반 UIViewController 작성 시 반복되는 `required init?(coder:)` 보일러플레이트를 제거한 베이스 클래스
open class BaseViewController: UIViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// UIKit ViewController 전용 커스텀 토스트 뷰 (`showToastView(message:)` 연동)
public final class VCToastView: UIView {
    
    private let messageView = UILabel(style: .custom(.semiBold, 13, .blackApp))
    
    public init(message: String) {
        super.init(frame: .zero)
        messageView.setupParagraphStyleText(message)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        messageView.textAlignment = .center
        
        addSubview(messageView)
        backgroundColor = .green100
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.green600.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.16
        layer.shadowOffset = .init(width: 0, height: 2)
        layer.shadowRadius = 6
        alpha = 0.0
        
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            messageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            messageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            messageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18)
        ])
    }
}

public extension UIViewController {
    /// UIKit ViewController 하단에 커스텀 토스트 뷰(`VCToastView`)를 애니메이션과 함께 노출
    func showToastView(message: String, _ duration: Double = 1.2, _ complete: (() -> Void)? = nil) {
        guard (self.view.subviews.last as? VCToastView) == nil else { return }
        let toastView = VCToastView(message: message)
        self.view.addSubview(toastView)
        
        NSLayoutConstraint.activate([
            toastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -48)
        ])
        
        UIView.animate(withDuration: 0.25) {
            toastView.alpha = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.25, animations: {
                toastView.alpha = 0.0
            }, completion: { _ in
                complete?()
                toastView.removeFromSuperview()
            })
        }
    }
}
