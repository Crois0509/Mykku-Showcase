# <img width="30" height="30" alt="icon" src="https://github.com/user-attachments/assets/7a2de3eb-9014-45ae-9e36-717d7706b675" /> MYKKU (마이꾸) - iOS


<!-- [IMAGE: 앱 대표 로고 및 메인 배너] -->
<img width="100%" alt="Title Logo" src="https://github.com/user-attachments/assets/49ed83a2-2451-4c66-b25e-00a9ac2d8f0e" />

<p align="left">
  <b>나만의 감성으로 기록하고 공유하는 팬덤 아카이빙 & 커뮤니티 플랫폼</b><br>
  다양한 이벤트/콘테스트 아카이브, 팬노트 뷰어, 실시간 커뮤니티 및 칭호 리워드 시스템
</p>

<p align="left">
  <img src="https://img.shields.io/badge/iOS-16.0+-black?style=for-the-badge&logo=apple" alt="iOS 16.0+" />
  <img src="https://img.shields.io/badge/Swift-5.10+-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 5.10+" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture%20%2B%20MVI--C-4A90E2?style=for-the-badge" alt="Architecture" />
  <img src="https://img.shields.io/badge/Tools-Tuist%20%7C%20Mise-blueviolet?style=for-the-badge" alt="Tuist" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
</p>

---

## 📌 Executive Summary

| 항목 | 내용 |
| :--- | :--- |
| **개발 기간** | 2025.10 ~ 2026.11 (기반 설계부터 릴리즈 안정화까지 지속 운영) |
| **담당 역할** | **iOS Lead & Core Architecture** (Jang Sang-gyeong / [@Crois0509](https://github.com/Crois0509))<br>• Clean Architecture + MVI-C 아키텍처 토대 설계<br>• Swift Concurrency & Moya 기반 토큰 세션 매니저 (`TokenRefreshProxy`) 구축<br>• UIKit-SwiftUI 하이브리드 네비게이션 및 전역 UIWindow 팝업 시스템 개발<br>• DiffableDataSource 및 Combine 파이프라인 렌더링/동시성 성능 최적화 |
| **팀 구성** | iOS 클라이언트 2명, 백엔드 1명, UI/UX 디자이너 3명 |
| **주요 링크** | [App Store 바로가기](https://apps.apple.com/app/id6756611507) \| [시연 영상 (Notion)](https://alert-okra-cb5.notion.site/MYKKU-41a618d04750807c8daad8b1dd840471?source=copy_link) |

> [!NOTE]
> 본 Repository는 MYKKU 앱의 핵심 아키텍처 및 UI만 가져온 Showcase Repository 입니다.
> 프로젝트 빌드 시 실제 MYKKU 앱의 화면이 아닌 앱의 핵심 기능을 보여주는 대시보드 앱이 실행됩니다.

---

## 📱 UI Preview & Features

### 🎬 주요 인터랙션 시연

| Carousel UI | 캘린더 방향성 슬라이드 전환 | 댓글 목록 UI 및 낙관적 업데이트 | 전역 독립 윈도우 칭호 팝업 |
| :---: | :---: | :---: | :---: |
| <img width="360" height="720" alt="Carousel" src="https://github.com/user-attachments/assets/2cb5acf0-ffa7-4769-9ed9-de64befc0827" /> | <img width="360" height="720" alt="Calendar" src="https://github.com/user-attachments/assets/fd61dc65-e068-4007-b829-f88c5ae16175" /> | <img width="360" height="720" alt="Comment" src="https://github.com/user-attachments/assets/e0f344d6-934b-47c5-9fa2-279b1bc48e20" /> | <img width="360" height="720" alt="Alert" src="https://github.com/user-attachments/assets/923e71db-82ea-4539-8cef-5794aa632578" /> |
| 드래그 변위(@GestureState)와 가속도에 따른 커스텀 Carousel | 스와이프 제스처 및 방향 인식 push 트랜지션 | 실시간 댓글/답글 및 낙관적 유저 차단 시스템 | 뷰 계층 전환에 구애받지 않는 독립 Window 리워드 |

---

### 🧩 도메인별 기능 목록

|컨텐츠|커뮤니티|담벼락/MY|공통/인프라|
| :----- | :----- | :----- | :----- |
| • 월간/주간 달력 |• 게시판 피드 |• 획득 칭호 관리 |• 토큰 자동 갱신|
|• 이벤트/콘테스트|• 댓글 및 대댓글 |• 수상 콘테스트  |• 오프라인 가드  |
|• 팬노트(FanNote)|• 낙관적 좋아요  |• 작성 글 관리   |• 전역 에러 제어 |
|• 수상작 아카이브|• 유저 차단/신고 |• 프로필 편집    |• 임시 저장 보호 |

1. **컨텐츠 (Contents & Events)**
   - **이벤트/콘테스트 캘린더**: 월별/주별 일정 확인, 스와이프 및 상단 인디케이터 기반 월 이동, 수상작 캐러셀 뷰어.
   - **팬노트 (FanNote)**: 반응형 그리드 뷰 및 커스텀 제스처 툴바가 탑재된 전용 팬노트 뷰어.
   - **하루덕담 (DailyMSG)**: 매일 업데이트되는 덕담 카드 및 실시간 댓글/답글 시스템.
  
     
2. **커뮤니티 (Community)**
   - **피드 목록 및 상세**: 태그/카테고리별 필터링, 이미지 다중 첨부, 실시간 검색.
   - **인라인 글 작성기**: 임시저장(Draft) 자동 카운트 뱃지, 즉각적인 포커스 전환 모핑 태그 칩 입력.
   - **안심 인터랙션**: 악성 유저 즉시 차단(로컬 낙관적 필터링) 및 도메인 분리 신고(Report) 파이프라인.
  
     
3. **마이페이지 & 담벼락 (MyPage & Wall)**
   - 획득한 칭호 리스트 실시간 확인 및 대표 칭호 설정.
   - 내가 작성한 글/댓글 모아보기, 수상 내역 아카이빙.

---

## 🛠 Tech Stack & Architecture

### 1. Technology Matrix

| 분류 | 기술 스택 | 도입 사유 (Why) |
| :--- | :--- | :--- |
| **Language** | `Swift 5.10+` | 엄격한 타입 안정성 및 모던 Concurrency 모델 활용 |
| **UI Framework** | `SwiftUI` & `UIKit` | 선언형 UI의 빠른 생산성 + 고성능 Diffable/Gesture 제어 역량 상호 보완 |
| **Architecture** | `Clean Architecture` + `MVI-C` | 비즈니스 로직과 UI의 명확한 격리, 단방향 상태 흐름(Unidirectional Flow) 구축 |
| **Concurrency** | `Swift Concurrency` (`async/await`, `actor`) | Data Race 없는 안전한 스레드 격리 및 직렬화된 비동기 세션 관리 |
| **Reactive** | `Combine` | UIKit 이벤트와 SwiftUI State 간의 선언형 바인딩 및 이벤트 스로틀링 |
| **Networking** | `Moya` + `Alamofire` | TargetType 열거형 기반 엔드포인트 타입 안정성 및 인터셉터 기반 세션 갱신 |
| **Image Pipeline** | `Kingfisher` | 화면 크기 맞춤형 다운샘플링(`DownsamplingProcessor`) 및 스크롤 이탈 다운로드 즉시 취소 |
| **Modularity & Build** | `Tuist` | 일관된 개발 환경 구성 및 Xcode 프로젝트 파일 충돌(Merge Conflict) 원천 방지 |

---

### 2. Architecture & Unidirectional Data Flow

MYKKU는 화면 제어를 담당하는 **Coordinator**, 단방향 상태 머신인 **Store(MVI)**, 비즈니스 규칙을 품은 **UseCase**, 그리고 원격/로컬 데이터를 공급하는 **Repository** 계층으로 철저히 분리되어 있습니다.

<img width="1038" height="3401" alt="mermaid-diagram-2026-11-17-145555" src="https://github.com/user-attachments/assets/8f3af072-1354-411d-b111-65d92a80b838" />

---

## 🚀 Technical Challenges & Troubleshooting (핵심 기여)

### 1. 동시 다발 401 Unauthorized 환경에서의 안전한 토큰 갱신 (`TokenRefreshProxy`)

- **Problem (문제)**: 
  - 여러 화면의 컬렉션 뷰 셀과 피드가 병렬로 API를 호출할 때(`async let` 또는 동시 네트워크 요청), Access Token이 만료되면 다수의 401 응답이 거의 같은 밀리초 단위로 발생.
  - 이로 인해 토큰 재발급 API가 중복으로 호출되어 Refresh Token 회전(Rotation) 정책에 의해 세션이 파기되거나, 멀티스레드 환경에서 레이스 컨디션(Data Race)이 발생하는 문제 확인.
- **Action (해결)**:
  - Alamofire의 `RequestInterceptor`를 Moya Provider에 연결하고, 재발급 상태를 스레드 안전하게 격리하는 **Swift `actor TokenRefreshProxy`** 를 설계.
  - 진행 중인 갱신 `Task`가 존재할 경우 새 요청을 보내지 않고 **동일한 Task를 `await`하도록 공유**하여 단 한 번의 토큰 갱신만 수행되도록 직렬화.
  - DIContainer ↔ NetworkManager ↔ AuthRepository 간의 순환 참조를 제거하기 위해 인터셉터 갱신 클로저를 의존성 역전(DIP)으로 주입.

```swift
// TokenRefreshProxy.swift (일부)
actor TokenRefreshProxy {
    private var refreshTask: Task<String, Error>?
    
    func refreshToken(using authRepository: AuthRepository) async throws -> String {
        // 이미 갱신 중인 Task가 있다면 중복 요청 없이 해당 Task의 결과를 공유 대기
        if let existingTask = refreshTask {
            return try await existingTask.value
        }
        
        let task = Task { () -> String in
            defer { self.refreshTask = nil }
            let response = try await authRepository.refreshAccessToken()
            return response.accessToken
        }
        
        self.refreshTask = task
        return try await task.value
    }
}
```

- **Result (성과)**:
  - 동시 다발적인 401 오류 상황에서도 토큰 갱신 API 호출 횟수를 **정확히 1회로 보장**.
  - 비동기 레이스 컨디션 및 토큰 불일치 크래시 **0건 달성**.

---

### 2. 뷰 라이프사이클에 종속되지 않는 전역 팝업 (`GlobalAlertManager`)

- **Problem (문제)**:
  - 칭호 획득 알림은 사용자의 모든 활동(댓글 작성, 출석, 게시글 등록 등) 직후 비동기로 도달함.
  - 기존의 SwiftUI `.overlay`나 `.sheet` 방식은 사용자가 알림 수신 직후 이전 화면으로 네비게이션 팝을 하거나 다른 탭으로 이동하면 **모달이 즉시 강제 dismiss되어 보상 피드백이 누락**되는 치명적인 UX 문제 발생.
- **Action (해결)**:
  - SwiftUI 계층 구조를 탈피하여 `UIWindowScene` 상위에 **`.alert + 1` 윈도우 레벨을 갖는 독립 `UIWindow`** 를 생성하고 `UIHostingController`로 주입하는 `GlobalAlertManager` 싱글톤 아키텍처 설계.
  - 사용자가 뒤로 가기, 시트 닫기, 탭 전환을 하더라도 최상단 윈도우에서 정해진 노출 시간 동안 보상 애니메이션이 온전히 동작한 후 자동 페이드아웃 되도록 보장.

```swift
// GlobalAlertManager.swift (일부)
func showAlert(roleInfo: MyRoleInfo?, for second: CGFloat) {
    guard let roleInfo,
          let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
    
    let window = UIWindow(windowScene: windowScene)
    window.windowLevel = .alert + 1 // 시스템 Alert보다 상위 레이어에 독립 배치
    window.backgroundColor = .clear
    
    let hostingController = UIHostingController(
        rootView: GlobalRoleAlertView(role: roleInfo, showingTime: second) { [weak self] in
            self?.hideAlert()
        }
    )
    hostingController.view.backgroundColor = .clear
    window.rootViewController = hostingController
    window.isHidden = false
    self.alertWindow = window
}
```

- **Result (성과)**:
  - 네비게이션 스택이나 모달 상태 변화와 완전히 독립된 **100% 신뢰성 있는 전역 보상 피드백 UX 확보**.

---

### 3. DiffableDataSource 중복 렌더링 제거 및 Combine 탭 스로틀링

- **Problem (문제)**:
  - Store의 `@Published state`가 변경될 때마다 화면과 무관한 속성 변화에도 `applySnapShot`이 호출되어 불필요한 Diff 연산과 컬렉션 뷰 버벅임(Frame Drop) 발생.
  - 사용자의 빠른 버튼 연타 시 중복 화면 전환(`push`) 및 중복 네트워크 패킷 발생.
- **Action (해결)**:
  - **`removeDuplicates(by:)`**: 컬렉션 뷰 바인딩 파이프라인에 실제 데이터 항목의 동일성을 비교하는 연산자를 배치하여 의미 있는 데이터 변경 시에만 스냅샷 재계산.
  - **`+UIControl tapPublisher`**: UIKit 버튼 전역에 1초 스로틀링(`throttle(for: 1.0, scheduler: RunLoop.main, latest: false)`)이 내장된 반응형 스트림을 구현하여 중복 탭 원천 방어.
  - **`@MainActor` 격리**: 백그라운드 태스크 완료 후 State 변경 시 발생하던 Xcode Purple Warning(메인 스레드 위반)을 방어하기 위해 모든 View/Store 업데이트 경로에 `@MainActor` 명시.

```swift
// ContentsMyWinningViewController.swift (일부)
store.$state
    .removeDuplicates(by: { $0.myWinningContest == $1.myWinningContest }) // 중복 스냅샷 방지
    .sink { [weak self] state in
        self?.applySnapShot(state.myWinningContest)
    }
    .store(in: &cancellables)
```

- **Result (성과)**:
  - 불필요한 컬렉션 뷰 재연산 제거로 고속 스크롤 중에도 **안정적인 60fps 유지**.
  - 비동기 상태 변경 시 메인 스레드 위반 이슈 100% 해소.

---

## 📂 Directory Structure

```text
MYKKU/
├── Projects/
│   └── MYKKU/
│       ├── Project.swift                 # Tuist 프로젝트 매니페스트
│       └── Project/
│           ├── MYKKU-iOS/
│           │   ├── App/                  # App 진입점 및 LifeCycle
│           │   ├── Common/               # 공통 확장, 유효성 검사기, LocalStorage, Keychain
│           │   ├── Component/            # 재사용 컴포넌트 (StickyButton, CardStack, Toast 등)
│           │   ├── Configs/              # Version & Secrets xcconfig
│           │   ├── Coordinator/          # BaseCoordinator 및 탭별 화면 전환 관리자
│           │   │   ├── App/              # AppCoordinator & StoreContainer
│           │   │   ├── Contents/         # 컨텐츠 탭 라우팅
│           │   │   ├── Community/        # 커뮤니티 탭 라우팅
│           │   │   └── MyPage/           # 마이페이지 탭 라우팅
│           │   ├── Data/                 # Moya API Target, DTO, AuthInterceptor
│           │   ├── Domain/               # Entity, UseCase, Repository Protocol
│           │   ├── DIContainer/          # Mock/Network 모드 지원 의존성 주입 컨테이너
│           │   ├── Presentation/         # 화면 뷰 및 MVI Store (Contents, Community, MyPage 등)
│           │   └── Resources/            # 에셋, 폰트, 다국어 리소스
│           ├── MYKKU-iOSTests/           # 단위 테스트 및 Mock Repository 검증
│           └── MYKKU-iOSUITests/         # UI 자동화 테스트
├── Tuist/                                # Tuist 설정 및 디펜던시 정의
├── Workspace.swift                       # Tuist 워크스페이스 정의
├── Makefile                              # 프로젝트 세팅 자동화 명령어
└── README.md
```

---

## ⚡ Getting Started (빌드 및 실행 가이드)

### 1. Prerequisites (선행 조건)

- **macOS**: Sonoma 14.0 이상 권장
- **Xcode**: 15.0 이상 (Swift 5.10 지원)

### 2. Generate & Run Project

설치된 폴더에서 `.xcodeproj` 파일을 실행하여 프로젝트를 열고,
`cmd + R` 혹은 직접 실행 버튼을 눌러 프로젝트를 실행할 수 있습니다.

---
