# 프로젝트 개발 대화 로그

**프로젝트명**: 오늘의 질문 (Daily Question)
**작성일**: 2025-10-25
**목적**: 개발 과정에서 주고받은 모든 대화 내용 기록

---

## Phase 1: 프로젝트 기획 및 초기 설계

### 대화 1: 프로젝트 요청

**사용자**:
```
생산성 앱을 만들려고해 googleForm 과 기능적으로 유사하고 목적은 동기부여야.
입력된 질문들을 알림을 통해 물어봐주고 답변을 받도록 하는 앱을 만들고 싶어.
가장 중요한 기능은 1. 답변을 입력하는 기능이고 2. json파일로 질문을 가져오는 기능(추후 관리기능 개발).
3. 알림 기능이야. 심플한 poc가 중요하니까 과도한 추상화는 지양해줘.
 개발 계획 세워주고 부족한 정보가 있으면 다시 물어봐줘
```

**AI 응답**:
추가 정보 필요:
- 플랫폼 및 기술 스택?
- 알림 스케줄링 방식?
- 데이터 저장 방식?
- JSON 파일 구조?
- UI/UX 요구사항?

---

### 대화 2: 요구사항 상세화

**사용자**:
```
1. flutter 로 안드로이드만 개발할 거야.
2. 고정된 시간에 알림을 보낼 거야. 데모 테스트를 위해 앱이 백그라운드로 돌아가면
   10초뒤에 알림이 오게 해줘. 알림은 매 비활성화의 10초후에 오면될거 같아.
   질문으로 알림이 오지 않고 고정된 텍스트로 알림이 오면 될 거 같아.
3. 사용자의 답변은 로컬에 저장되고 우선은 db없이 shared_preference만을 사용해줘.
   여러 사용자를 고려하지 않고 개인용으로 생각해줘. 서버는 필요없어.
   답변 히스토리를 다시 보는 기능은 필요해.
4. json 형식은 딱 좋아.
5. 최소한의 깔끔한 ui로 해줘.
   답변타입은 텍스트와 프로그레스(0~100%) 두가지 타입이면 좋겠어
```

**AI 응답**:
개발 계획 제시:
- Flutter (Android only)
- SharedPreferences로 로컬 저장
- WorkManager로 백그라운드 알림
- 텍스트 & 프로그레스 답변 타입
- Material Design 3 기반 미니멀 UI

프로젝트 구조:
```
lib/
├── main.dart
├── models/
│   ├── question.dart
│   └── answer.dart
├── services/
│   ├── question_service.dart
│   ├── storage_service.dart
│   └── notification_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── answer_screen.dart
│   └── history_screen.dart
└── widgets/
    ├── text_answer_widget.dart
    └── progress_answer_widget.dart
```

---

## Phase 2: 초기 개발 및 구현

### 대화 3: 개발 진행

**사용자**: (계획 승인)

**AI 작업**:
1. ✅ pubspec.yaml 패키지 추가
   - shared_preferences: ^2.2.2
   - flutter_local_notifications: ^17.0.0
   - workmanager: ^0.5.2 (나중에 0.9.0으로 업그레이드)
   - intl: ^0.19.0

2. ✅ assets/questions.json 생성
```json
{
  "questions": [
    {
      "id": "q1",
      "text": "오늘의 목표는 무엇인가요?",
      "type": "text"
    },
    {
      "id": "q2",
      "text": "오늘의 집중도는 어떠셨나요?",
      "type": "progress"
    }
  ]
}
```

3. ✅ Android 권한 설정 (AndroidManifest.xml)
   - POST_NOTIFICATIONS
   - RECEIVE_BOOT_COMPLETED
   - WAKE_LOCK
   - SCHEDULE_EXACT_ALARM

4. ✅ 모델 클래스 구현
   - `Question`: id, text, type(enum)
   - `Answer`: questionId, answer, timestamp

5. ✅ 서비스 레이어 구현
   - `QuestionService`: Singleton 패턴, JSON 로드
   - `StorageService`: SharedPreferences 래퍼
   - `NotificationService`: 알림 및 WorkManager

6. ✅ UI 화면 구현
   - `HomeScreen`: 질문 카드 리스트
   - `AnswerScreen`: 타입별 답변 입력
   - `HistoryScreen`: 답변 히스토리

7. ✅ 위젯 구현
   - `TextAnswerWidget`: TextField 기반
   - `ProgressAnswerWidget`: Slider 기반

8. ✅ main.dart 서비스 초기화
   - WidgetsBindingObserver로 라이프사이클 감지
   - 백그라운드 전환 시 10초 후 알림 스케줄

---

## Phase 3: 빌드 오류 해결

### 대화 4: NDK 버전 오류

**사용자**:
```
실행할때 오류가 발생했어.
Your project is configured with Android NDK 26.3.11579264,
but the following plugin(s) depend on a different Android NDK version:
- flutter_local_notifications requires Android NDK 27.0.12077973
```

**AI 해결**:
`android/app/build.gradle.kts` 수정:
```kotlin
ndkVersion = "27.0.12077973"
```

---

### 대화 5: Core Library Desugaring 오류

**사용자**:
```
다른 오류야
Dependency ':flutter_local_notifications' requires core library desugaring
to be enabled for :app.
```

**AI 해결**:
`android/app/build.gradle.kts` 수정:
```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

---

### 대화 6: WorkManager 호환성 오류

**사용자**:
```
e: file:///Users/kjun/.pub-cache/hosted/pub.dev/workmanager-0.5.2/android/src/main/kotlin/
dev/fluttercommunity/workmanager/BackgroundWorker.kt:14:44 Unresolved reference 'shim'.
```

**AI 해결**:
pubspec.yaml 수정:
```yaml
workmanager: ^0.9.0  # 0.5.2에서 업그레이드
```

---

## Phase 4: 문서화

### 대화 7: 문서화 에이전트 요청

**사용자**:
```
문서화를 위한 subagent를 하나 만들어줘
```

**AI 응답**:
- doc-writer 에이전트 생성
- README.md 업데이트
- ARCHITECTURE.md 작성 예정
- API.md 작성 예정
- DEVELOPMENT.md 작성 예정

---

### 대화 8: 문서 작성 지시

**사용자**:
```
현재 까지 작업 내용들을 @agent-doc-writer 를 통해 정리 작성해줘
```

**AI 작업**:
doc-writer 에이전트를 통해 프로젝트 문서화 진행
- README.md 완전히 새로 작성 (한글)
- 프로젝트 개요, 주요 기능, 기술 스택, 아키텍처 설명
- 설치 및 실행 가이드
- 확장 가능성 설명

---

## Phase 5: UI/UX 개선 - Expand/Collapse 기능

### 대화 9: UI 구조 변경 요청

**사용자**:
```
기능을 조금 수정하려고해. 답변을 입력하는 상세페이지 대신 질문을 클릭하면
folding/expanding 구조로 구현되면 좋겠어. 저장을 누르면 다시 expand 되었던 위젯이
fold 되면서 리스트상 약간의 ui변화가 있다면 좋을거 같아.
혹시 모호한 부분 있으면 다시 질문해주고 작업계획 세워줘
```

**AI 질문**:
1. UI 구조: 홈 화면에서 카드 클릭 → expand → 답변 입력 → 저장 → collapse?
2. 한 번에 하나만 expand? 여러 개 동시 expand?
3. 저장 후 UI 변화: 체크 마크? 색상 변경? 미리보기?
4. 히스토리 화면은 유지?
5. 애니메이션 스타일?

---

### 대화 10: 요구사항 상세화

**사용자**:
```
1. 맞아.
2. 동시에 expand 가능해.
3. 카드 색상 변경이 좋을거 같아. 답변 간략히 미리보기 기능도 있으면 좋아.
4. 히스토리화면은 수정할 거지만 지금 단계는 그대로 놔둬줘. 다시 알려줄게.
5. expand/collapse 애니메이션은 코드상 심플한 구조로 작성해줘.
   animation controller 없이 animated widget만으로 처리해줘.
```

**AI 작업**:
1. ✅ _QuestionCard를 StatefulWidget으로 변경
   - `isExpanded` 상태 관리
   - 각 카드가 독립적으로 expand/collapse

2. ✅ 카드 UI 구조 변경
   - Collapsed: 기본 카드 + 답변 미리보기
   - Expanded: 카드 + 답변 입력 폼 + 저장 버튼

3. ✅ AnimatedSize 위젯 사용
   - duration: 300ms
   - curve: Curves.easeInOut
   - AnimationController 없이 구현

4. ✅ 답변 상태별 스타일링
   - 답변 없음: 흰색 배경, 회색 테두리
   - 답변 있음: 연한 파란색 배경 (Colors.blue[50]), 파란색 테두리
   - 체크 아이콘 표시

5. ✅ 답변 미리보기
   - 텍스트: 최대 50자 + 말줄임
   - 프로그레스: "XX%" 형식

6. ✅ 인라인 답변 입력
   - TextAnswerWidget 재사용
   - ProgressAnswerWidget 재사용

7. ✅ 저장 로직
   - 저장 성공 → collapse
   - 배경색 변경
   - 미리보기 표시
   - 스낵바 표시

8. ✅ AnswerScreen 제거
   - 더 이상 필요 없음

---

## Phase 6: 기능 개선

### 대화 11: 이전 답변 값 로드

**사용자**:
```
답변을 완료한 카드를 다시 열면 이전 값이 입력되어 있도록 수정해줘.
```

**AI 작업**:
`_loadLatestAnswer()` 함수 수정:
```dart
Future<void> _loadLatestAnswer() async {
  final answer = await StorageService.instance
      .getLatestAnswerForQuestion(widget.question.id);
  if (mounted) {
    setState(() {
      _latestAnswer = answer;
      if (answer != null) {
        // Load previous answer into input fields
        if (widget.question.type == QuestionType.text) {
          _textController.text = answer.answer;
        } else {
          _progressValue = double.tryParse(answer.answer) ?? 50;
        }
      }
    });
  }
}
```

저장 후 clear 제거:
- `_textController.clear()` 삭제
- 값이 유지되어 다시 열었을 때 표시됨

---

## Phase 7: 문서화 요청

### 대화 12: 대화 로그 작성 요청

**사용자**:
```
지금 까지 너와 주고받았던 프롬프트들을 파일로 작성해 줄 수 있어?
```

**AI 질문**:
어떤 형식?
1. 대화 로그 형식 (시간순 전체 대화)
2. 작업 요약 문서 (핵심만 추출)
3. FAQ 형식 (질문-답변 쌍)
4. 변경 이력 형식 (CHANGELOG)
5. 전체 포함 (여러 파일)

**사용자**:
```
1번 형식이야
```

**AI 작업**:
✅ `docs/CONVERSATION_LOG.md` 작성 (현재 문서)

---

## 주요 기술 결정사항

### 아키텍처
- **패턴**: Singleton 패턴 (서비스 레이어)
- **상태 관리**: StatefulWidget + setState
- **비동기 처리**: async/await

### 데이터 흐름
```
[Asset JSON] → QuestionService → [UI: HomeScreen]
                                       ↓
                                 [User Input]
                                       ↓
                         Inline Answer Widget (Expanded Card)
                                       ↓
                                 StorageService → [SharedPreferences]
                                       ↓
                                 [UI: HistoryScreen]
```

### 알림 시스템
- **트리거**: WidgetsBindingObserver로 앱 라이프사이클 감지
- **스케줄링**: WorkManager.registerOneOffTask (10초 딜레이)
- **백그라운드 실행**: callbackDispatcher (top-level 함수)

### UI/UX 원칙
- **Material Design 3** 기반
- **미니멀리즘**: 깔끔하고 직관적
- **애니메이션**: 간단한 Animated 위젯 사용 (Controller 없이)
- **상태 시각화**: 색상으로 답변 상태 표현

---

## 해결된 주요 이슈

### 1. NDK 버전 불일치
**문제**: Plugin들이 NDK 27 요구
**해결**: build.gradle.kts에서 명시적으로 설정

### 2. Core Library Desugaring
**문제**: flutter_local_notifications 요구사항
**해결**: desugaring 활성화 + 라이브러리 추가

### 3. WorkManager 호환성
**문제**: 0.5.2 버전 컴파일 오류
**해결**: 0.9.0으로 업그레이드 (새로운 플러그인 아키텍처)

### 4. 별도 페이지 vs 인라인 입력
**결정**: 인라인 expand/collapse 방식 채택
**이유**: 더 나은 UX, 컨텍스트 유지

---

## 현재 프로젝트 상태

### 구현 완료 기능
✅ 질문 리스트 표시 (JSON에서 로드)
✅ 인라인 expand/collapse 답변 입력
✅ 텍스트 & 프로그레스 답변 타입
✅ 로컬 저장 (SharedPreferences)
✅ 답변 히스토리 조회
✅ 백그라운드 알림 (10초 후)
✅ 답변 상태별 UI 변화
✅ 답변 미리보기
✅ 이전 답변 값 자동 로드

### 향후 개선 가능 항목
- 히스토리 화면 개선 (사용자 요청 대기 중)
- 통계 및 분석 기능
- 질문 관리 기능 (추가/수정/삭제)
- 알림 시간 커스터마이징
- 백엔드 연동 (선택사항)

---

## 프로젝트 파일 구조 (최종)

```
hackerthon/
├── lib/
│   ├── main.dart                          # 앱 진입점, 서비스 초기화
│   ├── models/
│   │   ├── question.dart                  # Question 모델 & QuestionType enum
│   │   └── answer.dart                    # Answer 모델
│   ├── services/
│   │   ├── question_service.dart          # Singleton, JSON 로드
│   │   ├── storage_service.dart           # Singleton, SharedPreferences
│   │   └── notification_service.dart      # Singleton, 알림 & WorkManager
│   ├── screens/
│   │   ├── home_screen.dart               # 질문 카드 리스트 (expand/collapse)
│   │   └── history_screen.dart            # 답변 히스토리
│   └── widgets/
│       ├── text_answer_widget.dart        # TextField 입력
│       └── progress_answer_widget.dart    # Slider 입력
├── assets/
│   └── questions.json                     # 질문 데이터
├── android/
│   └── app/
│       ├── src/main/AndroidManifest.xml   # 권한 설정
│       └── build.gradle.kts               # NDK, desugaring 설정
├── docs/
│   └── CONVERSATION_LOG.md                # 이 문서
├── pubspec.yaml                           # 의존성 관리
└── README.md                              # 프로젝트 문서

삭제된 파일:
- lib/screens/answer_screen.dart           # 인라인 입력으로 대체됨
```

---

## 개발 타임라인

1. **프로젝트 기획** (Phase 1)
   - 요구사항 수집 및 명확화
   - 기술 스택 결정
   - 아키텍처 설계

2. **초기 개발** (Phase 2)
   - 프로젝트 구조 생성
   - 모델/서비스/UI 구현
   - 기본 기능 완성

3. **디버깅** (Phase 3)
   - 빌드 오류 해결
   - 의존성 문제 해결

4. **문서화** (Phase 4)
   - README.md 작성
   - 에이전트 시스템 구축

5. **UX 개선** (Phase 5)
   - UI 구조 전면 개편
   - Expand/collapse 기능
   - 답변 미리보기

6. **기능 보완** (Phase 6)
   - 이전 답변 로드 기능

7. **문서화 완성** (Phase 7)
   - 대화 로그 작성

---

## 개발 원칙

### 코드 품질
- 명확한 네이밍
- Singleton 패턴으로 전역 상태 관리
- 비동기 처리의 안전한 구현 (mounted 체크)

### 사용자 경험
- 간단하고 직관적인 UI
- 부드러운 애니메이션
- 명확한 피드백 (스낵바)

### 확장성
- 타입 기반 질문 시스템 (쉽게 확장 가능)
- JSON 기반 설정 (코드 수정 없이 질문 변경)
- 모듈화된 서비스 레이어

---

**문서 종료**

이 문서는 프로젝트 개발 과정에서 주고받은 모든 대화를 시간순으로 기록한 것입니다.
향후 유지보수 및 기능 확장 시 참고 자료로 활용할 수 있습니다.
