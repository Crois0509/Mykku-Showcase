//
//  ShowcaseModuleCard.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI

struct ShowcaseModuleCard: View {
    let badgeText: String
    let icon: String
    let title: String
    let subtitle: String
    let tags: [String]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: icon)
                        .font(.pretendard(of: .black, size: 13))
                        .foregroundStyle(Color.blackApp)
                        .frame(width: 30, height: 30)
                        .background(Color.green100)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                    
                    Text(badgeText)
                        .font(.pretendard(of: .bold, size: 11))
                        .foregroundStyle(Color.gray600)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.gray400)
                }
                
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.pretendard(of: .bold, size: 14))
                            .foregroundStyle(Color.blackApp)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(subtitle)
                            .font(.pretendard(of: .regular, size: 12))
                            .foregroundStyle(Color.gray700)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(3.5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.pretendard(of: .medium, size: 10))
                                .foregroundStyle(Color.gray700)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.gray100)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.whiteApp)
                    .shadow(color: Color.blackApp.opacity(0.05), radius: 8, x: 0, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray200, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
