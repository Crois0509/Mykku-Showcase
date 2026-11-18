//
//  Font+DesignSystem.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI
import UIKit

public enum PretendardFontType: String {
    case black = "Pretendard-Black"
    case extraBold = "Pretendard-ExtraBold"
    case bold = "Pretendard-Bold"
    case semiBold = "Pretendard-SemiBold"
    case medium = "Pretendard-Medium"
    case regular = "Pretendard-Regular"
    case light = "Pretendard-Light"
    case extraLight = "Pretendard-ExtraLight"
    case thin = "Pretendard-Thin"
    
    var systemWeight: Font.Weight {
        switch self {
        case .black: return .black
        case .extraBold: return .heavy
        case .bold: return .bold
        case .semiBold: return .semibold
        case .medium: return .medium
        case .regular: return .regular
        case .light: return .light
        case .extraLight: return .ultraLight
        case .thin: return .thin
        }
    }
    
    var uiFontWeight: UIFont.Weight {
        switch self {
        case .black: return .black
        case .extraBold: return .heavy
        case .bold: return .bold
        case .semiBold: return .semibold
        case .medium: return .medium
        case .regular: return .regular
        case .light: return .light
        case .extraLight: return .ultraLight
        case .thin: return .thin
        }
    }
}

public typealias PretendardWeight = PretendardFontType

// MARK: - SwiftUI Font Extension
/// 최소 폰트 크기 11pt 보장 및 MYKKU 디자인 보정(+2pt) 적용
public extension Font {
    static func pretendard(of type: PretendardFontType, size: CGFloat) -> Font {
        let clampedSize = max(size, 11) + 2
        if UIFont(name: type.rawValue, size: clampedSize) != nil {
            return .custom(type.rawValue, size: clampedSize)
        }
        return .system(size: clampedSize, weight: type.systemWeight)
    }
}

// MARK: - UIKit UIFont Extension
/// 최소 폰트 크기 11pt 보장 및 MYKKU 디자인 보정(+2pt) 적용
public extension UIFont {
    static func pretendard(of type: PretendardFontType, size: CGFloat) -> UIFont {
        let clampedSize = max(size, 11) + 2
        if let font = UIFont(name: type.rawValue, size: clampedSize) {
            return font
        }
        return .systemFont(ofSize: clampedSize, weight: type.uiFontWeight)
    }
}

// MARK: - UILabel Style & Paragraph Helper (+UILabel.swift)
public extension UILabel {
    enum LabelStyle {
        case title
        case subtitle
        case content
        case date
        case custom(PretendardFontType, CGFloat, UIColor)
    }
    
    convenience init(style: LabelStyle) {
        self.init()
        switch style {
        case .title:
            createLabel(color: .blackApp, type: .bold, size: 14)
        case .subtitle:
            createLabel(color: .gray600, type: .regular, size: 11)
        case .content:
            createLabel(color: .blackApp, type: .regular, size: 13)
        case .date:
            createLabel(color: .gray600, type: .regular, size: 11)
        case .custom(let style, let size, let color):
            createLabel(color: color, type: style, size: max(size, 11))
        }
    }
    
    func createLabel(color: UIColor, type: PretendardFontType, size: CGFloat) {
        self.textColor = color
        self.font = .pretendard(of: type, size: max(size, 11))
        self.numberOfLines = 0
        self.textAlignment = .left
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.lineBreakMode = .byTruncatingTail
    }
    
    func setupParagraphStyleText(_ text: String?, ratio: Double = 0.35) {
        guard let text else { return }
        let font = self.font ?? UIFont.pretendard(of: .regular, size: 14)
        let fontSize = font.pointSize
        let alignment = self.textAlignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = fontSize * ratio
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: self.textColor ?? UIColor.blackApp,
            .paragraphStyle: paragraphStyle
        ]
        self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}

// MARK: - UIView, UITextField, UIViewController, Int, String Helpers
public extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

public extension UITextField {
    func setupPlaceholder(_ text: String, _ font: UIFont?, _ color: UIColor) {
        let attributes = AttributeContainer([
            .font: font ?? UIFont.pretendard(of: .regular, size: 14),
            .foregroundColor: color
        ])
        self.attributedPlaceholder = NSAttributedString(AttributedString(text, attributes: attributes))
    }
}

public extension UIViewController {
    func showCancelAlert(title: String, message: String, _ completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        self.present(alert, animated: true)
    }
    
    func showTriggerAlert(title: String, message: String, distructive: Bool = false, _ completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: distructive ? .destructive : .default) { _ in
            completion?()
        })
        self.present(alert, animated: true)
    }
}

public extension Int {
    var shortFormat: String {
        let doubleValue = Double(self)
        if self >= 1_000_000 {
            var formatted = String(format: "%.1f", doubleValue / 1_000_000.0)
            if formatted.hasSuffix(".0") { formatted.removeLast(2) }
            return "\(formatted)m"
        } else if self >= 1_000 {
            var formatted = String(format: "%.1f", doubleValue / 1_000.0)
            if formatted.hasSuffix(".0") { formatted.removeLast(2) }
            return "\(formatted)k"
        } else {
            return "\(self)"
        }
    }
}
