//
//  BaseRepresentable.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 11/13/25.
//

import SwiftUI

/// UIKit ViewController를 SwiftUI 계층에 편입시킬 때 일관된 Store(상태) 및 Coordinator(라우팅) 주입을 강제하는 표준 브릿지 프로토콜
@MainActor
public protocol BaseRepresentable: UIViewControllerRepresentable {
    associatedtype CoordinatorType: CoordinatorProtocol
    associatedtype StoreType: Store
    
    var coordinator: CoordinatorType { get }
    var store: StoreType { get }
}
