//
//  ReusableIdentifierProtocol.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 11/2/25.
//

import UIKit

/// class 타입에 컴파일 타임 안전한 기본 identifier를 자동 생성하는 프로토콜
/// - 문자열 리터럴 하드코딩 오타로 인한 런타임 크래시 원천 방지
@MainActor
public protocol ReusableIdentifierProtocol: AnyObject {
    static var id: String { get }
}

extension UIView: @MainActor ReusableIdentifierProtocol {
    public static var id: String {
        String(describing: Self.self)
    }
}

// MARK: - Type-Safe Registration & Dequeue Helpers
public extension UICollectionView {
    func register<Cell: UICollectionViewCell>(_ cellClass: Cell.Type) {
        register(cellClass, forCellWithReuseIdentifier: Cell.id)
    }
    
    func dequeueReusableCell<Cell: UICollectionViewCell>(_ cellClass: Cell.Type, for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: Cell.id, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with identifier: \(Cell.id)")
        }
        return cell
    }
}

public extension UITableView {
    func register<Cell: UITableViewCell>(_ cellClass: Cell.Type) {
        register(cellClass, forCellReuseIdentifier: Cell.id)
    }
    
    func dequeueReusableCell<Cell: UITableViewCell>(_ cellClass: Cell.Type, for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: Cell.id, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with identifier: \(Cell.id)")
        }
        return cell
    }
}
