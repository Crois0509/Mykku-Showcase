//
//  DefaultReportRepository.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 9/29/26.
//

import Foundation

// MARK: - Data Transfer Objects (DTO)
public struct ReportRequest: Encodable, Sendable {
    public let targetType: ReportTargetType
    public let targetId: Int
    public let reason: ReportReasonType
    public let detail: String
}

public struct GetReportsReasonListResponse: Decodable, Sendable {
    public let reason: ReportReasonType
    public let description: String
    
    /// DTO를 도메인 Entity로 매핑하여 계층 오염 방지
    public func toEntity() -> ReportReason {
        ReportReason(
            reason: reason.rawValue,
            description: description
        )
    }
}

// MARK: - API Router
public enum ReportRouter: NetworkTargetType {
    case reportContents(dto: ReportRequest)
    case getReportList
    
    public var baseURL: URL {
        URL(string: "https://api.mykku-showcase.example.com")!
    }
    
    public var path: String {
        switch self {
        case .reportContents:
            return "/api/v1/reports"
        case .getReportList:
            return "/api/v1/reports/reasons"
        }
    }
    
    public var method: String {
        switch self {
        case .reportContents: return "POST"
        case .getReportList: return "GET"
        }
    }
    
    public var task: NetworkTask {
        switch self {
        case .reportContents(let dto):
            return .requestJSONEncodable(dto)
        case .getReportList:
            return .requestPlain
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}

// MARK: - Network Repository Implementation (Data Layer)
public final class DefaultReportRepository: ReportRepository {
    
    private let networkManager: any NetworkManager
    
    public init(networkManager: any NetworkManager) {
        self.networkManager = networkManager
    }
    
    public func reportContent(
        type: ReportTargetType,
        id: Int,
        reason: ReportReasonType,
        detail: String
    ) async throws(AppError) {
        do {
            let request = ReportRequest(
                targetType: type,
                targetId: id,
                reason: reason,
                detail: detail
            )
            try await networkManager.request(
                ReportRouter.reportContents(dto: request),
                of: EmptyResponse.self
            )
        } catch {
            throw .default(error.message)
        }
    }
    
    public func getReportReasonList() async throws(AppError) -> [ReportReason] {
        do {
            let response = try await networkManager.request(
                ReportRouter.getReportList,
                of: BaseResponse<[GetReportsReasonListResponse]>.self
            )
            return response.data.map { $0.toEntity() }
        } catch {
            throw .default(error.message)
        }
    }
}
