//
//  ReportView.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 9/28/26.
//

import SwiftUI

/// 글자 수 카운터 및 포커스 테두리가 내장된 다중 라인 텍스트 필드 스타일
public struct ContentTextFieldStyle: TextFieldStyle {
    var focusState: FocusState<Bool>.Binding
    let currentLength: Int
    let maxLength: Int
    
    public func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            configuration
                .focused(focusState)
                .font(.pretendard(of: .regular, size: 14))
                .multilineTextAlignment(.leading)
            
            HStack {
                Spacer()
                Text("\(currentLength)/\(maxLength)")
                    .font(.pretendard(of: .regular, size: 11))
                    .foregroundStyle(currentLength < maxLength ? Color.gray600 : Color.red600)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.gray50)
                .overlay {
                    if focusState.wrappedValue {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(lineWidth: 1)
                            .fill(Color.gray200)
                    }
                }
        )
    }
}

/// Clean Architecture + MVI 패턴이 결합된 신고하기 Presentation View
public struct ReportView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var store: ReportStore
    
    @State private var reportReasonList: [ReportReason] = []
    @State private var selectIndex: Int? = nil
    @State private var reportDetail: String = ""
    @State private var isEditing: Bool = false
    
    @State private var isShowingCheckAlert: Bool = false
    @State private var isShowingResultAlert: Bool = false
    @State private var resultAlertTitle: String = ""
    @State private var resultAlertMessage: String = ""
    
    @FocusState private var reportDetailFocus: Bool
    
    let reportType: ReportTargetType
    let reportId: Int
    
    private var reportTitle: String {
        if isEditing, let idx = selectIndex, idx < reportReasonList.count {
            return reportReasonList[idx].description
        } else {
            switch reportType {
            case .feed:
                return "해당 피드를 신고하는 이유를 선택해 주세요."
            default:
                return "해당 댓글을 신고하는 이유를 선택해 주세요."
            }
        }
    }
    
    private var reportDescription: String {
        if isEditing {
            return ""
        } else {
            switch reportType {
            case .feed:
                return "신고자의 정보는 상대방에게 공개되지 않습니다.\n신고 내용은 운영정책에 따라 검토되며,\n신고만으로 피드가 즉시 삭제되지는 않습니다."
            default:
                return "신고자의 정보는 상대방에게 공개되지 않습니다.\n신고 내용은 운영정책에 따라 검토되며,\n신고만으로 댓글이 즉시 삭제되지는 않습니다."
            }
        }
    }
    
    public init(type: ReportTargetType, id: Int, store: ReportStore) {
        self.reportType = type
        self.reportId = id
        self._store = StateObject(wrappedValue: store)
    }
    
    public var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 28) {
                VStack(spacing: 8) {
                    Text(reportTitle)
                        .font(.pretendard(of: .bold, size: 16))
                        .foregroundStyle(Color.blackApp)
                        .multilineTextAlignment(.center)
                    
                    if !reportDescription.isEmpty {
                        Text(reportDescription)
                            .font(.pretendard(of: .regular, size: 12))
                            .foregroundStyle(Color.gray600)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4.8)
                    }
                }
                
                if isEditing {
                    VStack(alignment: .trailing, spacing: 12) {
                        TextField("신고 상세 내용을 최소 10자 이상 작성해 주세요.", text: $reportDetail, axis: .vertical)
                            .textFieldStyle(
                                ContentTextFieldStyle(
                                    focusState: $reportDetailFocus,
                                    currentLength: reportDetail.count,
                                    maxLength: 500
                                )
                            )
                            .lineLimit(3...10)
                        
                        HStack {
                            Button("사유 다시 선택") {
                                withAnimation {
                                    reportDetail = ""
                                    selectIndex = nil
                                    isEditing = false
                                }
                            }
                            .font(.pretendard(of: .medium, size: 14))
                            .foregroundStyle(Color.gray600)
                            
                            Spacer()
                            
                            Button {
                                isShowingCheckAlert = true
                            } label: {
                                Text("작성 완료")
                                    .font(.pretendard(of: .bold, size: 14))
                                    .foregroundStyle(Color.black)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                            }
                            .background(Color.green200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(Array(reportReasonList.enumerated()), id: \.offset) { index, reason in
                                Button {
                                    withAnimation {
                                        selectIndex = index
                                        isEditing = true
                                        reportDetailFocus = true
                                    }
                                } label: {
                                    HStack {
                                        Text(reason.description)
                                            .font(.pretendard(of: .regular, size: 14))
                                            .foregroundStyle(Color.blackApp)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(Color.gray400)
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 20)
                                }
                                .background(Color.gray50)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                    .zIndex(1)
                }
                
                Spacer()
            }
            .padding([.top, .horizontal], 20)
            
            if store.state.isLoading {
                Color.black.opacity(0.15).ignoresSafeArea()
                ProgressView("처리 중...")
                    .padding(20)
                    .background(Color.whiteApp)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 6)
            }
        }
        .navigationTitle("신고하기")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.3), value: isEditing)
        .task {
            store.send(.getReportReasonList)
        }
        .onReceive(store.$state) { state in
            reportReasonList = state.reasonList
            
            if state.reportSuccess == true {
                resultAlertTitle = "신고 완료"
                resultAlertMessage = "신고가 정상적으로 접수되었습니다.\n확인 후 필요한 조치를 진행할게요."
                isShowingResultAlert = true
            } else if state.reportSuccess == false {
                resultAlertTitle = "신고 실패"
                resultAlertMessage = state.errorState?.message ?? "문제가 발생했습니다.\n잠시 후 다시 시도해 주세요."
                isShowingResultAlert = true
            }
        }
        .onDisappear {
            store.send(.setReportResult(nil))
            store.send(.setError(nil))
        }
        .onTapGesture { hideKeyboard() }
        .alert(Text("신고 확인"), isPresented: $isShowingCheckAlert) {
            Button("취소", role: .cancel) { isShowingCheckAlert = false }
            Button("확인", role: .destructive) {
                guard let idx = selectIndex,
                      idx < reportReasonList.count,
                      let reason = ReportReasonType(rawValue: reportReasonList[idx].reason) else {
                    resultAlertTitle = "신고 실패"
                    resultAlertMessage = "신고 사유를 확인할 수 없습니다."
                    isShowingResultAlert = true
                    return
                }
                
                store.send(.report(ReportInfo(
                    type: reportType,
                    id: reportId,
                    reason: reason,
                    detail: reportDetail
                )))
            }
        } message: {
            Text("선택한 사유로 신고하시겠습니까?\n신고된 내용은 운영정책에 따라 검토됩니다.")
        }
        .alert(Text(resultAlertTitle), isPresented: $isShowingResultAlert) {
            Button("확인", role: .cancel) {
                isShowingResultAlert = false
                if store.state.reportSuccess == true {
                    dismiss()
                } else {
                    store.send(.setReportResult(nil))
                    store.send(.setError(nil))
                }
            }
        } message: {
            Text(resultAlertMessage)
        }
    }
}
