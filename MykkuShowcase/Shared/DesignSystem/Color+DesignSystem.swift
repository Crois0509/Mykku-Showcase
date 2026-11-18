//
//  Color+DesignSystem.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI
import UIKit

// MARK: - SwiftUI MYKKU Color Palette (Exact Match with MYKKU Assets.xcassets)
public extension Color {
    // Base
    static let blackApp = Color(hex: 0x282828)
    static let whiteApp = Color(hex: 0xFFFFFF)
    static let launchBGColor = Color(hex: 0xBCFF88)
    
    // Brand Signature Neon Green
    static let green50  = Color(hex: 0xF4FFE8)
    static let green100 = Color(hex: 0xD9FFB8)
    static let green200 = Color(hex: 0xBCFF88)
    static let green300 = Color(hex: 0xA1FF6C)
    static let green400 = Color(hex: 0x8CFF58)
    static let green500 = Color(hex: 0x84FF58)
    static let green600 = Color(hex: 0x6AF045)
    static let green700 = Color(hex: 0x53E138)
    static let green800 = Color(hex: 0x36C128)
    static let green900 = Color(hex: 0x1C9E1A)
    
    // Gray Scale
    static let gray50  = Color(hex: 0xF9F9F9)
    static let gray100 = Color(hex: 0xF1F1F1)
    static let gray200 = Color(hex: 0xE8E8E8)
    static let gray300 = Color(hex: 0xDEDEDE)
    static let gray400 = Color(hex: 0xC2C2C2)
    static let gray500 = Color(hex: 0xA3A3A3)
    static let gray600 = Color(hex: 0x878787)
    static let gray700 = Color(hex: 0x626262)
    static let gray800 = Color(hex: 0x3A3A3A)
    
    // Blue
    static let blue50  = Color(hex: 0xF2F6FF)
    static let blue100 = Color(hex: 0xDDE7FF)
    static let blue200 = Color(hex: 0xBFD4FF)
    static let blue300 = Color(hex: 0x9ABEFF)
    static let blue400 = Color(hex: 0x7DA7FF)
    static let blue500 = Color(hex: 0x618EFF)
    static let blue600 = Color(hex: 0x4B73E1)
    static let blue700 = Color(hex: 0x3C5FC1)
    static let blue800 = Color(hex: 0x2A4691)
    static let blue900 = Color(hex: 0x182D5A)
    
    // Pink
    static let pink50  = Color(hex: 0xFFF0F4)
    static let pink100 = Color(hex: 0xFFE0EB)
    static let pink200 = Color(hex: 0xFFCCE0)
    static let pink300 = Color(hex: 0xFFA1C1)
    static let pink400 = Color(hex: 0xFF97BA)
    static let pink500 = Color(hex: 0xFF6DA1)
    static let pink600 = Color(hex: 0xFF4889)
    static let pink700 = Color(hex: 0xEB3674)
    static let pink800 = Color(hex: 0xC01D55)
    static let pink900 = Color(hex: 0x870B3A)
    
    // Red
    static let red50  = Color(hex: 0xFFF0F0)
    static let red100 = Color(hex: 0xFFD9D9)
    static let red200 = Color(hex: 0xFFB3B3)
    static let red300 = Color(hex: 0xFF8A8A)
    static let red400 = Color(hex: 0xFF6F6F)
    static let red500 = Color(hex: 0xFF5B5B)
    static let red600 = Color(hex: 0xE14A4A)
    static let red700 = Color(hex: 0xC13C3C)
    static let red800 = Color(hex: 0x8E2A2A)
    static let red900 = Color(hex: 0x5A1818)
    
    // Social
    static let kakaoYellow = Color(hex: 0xFEE500)
    static let naverGreen  = Color(hex: 0x03C75A)
    
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

// MARK: - UIKit MYKKU UIColor Palette (Exact Match with MYKKU Assets.xcassets)
public extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xff) / 255.0,
            green: CGFloat((hex >> 08) & 0xff) / 255.0,
            blue: CGFloat((hex >> 00) & 0xff) / 255.0,
            alpha: alpha
        )
    }
    
    static let blackApp = UIColor(hex: 0x282828)
    static let whiteApp = UIColor(hex: 0xFFFFFF)
    static let launchBGColor = UIColor(hex: 0xBCFF88)
    
    // Green
    static let green50  = UIColor(hex: 0xF4FFE8)
    static let green100 = UIColor(hex: 0xD9FFB8)
    static let green200 = UIColor(hex: 0xBCFF88)
    static let green300 = UIColor(hex: 0xA1FF6C)
    static let green400 = UIColor(hex: 0x8CFF58)
    static let green500 = UIColor(hex: 0x84FF58)
    static let green600 = UIColor(hex: 0x6AF045)
    static let green700 = UIColor(hex: 0x53E138)
    static let green800 = UIColor(hex: 0x36C128)
    static let green900 = UIColor(hex: 0x1C9E1A)
    
    // Gray
    static let gray50  = UIColor(hex: 0xF9F9F9)
    static let gray100 = UIColor(hex: 0xF1F1F1)
    static let gray200 = UIColor(hex: 0xE8E8E8)
    static let gray300 = UIColor(hex: 0xDEDEDE)
    static let gray400 = UIColor(hex: 0xC2C2C2)
    static let gray500 = UIColor(hex: 0xA3A3A3)
    static let gray600 = UIColor(hex: 0x878787)
    static let gray700 = UIColor(hex: 0x626262)
    static let gray800 = UIColor(hex: 0x3A3A3A)
    
    // Blue
    static let blue50  = UIColor(hex: 0xF2F6FF)
    static let blue100 = UIColor(hex: 0xDDE7FF)
    static let blue200 = UIColor(hex: 0xBFD4FF)
    static let blue300 = UIColor(hex: 0x9ABEFF)
    static let blue400 = UIColor(hex: 0x7DA7FF)
    static let blue500 = UIColor(hex: 0x618EFF)
    static let blue600 = UIColor(hex: 0x4B73E1)
    static let blue700 = UIColor(hex: 0x3C5FC1)
    static let blue800 = UIColor(hex: 0x2A4691)
    static let blue900 = UIColor(hex: 0x182D5A)
    
    // Pink
    static let pink50  = UIColor(hex: 0xFFF0F4)
    static let pink100 = UIColor(hex: 0xFFE0EB)
    static let pink200 = UIColor(hex: 0xFFCCE0)
    static let pink300 = UIColor(hex: 0xFFA1C1)
    static let pink400 = UIColor(hex: 0xFF97BA)
    static let pink500 = UIColor(hex: 0xFF6DA1)
    static let pink600 = UIColor(hex: 0xFF4889)
    static let pink700 = UIColor(hex: 0xEB3674)
    static let pink800 = UIColor(hex: 0xC01D55)
    static let pink900 = UIColor(hex: 0x870B3A)
    
    // Red
    static let red50  = UIColor(hex: 0xFFF0F0)
    static let red100 = UIColor(hex: 0xFFD9D9)
    static let red200 = UIColor(hex: 0xFFB3B3)
    static let red300 = UIColor(hex: 0xFF8A8A)
    static let red400 = UIColor(hex: 0xFF6F6F)
    static let red500 = UIColor(hex: 0xFF5B5B)
    static let red600 = UIColor(hex: 0xE14A4A)
    static let red700 = UIColor(hex: 0xC13C3C)
    static let red800 = UIColor(hex: 0x8E2A2A)
    static let red900 = UIColor(hex: 0x5A1818)
}
