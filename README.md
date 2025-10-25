# 🌞 DayForm 데이폼

> **“내 하루를 디자인하는 나만의 폼(Form), 루틴 블로깅 앱 데이폼(DayForm)”**

https://docs.google.com/forms/d/1ilxgp2bQx6lNDKOApuWxtrUDnWOm3X4fs0vANDqYEpY/viewform?edit_requested=true

Dayform은 **나의 하루를 '설문지 폼(Form)'으로 디자인하고**, 매일 응답해 **루틴을 형성하고 기록을 분석**할 수 있는 **루틴 블로깅 앱**입니다.


---

## 📌 Introduction

- 설문폼으로 디자인하는 나의 하루 : 나에게 매일 묻고 싶은 질문을 나만의 설문지 폼으로 만들 수 있습니다.
- 루틴 블로깅하기 : 매일 설문지 폼에 응답하며 나의 하루를 블로깅합니다.
- 기록 트래킹을 통한 동기부여 : 피드에서 트래킹된 기록들을 보며 나만의 패턴을 발견하고, 동기부여를 받을 수 있습니다.

---

## 🚩 Problem Statement

- 루틴 앱들은 대부분 **제한된 체크박스와 알람** 위주의 UX를 제공하여 **개인의 다양한 생활 패턴을 반영하기 어렵습니다.**
- 획일적인 UX로 인해 루틴 앱의 **장기 사용률은 매우 낮으며**, 사용자는 자신의 루틴이 **어떤 패턴과 의미를 갖는지 이해하지 못한 채 기록을 포기하게 됩니다


✅ Dayform은 루틴을 ‘체크하는 동작’이 아니라, ‘블로깅(기록하는 행위)’ 자체를 하나의 리추얼(ritual)**로 바라봅니다.

사용자는 폼(Form)을 직접 설계함으로써, 자신의 가치관과 라이프스타일에 맞는 개인화된 질문지를 만들 수 있습니다.
“루틴은 지켜야 하는 것이 아니라, 스스로 설계하고 기록하며 이해하는 과정이다.”
Dayform은 바로 그 과정을 위한 루틴 블로깅 플랫폼입니다.

---

## 🎯 Core Concept

| 기능 | 설명 |
|------|------|
| **Form-Making System** | 사용자가 원하는 루틴을 문답형 폼(Form)으로 직접 설계 |
| **Daily Response UI** | 매일 Form에 응답하며 하루를 기록 |
| **Pattern Visualization** | 응답 결과가 누적되어 차트 및 타임라인으로 시각화 |
| **Themed Templates** | 환경(분리수거, 탄소절감), 건강(운동, 수면, 영양제) 등 맞춤형 폼 제공 |
| **User-owned Data** | 사용자가 자신의 데이터를 피드로 열람 |

---

## 🧭 User Flow (Demo)

1. **앱 실행 → 스플래시 화면 (태양 로고 + Dayform 텍스트)**
2. **루틴 주제 선택**  
   - 건강 / 환경 / 생산성 / 직접 생성
3. **Form 생성** (예시 질문)
   - 오늘 플라스틱 사용을 줄이기 위해 무엇을 실천했나요?
   - 몸의 컨디션이 좋지 않았다면 원인은 무엇인가요?
4. **Daily 응답 기록** → 자동 저장
5. **패턴 시각화**
   - 지속성 그래프, 감정/행동 상관분석, 루틴 성공률

---

## 🌟 Key Differentiators

| 기존 루틴 앱 | Dayform |
|--------------|---------|
| 체크리스트&알람 | 설문지 폼 |
| 완료 여부만 기록 | 응답 데이터로 패턴 분석 |
| 실패 시 포기 | 변화의 원인을 이해하며 지속 가능성 증가 |
| 사용자 순응형 UX | 사용자 주권형 UX |

---

## day_form — 실습 요약 @ 가현님

목적: Flutter만 설치된 상태에서 시작하여 `gemini`(자동화 도구)를 활용해 UI 구현, 상태관리, JSON 데이터 처리, 모바일 에뮬레이터에서의 실행(위해 CocoaPods 설치 포함)까지 진행하려 했던 시도와 결과를 요약합니다.

## 시작 상태
- 사전 설치: Flutter만 설치되어 있는 상태
- 목표: MVP 관련 사전 안내를 바탕으로 gemini를 이용해 빠르게 프로토타입을 구성하고, 모바일 에뮬레이터에서 동작 확인

## 시도한 작업
- gemini를 이용해 UI 구현 및 상태관리(ViewModel/Provider) 구조로 리팩터링
- JSON 파일(`assets/questions.json`)을 이용해 데이터 로드/바인딩 구현
- 테스트 자동화/재현을 위해 `test.toml` 파일 생성하고 gemini에서 `/test` 경로로 실행 시도
- 모바일 에뮬레이터에서 실행하기 위해 iOS 의존성 설치(CocoaPods) 시도

## 발생한 문제와 결과
- `test.toml`을 만들어 gemini에서 실행하려 했으나 실행 실패
- iOS 빌드에서 `Module 'flutter_local_notifications' not found` 오류가 발생
	- 원인: iOS 네이티브 라이브러리(플러그인) 연결을 위한 CocoaPods가 설치 또는 실행되지 않음
	- 시도: `flutter clean`, `flutter pub get` 등 패키지 관련 정리 작업 수행
	- 실패: 로컬 환경에서 `pod` 명령이 없어 `pod install`을 실행하지 못함(또는 `sudo gem install cocoapods`에서 설치를 완료하지 못함)

결과적으로 모바일(실기기/시뮬레이터) 환경에서의 최종 실행 검증은 완료하지 못했습니다.

## 원인 분석
- 평소 자주 쓰는 짧은 커맨드만 사용하여 전체 툴체인(예: CocoaPods 설치, 권한/환경 설정 등)을 준비하지 않은 점이 주 원인입니다.
- Flutter 플러그인 중 iOS 네이티브 컴포넌트가 있는 경우에는 `pod install`을 통한 네이티브 의존성 설치가 필수입니다.

## 배운 점
1. gemini 같은 자동화 도구는 프롬프트를 파일로 만들어 실행하면 재현 가능한 작업 파이프라인을 만들 수 있다.
2. 모바일(iOS) 테스트를 위해서는 시스템 레벨 의존성(CocoaPods, Xcode 등)이 사전에 준비되어야 한다.
3. 짧은 커맨드 중심의 작업 방식은 빠르지만, 전체 프로젝트 구조/환경을 처음부터 만들 때는 필요한 초기화 단계(의존성 매니저 설치 등)를 누락하기 쉽다.

## 다음 단계(권장)
1. 로컬에 CocoaPods 설치

```bash
sudo gem install cocoapods
```

2. iOS 의존성 설치 및 빌드 재시도

```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run -d <device-id>
```

3. (옵션) Android AVD로 빠르게 테스트하려면 Android Studio에서 AVD를 만들고 아래처럼 실행

```bash
flutter emulators --launch <emulator-id>
flutter run -d <emulator-device-id>
```

4. gemini 자동화 재구성: 실패한 `test.toml`을 점검해 필요한 권한/환경 전제(예: `pod install` 수행 여부)를 추가하고 재실행

## 프레젠테이션 메모(말할 거리)
- 시도한 목표와 기대 결과를 간단히 설명
- 왜 실패했는지(환경 의존성 누락)와 해결 방법을 명확히 제시
- gemini를 통해 얻은 장점(프롬프트 파일화로 재현 가능)과 향후 적용 계획

---

필요하면 제가 `README` 내용에 더 많은 명령 예시나 단계별 스크린샷/결과 로그를 추가해 드리겠습니다.
