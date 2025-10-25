# 오늘의 질문 (Daily Question)

> 매일의 성찰을 통한 자기계발 - 스마트 알림 기반 일일 질문 응답 플랫폼

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 프로젝트 개요

**오늘의 질문**은 사용자의 일상적인 성찰과 자기 인식을 돕는 모바일 애플리케이션입니다. 백그라운드 알림 시스템을 활용하여 사용자가 앱을 떠난 후에도 정기적으로 질문을 푸시하고, 다양한 형태의 답변(텍스트, 진행도)을 수집하여 개인의 성장 과정을 추적합니다.

### 핵심 가치 제안

- **지속적인 사용자 인게이지먼트**: 앱 백그라운드 상태에서도 10초 후 자동 알림 발송
- **다양한 답변 형식 지원**: 텍스트 기반 답변과 진행도(0-100%) 답변 타입 제공
- **완전한 오프라인 퍼스트 아키텍처**: 로컬 스토리지 기반으로 네트워크 없이 완벽 작동
- **경량화된 데이터 구조**: JSON 기반 질문 관리로 손쉬운 확장성 확보
- **직관적인 UX/UI**: Material Design 3 기반의 모던하고 깔끔한 인터페이스

## 주요 기능

### 1. 실시간 알림 시스템
- **WorkManager 기반 백그라운드 작업**: 앱 생명주기와 독립적으로 작동
- **스마트 트리거링**: 앱이 백그라운드로 전환 시 10초 후 자동 알림
- **고도화된 알림 채널**: Android 13+ 권한 요청 및 채널 관리

### 2. 유연한 질문-답변 시스템
- **타입 기반 질문 분류**: Text / Progress 타입으로 구분
- **동적 질문 로딩**: Asset 기반 JSON 파일에서 런타임 로딩
- **확장 가능한 데이터 모델**: 새로운 질문 타입 추가 용이

### 3. 히스토리 & 분석
- **타임라인 기반 답변 히스토리**: 날짜/시간별 답변 추적
- **시각화된 진행도 표시**: 프로그레스 바를 통한 직관적 정보 전달
- **즉각적인 데이터 동기화**: SharedPreferences 기반 실시간 저장

### 4. 사용자 경험 최적화
- **풀 다운 리프레시**: 질문 및 히스토리 새로고침
- **상태 기반 UI**: Loading, Empty, Error 상태 세밀한 처리
- **접근성 고려**: Tooltip, Semantic 라벨 등 다양한 접근성 기능

## 기술 스택

### 프레임워크 & 언어
- **Flutter 3.8.1**: Cross-platform UI 프레임워크
- **Dart 3.8.1**: 최신 언어 기능 활용 (Null Safety, Pattern Matching 등)

### 핵심 패키지

| 패키지 | 버전 | 용도 |
|--------|------|------|
| `flutter_local_notifications` | 17.0.0 | 로컬 푸시 알림 관리 |
| `workmanager` | 0.9.0 | 백그라운드 작업 스케줄링 |
| `shared_preferences` | 2.2.2 | Key-Value 기반 로컬 저장소 |
| `intl` | 0.19.0 | 날짜/시간 포맷팅 및 국제화 |

## 프로젝트 구조

```
hackerthon/
├── lib/
│   ├── main.dart                    # 앱 진입점 및 전역 설정
│   ├── models/                      # 데이터 모델 레이어
│   │   ├── question.dart            # 질문 모델 & 타입 Enum
│   │   └── answer.dart              # 답변 모델
│   ├── services/                    # 비즈니스 로직 & 인프라 레이어
│   │   ├── question_service.dart   # 질문 관리 서비스 (Singleton)
│   │   ├── storage_service.dart    # 로컬 스토리지 추상화 (Singleton)
│   │   └── notification_service.dart # 알림 & 백그라운드 작업 (Singleton)
│   ├── screens/                     # 화면 컴포넌트
│   │   ├── home_screen.dart         # 질문 목록 화면
│   │   ├── answer_screen.dart       # 답변 작성 화면
│   │   └── history_screen.dart      # 답변 히스토리 화면
│   └── widgets/                     # 재사용 가능한 UI 컴포넌트
│       ├── text_answer_widget.dart  # 텍스트 답변 입력 위젯
│       └── progress_answer_widget.dart # 진행도 슬라이더 위젯
├── assets/
│   └── questions.json               # 질문 데이터 (설정 파일)
├── android/                         # Android 네이티브 설정
├── pubspec.yaml                     # 의존성 관리
└── docs/                           # 프로젝트 문서
    ├── ARCHITECTURE.md              # 아키텍처 설계 문서
    ├── API.md                       # 서비스 레이어 API 문서
    └── DEVELOPMENT.md               # 개발 환경 설정 가이드
```

## 빠른 시작

### 사전 요구사항
- Flutter SDK 3.8.1 이상
- Dart SDK 3.8.1 이상
- Android Studio / VS Code + Flutter 플러그인
- Android SDK (API 21+) 또는 iOS 개발 환경

### 설치 및 실행

```bash
# 1. 저장소 클론
git clone <repository-url>
cd hackerthon

# 2. 의존성 설치
flutter pub get

# 3. 연결된 디바이스 확인
flutter devices

# 4. 앱 실행
flutter run

# 5. 프로덕션 빌드
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### 개발 모드 실행

```bash
# Hot Reload 활성화 개발 모드
flutter run --debug

# 특정 디바이스 지정
flutter run -d <device-id>

# Profile 모드 (성능 분석)
flutter run --profile
```

## 아키텍처 하이라이트

### 싱글톤 패턴 기반 서비스 레이어
모든 서비스 클래스는 싱글톤 패턴으로 구현되어 앱 전체에서 단일 인스턴스를 공유합니다.

```dart
// 예시: QuestionService 접근
final questions = QuestionService.instance.getAllQuestions();
```

### 상태 관리
- **StatefulWidget 기반**: 화면 단위 로컬 상태 관리
- **setState 패턴**: 단순하고 예측 가능한 UI 업데이트
- **Future 기반 비동기 처리**: async/await로 깔끔한 비동기 코드

### 데이터 흐름

```
[Asset JSON] → QuestionService → [UI: HomeScreen]
                                         ↓
                                  [User Input]
                                         ↓
                                  AnswerScreen
                                         ↓
                                  StorageService → [SharedPreferences]
                                         ↓
                                  [UI: HistoryScreen]
```

## 확장 가능성

### 새로운 질문 타입 추가

1. `models/question.dart`에서 `QuestionType` enum 확장
2. `widgets/` 디렉토리에 새로운 답변 위젯 생성
3. `screens/answer_screen.dart`에서 타입별 분기 처리
4. `assets/questions.json`에 새 타입 질문 추가

### 백엔드 연동

현재는 완전히 로컬 기반이지만, 다음과 같이 확장 가능:

- `services/api_service.dart` 생성하여 REST API 통신 레이어 추가
- `StorageService`를 캐시 레이어로 활용
- `QuestionService`에서 서버 동기화 로직 구현

### 분석 및 인사이트

- 답변 데이터를 기반으로 통계 화면 추가
- Chart 라이브러리 (fl_chart 등) 연동
- 진행도 타입 답변의 시계열 분석

## 성능 최적화

- **Lazy Loading**: 질문 데이터는 필요 시에만 로드
- **효율적인 리스트 렌더링**: `ListView.builder` 사용
- **최소한의 리빌드**: `const` 생성자 적극 활용
- **경량 데이터 구조**: JSON 직렬화/역직렬화 최적화

## 테스팅

```bash
# 단위 테스트 실행
flutter test

# 통합 테스트 (향후 추가 예정)
flutter test integration_test

# 커버리지 리포트 생성
flutter test --coverage
```

## 기여 가이드

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 연락처

프로젝트 관련 문의: [이메일 주소]

프로젝트 링크: [GitHub Repository URL]

---

**Made with Flutter & Love** | Hackathon 2025
