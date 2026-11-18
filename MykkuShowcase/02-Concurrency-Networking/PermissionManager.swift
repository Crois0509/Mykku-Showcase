//
//  PermissionManager.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 6/23/26.
//

import Foundation
import AVFoundation
import Photos
import UIKit

public enum PermissionType: String, CaseIterable, Sendable {
    case camera = "카메라 (Camera)"
    case photoLibrary = "사진첩 (PhotoLibrary)"
}

/// 카메라 및 사진첩 접근 권한 확인과 비동기 요청을 추상화한 프로토콜
public protocol PermissionManagable: Sendable {
    func isGranted(for type: PermissionType) -> Bool
    func requestPermission(for type: PermissionType) async -> Bool
}

/// async/await 기반 시스템 미디어 권한 매니저
/// - UI 계층에서 AVFoundation / Photos 프레임워크 의존성을 완전히 분리
/// - iOS의 부분 사진 접근 허용(`.limited`) 상태까지 세밀하게 판별하여 일관된 권한 UX 제공
public final class PermissionManager: PermissionManagable {
    
    public init() {}
    
    public func isGranted(for type: PermissionType) -> Bool {
        switch type {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            return status == .authorized
            
        case .photoLibrary:
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            return status == .authorized || status == .limited
        }
    }
    
    public func isNotDetermined(for type: PermissionType) -> Bool {
        switch type {
        case .camera:
            return AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
        case .photoLibrary:
            return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .notDetermined
        }
    }
    
    public func requestPermission(for type: PermissionType) async -> Bool {
        guard !isGranted(for: type) else { return true }
        
        switch type {
        case .camera:
            return await AVCaptureDevice.requestAccess(for: .video)
            
        case .photoLibrary:
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return status == .authorized || status == .limited
        }
    }
    
    /// 앱 최초 실행 시 아직 결정되지 않은(.notDetermined) 카메라 및 사진첩 접근 권한을 확인 및 요청
    public func checkInitialPermissions() async {
        for type in PermissionType.allCases where isNotDetermined(for: type) {
            _ = await requestPermission(for: type)
        }
    }
    
    /// 권한이 미결정 상태이면 시스템 권한 팝업을 요청하고, 이미 결정된 상태(거부/제한/허용)이면 앱 설정 화면으로 이동
    @MainActor
    public func requestOrOpenSettings(for type: PermissionType) async -> Bool {
        if isNotDetermined(for: type) {
            return await requestPermission(for: type)
        } else {
            openAppSettings()
            return isGranted(for: type)
        }
    }
    
    @MainActor
    public func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}
