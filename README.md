# 📱 WeBooks Frontend (Flutter)

> **Flutter 학습을 목표로 백엔드 API와 연동하여 구현한 중고책 거래 모바일 앱**

---

## 📌 프로젝트 목적

본 프로젝트는 **Flutter 프레임워크 학습**과  
**백엔드 API와 연동되는 모바일 애플리케이션 구조 이해**를 목표로 진행했습니다.

UI/기능의 일부는 기존 예제나 레퍼런스를 참고했지만,  
다음 영역은 **직접 설계·구현하며 Flutter 사용 경험을 쌓는 데 집중**했습니다.

- Flutter 프로젝트 구조 설계
- 상태 관리(Riverpod) 적용
- REST API 연동 및 인증 흐름 구현
- 모바일 환경에서의 보안 처리 경험

---

## 🙋‍♂️ 담당 구현 범위 (직접 수행한 부분)

### ✅ 1. 소셜 로그인 연동 및 인증 흐름 구현
- Kakao / Google 로그인 SDK 연동
- 백엔드 인증 API와 연계한 로그인 플로우 구성
- JWT 기반 인증 처리
  - Access Token 자동 첨부
  - 만료 시 Refresh Token 재발급 요청
- 로그인 상태에 따른 화면 분기 처리

```dart
// Dio Interceptor를 활용한 인증 헤더 자동 주입
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }
}
```

### ✅ 2. Flutter 앱 구조 설계 (Clean Architecture 학습 적용)

Flutter 공식 문서와 커뮤니티 사례를 참고하여
기능 단위(feature 기반) 구조로 프로젝트를 설계했습니다.

```bash
lib/features/
├── auth/
│   ├── data/          # API 통신
│   ├── domain/        # 모델 정의
│   ├── application/   # 상태 관리 (Riverpod)
│   └── presentation/  # UI
├── books/
└── chat/
```
- Data Layer: Dio 기반 API 호출
- Domain Layer: 모델 정의 (json_serializable)
- Application Layer: Riverpod Provider로 상태 관리
- Presentation Layer: UI 렌더링

Flutter 앱을 “화면 단위”가 아닌
“기능 단위”로 나누는 경험을 목표로 구조를 설계

### ✅ 3. 상태 관리 및 API 연동 경험

- Riverpod을 사용한 상태 관리 적용
- 서버 Pagination API와 연동한 목록 조회
- 무한 스크롤 UI 구현 경험
- 검색/필터 조건 변경 시 상태 갱신 처리

```dart
Future<void> loadMoreBooks() async {
  if (state.isLoadingMore || !state.hasMore) return;

  final nextPage = state.currentPage + 1;
  final response = await bookApi.getBookList(page: nextPage);

  state = state.copyWith(
    books: [...state.books, ...response.results],
    currentPage: nextPage,
    hasMore: response.hasNext,
  );
}
```

### ✅ 4. 모바일 환경 보안 설정 경험
- `flutter_secure_storage`를 활용한 JWT 토큰 저장
- `.env` 파일을 통한 환경 변수 분리
- Android `local.properties`를 활용한 API Key 관리
- 민감 정보 Git 제외 설정 경험

---

## 🛠 사용 기술 (학습 및 적용 위주)
| Category         | Technologies              |
| ---------------- | ------------------------- |
| Framework        | Flutter                   |
| Language         | Dart                      |
| State Management | Riverpod                  |
| HTTP             | Dio                       |
| Auth             | Kakao SDK, Google Sign-In |
| Storage          | flutter_secure_storage    |
| Env              | flutter_dotenv            |

---

## 📱 구현 기능 요약
기능 자체보다 Flutter + API 연동 경험에 초점
- 소셜 로그인(카카오/구글)
- 인증 상태에 따른 화면 분기
- 책 목록 조회 (Pagination)
- 검색 및 필터 UI
- 기본 CRUD 화면 구성
- 채팅 화면 UI 및 API 연동

---

## 🌱 프로젝트를 통해 얻은 것
- Flutter 프로젝트 구조 설계 경험
- Riverpod 기반 상태 관리 이해
- 모바일 앱에서의 인증 흐름 구현 경험
- 백엔드 API와의 협업 및 연동 경험
- Flutter 공식 문서와 예제를 활용해 기능을 확장하는 방법 학습

---

## 📈 향후 학습 목표
- Widget / Unit 테스트 작성
- WebSocket 기반 실시간 채팅
- iOS 빌드 및 배포 경험
- Flutter 성능 최적화