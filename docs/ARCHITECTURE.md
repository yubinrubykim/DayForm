# 아키텍처 설계 문서 (Architecture Design Document)

> **오늘의 질문** 애플리케이션의 시스템 아키텍처 및 설계 원칙

## 목차

1. [시스템 개요](#시스템-개요)
2. [아키텍처 패턴](#아키텍처-패턴)
3. [레이어 구조](#레이어-구조)
4. [데이터 흐름](#데이터-흐름)
5. [핵심 컴포넌트](#핵심-컴포넌트)
6. [상태 관리 전략](#상태-관리-전략)
7. [백그라운드 작업 아키텍처](#백그라운드-작업-아키텍처)
8. [데이터 영속성](#데이터-영속성)
9. [확장성 고려사항](#확장성-고려사항)
10. [성능 최적화](#성능-최적화)

---

## 시스템 개요

### 아키텍처 비전

**오늘의 질문**은 **오프라인 퍼스트(Offline-First)**, **심플하지만 확장 가능한(Simple but Scalable)** 모바일 애플리케이션 아키텍처를 지향합니다. 네트워크 의존성을 최소화하면서도 향후 백엔드 연동, 클라우드 동기화, 분석 기능 추가 등의 확장이 용이한 구조를 설계했습니다.

### 핵심 설계 원칙

1. **단일 책임 원칙(Single Responsibility)**: 각 클래스와 모듈은 하나의 명확한 책임만 가짐
2. **의존성 역전 원칙(Dependency Inversion)**: 추상화에 의존하여 구현체 교체 용이
3. **개방-폐쇄 원칙(Open-Closed)**: 확장에는 열려있고 수정에는 닫혀있는 구조
4. **명확한 레이어 분리**: Presentation, Business Logic, Data 레이어 엄격 구분
5. **불변성 우선**: 데이터 모델은 불변 객체로 설계하여 예측 가능한 상태 관리

### 기술적 제약사항

- **Flutter 3.8.1+**: Material Design 3 및 최신 Dart 언어 기능 활용
- **모바일 플랫폼 타겟**: Android (API 21+), iOS (13+) 지원
- **로컬 우선**: 외부 네트워크 의존성 없음 (현재 버전)
- **경량화**: 최소한의 외부 패키지 사용으로 앱 사이즈 최적화

---

## 아키텍처 패턴

### 계층형 아키텍처 (Layered Architecture)

본 프로젝트는 **3-Tier 계층형 아키텍처**를 기반으로 구성되어 있습니다.

```
┌─────────────────────────────────────┐
│    Presentation Layer (UI)          │
│  - Screens (StatefulWidget)         │
│  - Widgets (Reusable Components)    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│    Business Logic Layer              │
│  - Services (Singleton Pattern)     │
│  - Business Rules & Orchestration   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│    Data Layer                        │
│  - Models (Data Objects)            │
│  - Storage Abstractions             │
│  - Asset Management                 │
└─────────────────────────────────────┘
```

### 디자인 패턴

#### 1. 싱글톤 패턴 (Singleton Pattern)

모든 서비스 클래스는 싱글톤으로 구현되어 앱 전역에서 단일 인스턴스를 공유합니다.

**구현 방식:**

```dart
class QuestionService {
  static QuestionService? _instance;

  QuestionService._();  // Private constructor

  static QuestionService get instance {
    _instance ??= QuestionService._();
    return _instance!;
  }
}
```

**장점:**
- 메모리 효율성: 중복 인스턴스 생성 방지
- 전역 접근: 어느 위젯에서든 `ServiceName.instance`로 간편 접근
- 상태 공유: 앱 전체에서 일관된 데이터 상태 유지

#### 2. 팩토리 패턴 (Factory Pattern)

JSON 데이터를 모델 객체로 변환하는 팩토리 메서드 사용:

```dart
factory Question.fromJson(Map<String, dynamic> json) {
  return Question(
    id: json['id'] as String,
    text: json['text'] as String,
    type: QuestionType.fromString(json['type'] as String),
  );
}
```

#### 3. 리포지토리 패턴 (Repository-like Pattern)

`StorageService`는 데이터 접근 로직을 추상화하여 구현체 교체 가능:

```dart
// 향후 확장 예시
abstract class IStorageService {
  Future<void> saveAnswer(Answer answer);
  Future<List<Answer>> getAllAnswers();
}

class SharedPreferencesStorage implements IStorageService { ... }
class SQLiteStorage implements IStorageService { ... }
class CloudStorage implements IStorageService { ... }
```

---

## 레이어 구조

### 1. Presentation Layer (프레젠테이션 레이어)

**책임**: 사용자 인터페이스 렌더링 및 사용자 입력 처리

#### Screens (화면 컴포넌트)

| 화면 | 파일 | 주요 기능 |
|------|------|-----------|
| 홈 화면 | `home_screen.dart` | 질문 목록 표시, 질문 선택 |
| 답변 작성 화면 | `answer_screen.dart` | 답변 입력 폼, 저장 로직 |
| 히스토리 화면 | `history_screen.dart` | 과거 답변 목록, 시간순 정렬 |

#### Widgets (재사용 컴포넌트)

| 위젯 | 파일 | 용도 |
|------|------|------|
| 텍스트 답변 입력 | `text_answer_widget.dart` | 멀티라인 텍스트 필드 |
| 진행도 슬라이더 | `progress_answer_widget.dart` | 0-100% 범위 슬라이더 |

**특징:**
- **StatefulWidget 기반**: 로컬 상태 관리 (Loading, Error, Success)
- **컴포지션 우선**: 큰 위젯을 작은 위젯으로 분해하여 재사용성 극대화
- **단방향 데이터 흐름**: 부모에서 자식으로 데이터 전달, 자식은 콜백으로 이벤트 전파

### 2. Business Logic Layer (비즈니스 로직 레이어)

**책임**: 비즈니스 규칙 구현, 데이터 조작, 외부 시스템 통합

#### Services

| 서비스 | 파일 | 핵심 기능 |
|--------|------|-----------|
| QuestionService | `question_service.dart` | 질문 로딩, 질문 조회 |
| StorageService | `storage_service.dart` | 답변 저장, 조회, 삭제 |
| NotificationService | `notification_service.dart` | 알림 관리, 백그라운드 작업 |

**주요 메서드:**

```dart
// QuestionService
Future<void> loadQuestions()
List<Question> getAllQuestions()
Question? getQuestionById(String id)

// StorageService
Future<void> saveAnswer(Answer answer)
Future<List<Answer>> getAllAnswers()
Future<List<Answer>> getAnswersByQuestionId(String questionId)
Future<Answer?> getLatestAnswerForQuestion(String questionId)

// NotificationService
Future<void> init()
Future<void> showNotification()
Future<void> scheduleNotification()
```

### 3. Data Layer (데이터 레이어)

**책임**: 데이터 모델 정의, 직렬화/역직렬화, 영속성

#### Models

| 모델 | 파일 | 속성 |
|------|------|------|
| Question | `question.dart` | id, text, type (enum) |
| Answer | `answer.dart` | questionId, answer, timestamp |

**데이터 모델 특징:**
- **불변 객체**: 모든 필드는 `final`로 선언
- **JSON 직렬화**: `fromJson`, `toJson` 팩토리 메서드 제공
- **타입 안전성**: Enum 기반 타입 시스템

---

## 데이터 흐름

### 질문 로딩 플로우

```
[App Start]
    ↓
[main.dart] QuestionService.instance.loadQuestions()
    ↓
[QuestionService] rootBundle.loadString('assets/questions.json')
    ↓
[JSON Parsing] List<Question> 변환
    ↓
[Memory Cache] _questions 리스트에 저장
    ↓
[HomeScreen] QuestionService.instance.getAllQuestions()
    ↓
[UI Render] ListView.builder로 화면 표시
```

### 답변 저장 플로우

```
[AnswerScreen] 사용자 입력
    ↓
[Validation] 빈 값 체크
    ↓
[Answer Model 생성] timestamp 자동 할당
    ↓
[StorageService.saveAnswer(answer)]
    ↓
[getAllAnswers()] 기존 답변 로드
    ↓
[answers.add(answer)] 새 답변 추가
    ↓
[SharedPreferences] JSON 직렬화 후 저장
    ↓
[Success Callback] SnackBar 표시, 화면 닫기
```

### 알림 트리거 플로우

```
[User Action] 앱을 백그라운드로 전환
    ↓
[WidgetsBindingObserver] didChangeAppLifecycleState() 감지
    ↓
[NotificationService.scheduleNotification()]
    ↓
[WorkManager] 10초 후 실행되는 일회성 작업 등록
    ↓
[callbackDispatcher()] 백그라운드 Isolate에서 실행
    ↓
[FlutterLocalNotifications.show()] 알림 표시
    ↓
[User Tap] 알림 탭 시 앱 재오픈
```

---

## 핵심 컴포넌트

### QuestionService

**역할**: 질문 데이터 생명주기 관리

```dart
class QuestionService {
  List<Question> _questions = [];  // 메모리 캐시

  Future<void> loadQuestions() async {
    // Asset에서 JSON 로드
    final jsonString = await rootBundle.loadString('assets/questions.json');
    final jsonData = json.decode(jsonString);

    // Question 객체로 변환
    _questions = (jsonData['questions'] as List)
        .map((json) => Question.fromJson(json))
        .toList();
  }

  List<Question> getAllQuestions() {
    return List.unmodifiable(_questions);  // 불변 복사본 반환
  }
}
```

**설계 결정:**
- **메모리 캐시**: 반복 로딩 방지, 빠른 접근
- **불변 반환**: `List.unmodifiable()`로 외부 수정 방지
- **에러 핸들링**: try-catch로 로딩 실패 시 빈 리스트 반환

### StorageService

**역할**: 로컬 데이터 영속성 추상화

```dart
class StorageService {
  static const String _answersKey = 'answers';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveAnswer(Answer answer) async {
    final answers = await getAllAnswers();
    answers.add(answer);

    // JSON 직렬화
    final answersJson = answers.map((a) => a.toJson()).toList();
    await _prefs!.setString(_answersKey, json.encode(answersJson));
  }
}
```

**설계 결정:**
- **지연 초기화**: `init()` 메서드로 비동기 초기화
- **단일 키 사용**: 모든 답변을 하나의 JSON 배열로 저장 (단순성)
- **트랜잭션 패턴**: 읽기 → 수정 → 쓰기 원자적 수행

### NotificationService

**역할**: 알림 및 백그라운드 작업 오케스트레이션

```dart
class NotificationService {
  Future<void> initBackgroundWork() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }

  Future<void> scheduleNotification() async {
    await Workmanager().registerOneOffTask(
      'notification_task_${DateTime.now().millisecondsSinceEpoch}',
      taskName,
      initialDelay: const Duration(seconds: 10),
    );
  }
}

// Top-level function (Isolate 진입점)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 백그라운드에서 알림 표시
    await notifications.show(...);
    return true;
  });
}
```

**설계 결정:**
- **WorkManager 사용**: Android/iOS 플랫폼별 백그라운드 작업 추상화
- **Top-level 함수**: Isolate에서 실행되므로 전역 함수 필요
- **고유 작업 ID**: timestamp 기반으로 중복 방지

---

## 상태 관리 전략

### 로컬 상태 관리 (StatefulWidget)

각 화면은 자체 상태를 관리하며, 복잡한 전역 상태 관리 라이브러리는 사용하지 않습니다.

```dart
class _HomeScreenState extends State<HomeScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    await QuestionService.instance.loadQuestions();
    setState(() {
      _questions = QuestionService.instance.getAllQuestions();
      _isLoading = false;
    });
  }
}
```

**장점:**
- **단순성**: 학습 곡선 낮음, 디버깅 용이
- **성능**: 불필요한 리빌드 없음
- **예측 가능성**: 명시적 `setState()` 호출로 상태 변화 추적 쉬움

### 상태 종류

1. **로딩 상태**: `_isLoading` 플래그로 관리
2. **데이터 상태**: `_questions`, `_answers` 등 리스트
3. **폼 상태**: `TextEditingController`, 슬라이더 값

### 향후 확장 고려

대규모 상태 관리가 필요해질 경우:
- **Provider**: 간단한 의존성 주입 및 상태 공유
- **Riverpod**: 타입 안전한 Provider 개선판
- **BLoC**: 이벤트 기반 상태 관리

---

## 백그라운드 작업 아키텍처

### WorkManager 통합

**WorkManager**는 Android의 JobScheduler와 iOS의 Background Tasks를 추상화한 플러그인입니다.

#### 작업 등록

```dart
Future<void> scheduleNotification() async {
  await Workmanager().registerOneOffTask(
    'notification_task_${DateTime.now().millisecondsSinceEpoch}',
    taskName,
    initialDelay: const Duration(seconds: 10),
  );
}
```

#### 작업 실행 (별도 Isolate)

```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == NotificationService.taskName) {
      final notifications = FlutterLocalNotificationsPlugin();

      await notifications.show(
        0,
        '오늘의 질문이 준비되었어요!',
        '당신의 하루를 되돌아볼 시간입니다.',
        notificationDetails,
      );
    }
    return Future.value(true);
  });
}
```

### 앱 생명주기 감지

```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      NotificationService.instance.scheduleNotification();
    }
  }
}
```

---

## 데이터 영속성

### SharedPreferences 구조

```json
{
  "answers": [
    {
      "questionId": "q1",
      "answer": "오늘은 프로젝트 문서를 작성했다.",
      "timestamp": "2025-10-25T14:30:00.000Z"
    },
    {
      "questionId": "q2",
      "answer": "85",
      "timestamp": "2025-10-25T14:31:00.000Z"
    }
  ]
}
```

### 데이터 마이그레이션 전략

향후 스키마 변경 시:

```dart
Future<void> _migrateData() async {
  final version = _prefs.getInt('schema_version') ?? 1;

  if (version < 2) {
    // v1 → v2 마이그레이션 로직
    await _migrateV1ToV2();
    await _prefs.setInt('schema_version', 2);
  }
}
```

---

## 확장성 고려사항

### 백엔드 연동 준비

```dart
// 향후 추가 예정
abstract class IQuestionRepository {
  Future<List<Question>> fetchQuestionsFromServer();
  Future<List<Question>> getLocalQuestions();
}

class QuestionRepository implements IQuestionRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  @override
  Future<List<Question>> fetchQuestionsFromServer() async {
    final questions = await _apiService.getQuestions();
    await _storageService.cacheQuestions(questions);
    return questions;
  }
}
```

### 모듈화 전략

대규모 확장 시 Feature 단위 모듈화:

```
lib/
├── core/                    # 공통 유틸리티
│   ├── services/
│   └── utils/
├── features/
│   ├── questions/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── answers/
│   └── analytics/
```

---

## 성능 최적화

### 렌더링 최적화

1. **const 생성자**: 불변 위젯은 `const` 선언으로 리빌드 방지
2. **ListView.builder**: 화면에 보이는 항목만 렌더링
3. **키 사용**: 리스트 항목 재정렬 시 위젯 재사용

```dart
ListView.builder(
  itemCount: _questions.length,
  itemBuilder: (context, index) {
    final question = _questions[index];
    return _QuestionCard(
      key: ValueKey(question.id),  // 고유 키
      question: question,
    );
  },
)
```

### 메모리 최적화

1. **싱글톤 패턴**: 중복 인스턴스 생성 방지
2. **불변 컬렉션**: `List.unmodifiable()` 사용
3. **Dispose 패턴**: `TextEditingController` 등 리소스 해제

### 로딩 최적화

1. **Lazy Loading**: 질문은 앱 시작 시 한 번만 로드
2. **비동기 초기화**: 블로킹 없이 병렬 초기화

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 병렬 초기화
  await Future.wait([
    StorageService.instance.init(),
    NotificationService.instance.init(),
    QuestionService.instance.loadQuestions(),
  ]);

  runApp(const MyApp());
}
```

---

## 다이어그램

### 전체 시스템 아키텍처

```
┌──────────────────────────────────────────────────────┐
│                   Presentation Layer                  │
│  ┌────────────┐  ┌────────────┐  ┌───────────────┐  │
│  │HomeScreen  │  │AnswerScreen│  │HistoryScreen  │  │
│  └─────┬──────┘  └─────┬──────┘  └───────┬───────┘  │
└────────┼────────────────┼──────────────────┼──────────┘
         │                │                  │
         ▼                ▼                  ▼
┌──────────────────────────────────────────────────────┐
│                Business Logic Layer                   │
│  ┌─────────────────┐  ┌──────────────┐  ┌──────────┐│
│  │QuestionService  │  │StorageService│  │Notification││
│  │   (Singleton)   │  │  (Singleton) │  │Service    ││
│  └────────┬────────┘  └──────┬───────┘  └────┬─────┘│
└───────────┼────────────────────┼───────────────┼──────┘
            │                    │               │
            ▼                    ▼               ▼
┌──────────────────────────────────────────────────────┐
│                      Data Layer                       │
│  ┌─────────┐  ┌─────────┐  ┌────────────┐  ┌──────┐│
│  │Question │  │ Answer  │  │SharedPrefs │  │Assets││
│  │ Model   │  │ Model   │  │            │  │      ││
│  └─────────┘  └─────────┘  └────────────┘  └──────┘│
└──────────────────────────────────────────────────────┘
```

---

**문서 버전**: 1.0
**최종 수정일**: 2025-10-25
**작성자**: Hackathon Team
