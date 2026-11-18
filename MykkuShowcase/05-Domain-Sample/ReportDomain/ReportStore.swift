//
//  ReportStore.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 9/29/26.
//

import Foundation

/// 신고 화면의 단일 불변 상태 (Single Source of Truth)
public struct ReportState {
    public var isLoading: Bool = false
    public var errorState: AppError? = nil
    public var reasonList: [ReportReason] = []
    public var reportSuccess: Bool? = nil
}

/// 뷰에서 Store로 전달하는 단방향 의도(Intent)
public enum ReportIntent {
    case setLoading(Bool)
    case setError(AppError?)
    case getReportReasonList
    case report(ReportInfo)
    case setReportResult(Bool?)
}

/// MVI 패턴 기반 신고 상태 머신
/// - `@MainActor` 격리를 통해 비동기 작업 후 상태 변이 시 메인 스레드 안전성 보장
@MainActor
public final class ReportStore: Store {
    @Published public var state = ReportState()
    private let useCase: any ReportUseCase
    
    public init(useCase: any ReportUseCase) {
        self.useCase = useCase
    }
    
    public func send(_ intent: ReportIntent) {
        switch intent {
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            
        case .setError(let error):
            state.errorState = error
            
        case .getReportReasonList:
            Task {
                send(.setLoading(true))
                do {
                    let result = try await useCase.fetchReportReasons()
                    state.reasonList = result
                    send(.setLoading(false))
                } catch let error as AppError {
                    send(.setLoading(false))
                    send(.setError(error))
                } catch {
                    send(.setLoading(false))
                    send(.setError(.default(error.localizedDescription)))
                }
            }
            
        case .report(let reportInfo):
            Task {
                send(.setLoading(true))
                do {
                    try await useCase.submitReport(reportInfo)
                    send(.setReportResult(true))
                    send(.setLoading(false))
                } catch let error as AppError {
                    send(.setLoading(false))
                    send(.setError(error))
                    send(.setReportResult(false))
                } catch {
                    send(.setLoading(false))
                    send(.setError(.default(error.localizedDescription)))
                    send(.setReportResult(false))
                }
            }
            
        case .setReportResult(let result):
            state.reportSuccess = result
        }
    }
}
