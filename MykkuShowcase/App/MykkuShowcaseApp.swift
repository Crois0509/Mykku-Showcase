//
//  MykkuShowcaseApp.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import SwiftUI

@main
struct MykkuShowcaseApp: App {
    
    @StateObject private var diContainer = DIContainer(status: .mock)
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some Scene {
        WindowGroup {
            ShowcaseDashboardView()
                .environmentObject(diContainer)
                .environmentObject(networkMonitor)
        }
    }
}
