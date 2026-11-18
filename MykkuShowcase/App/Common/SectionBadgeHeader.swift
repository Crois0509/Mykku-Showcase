//
//  SectionBadgeHeader.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI

struct SectionBadgeHeader: View {
    let badge: String
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(badge)
                .font(.pretendard(of: .bold, size: 11))
                .foregroundStyle(Color.blackApp)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color.green400)
                .clipShape(Capsule())
            
            Text(title)
                .font(.pretendard(of: .bold, size: 17))
                .foregroundStyle(Color.blackApp)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
