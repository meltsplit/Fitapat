
> 해당 레포지토리는 원본 레포지토리가 아닙니다 ‼️ </br>
> 해당 레포지토리는 원본 레포지토리가 아닙니다 ‼️ </br>
> 해당 레포지토리는 원본 레포지토리가 아닙니다 ‼️ </br>
# Fitapat - iOS


<img src="https://github.com/meltsplit/Fitapat/assets/57269348/925a09a6-f1b2-4674-820d-1ef5f65e693c" height="800"> </br>
> fitapat(핏어팻)은 생성형 AI를 활용한 반려동물 커스텀 굿즈 이커머스입니다

## 🛠️ Skills
- RxSwift
- Moya
- Snapkit
- Sentry
- FirebaseMessaging
- FirebaseRemoteConfig
- KakaoSDK
- KingFisher
- Realm

## 🏛️ 아키텍처: MVVM + CleanArchitecture
![아키텍처](https://github.com/meltsplit/Fitapat/assets/57269348/7776d712-676c-4ace-bb28-4253c9a53a2e)

### MVVM
- MVVM을 도입하여 뷰컨트롤러와 뷰는 화면을 그리는 역할에만 집중하고 데이터 관리, 로직의 실행은 뷰모델에서 진행되도록 했습니다.
- 뷰모델을 Input과 Output으로 정의하여 뷰의 이벤트들을 Input에 바인딩하고, 뷰에 보여질 데이터를 Output에 바인딩했습니다.
- 일관성 있고 직관적인 구조를 유지해 뷰모델의 코드 가독성이 높였습니다.

### Clean Architecture
- 뷰모델의 비즈니스 로직들을 유즈케이스로, 네트워크나 외부 프레임워크에 대한 요청은 repository로 분리해 각 레이어의 역할을 분명하게 나누었습니다.
- MockService 객체를 통해 서버 API가 나오기전이라도 뷰로직을 미리 테스트 할 수 있도록 했습니다.

</br>
</br>

##  🔥 해결한 문제

### 1. 반려동물 등록 이탈율 14% 감소
- **상황**:
  - 유저가 AI에 학습시킬 반려동물 이미지 15장을 서버로 업로드 해야하는 상황이었습니다. 이미지 업로드 중 이탈이 자주 발생하여, 반려동물 등록 실패 비율이 78%에 달해 아래와 같이 해결했습니다.
- **문제**:
  1. 유저가 큰 사이즈의 이미지 입력 시, 서버 통신 시간이 1분 이상 소요
  2. 네트워크 통신 진행도가 나타나지 않아 유저가 이탈
  3. 유저가 앱 이탈시 서버통신이 끊겨 반려동물 등록에 실패하는 문제
  4. 애플 내장 갤러리뷰에 불편함을 느껴 이탈 
- **해결**:
  1. 이미지 다운샘플링을 통해 http body 바이트수 감소
  2. [이미지 업로드 진행도를 나타내는 토스트뷰 구현](https://velog.io/@melt/이미지-업로드-통신의-진행도를-실시간-로딩뷰-보여주기)
  3. [앱 생명주기를 관찰하여 URLSession Task를 background 세션으로 전환하기](https://velog.io/@melt/앱-생명주기를-관찰하여-URLSession-Task를-background-세션으로-전환하기) </br>
  4. Custom Image Picker 구현하기
     - RxSwift, MVVM 구조에 맞게 설계
     - 넘버링 기능을 구현하기 위해 선택된 사진을 `[PHAsset]` 에 저장하여, index를 토대로 선택알고리즘을 구현
     - DiffableDataSource를 통해 선택해제 컬렉션뷰(가로) 애니메이션을 부드럽게 구현
     - 이미지캐싱을 담당하는 `PHAssetTransformer` Protocol을 만들어 Cell이 채택하도록 설계하였고, Cell의 `prepareForReuse()`가 발동될 시 이미지캐싱을 중단시켜 메모리 누수를 방지
- **결과**:
  1. 서버 통신 시간 1분에서 20초로 단축
  2. 유저 친화적 UI/UX 제공하여 사용자 경험 개선
  3. 앱 이탈 시에도, 서버통신이 끊기지 않아 등록 실패율 감소
  4. 반려동물 이미지 고르는 UX 개선


### 2. 클린 아키텍처로 외부 변화로부터 보호하기
<img width="615" alt="ZOOC_서비스변경" src="https://github.com/meltsplit/Fitapat/assets/57269348/46b8830a-3ca8-47fd-b03b-ed35ee3347bb">

- **상황**:
  - <네이버 서비스> 문자인증 API 를 모두 구현하였으나, <네이버 서비스> 내부 문제로 API 사용이 3주간 사용이 불가능하다는 통보를 받았습니다. 
- **해결**:
  - 클린아키텍처로 Service Layer에만 의존하도록 설계하였기에 문자인증 요청, 타이머, 인증코드 검증 등의 뷰 혹은 비즈니스 로직 변경 없이 쉽게 <알리고 서비스>를 적용할 수 있었습니다.
- **결과**:
  - 앱 업데이트 기간을 3주에서 3일로 단축시킬 수 있었습니다.


### 3. Debug / Release Schema를 분리 후 XcodeCloud를 활용하여 TestFlight CI/CD를 구축했습니다.
[Debug / Release Configuration 분리](https://velog.io/@melt/Debug-Release-Configuration-분리)
- **상황**:
  - 자주 변경되는 기획과 새로운 기능이 나올 때 마다 팀원(서버, 디자이너)의 즉각적인 QA 가 필요했습니다.
- **해결**:
  - Schema를 Debug, Release로 분리하였습니다.
  - Schema에 따라 xcconfig 파일를 분리하여 BaseURL, Bundle Idetifier, App Name, App Icon 이 다르게 설정되도록 구축했습니다.
  - XcodeCloud를 통해 main 브랜치는 Release 스키마를, develop 브랜치는 Debug 스키마에 대한 CD를 구축했습니다.
  - TestFlight를 통해 릴리즈앱과 테스트앱을 자동 배포 환경을 구축했습니다.
- **결과**:
  - iOS 앱 개발자가 수동으로 archive를 하지 않아, 빌드당 10분의 가량 시간을 단축되었습니다.
  - 개발의 변경사항이 자동 배포되기에, 팀원(서버, 디자이너)들의 즉각적인 피드백 및 QA 환경이 만들어졌습니다.

### 4. WebView 연동시 화면 전환 관련 프로토콜 구축하기
- **상황**:
  - SEO 및 빠른 배포를 위해 네이티브앱에서 웹앱으로 전환해야 했습니다. 웹앱 도입 당시 확장성 있는 화면 전환 방식이 필요했습니다.
- **해결**:
  - RESTful API를 참고하여 funcName 으로 path를 정하고, body 값에 해당 요청에 필요한 데이터를 `json` 형식 만든 후, `JSONSerialization`을 통해 `Enconding`하는 방식을 도입했습니다.
- **결과**:
  - 앱 코드 변경 없이도 Web: React에서 앱의 화면전환인 `push`, `pop`, `present`, `dismiss`, `탭 전환`, `웹뷰 띄우기` 등을 통제할 수 있습니다.


### 5.이미지 다운샘플링으로 메모리 사용량 60% 감소
- **상황**:
  - 서버로부터 받아오는 이미지 사이즈가 커 메모리 사용량이 2GB에 육박하여 스크롤 시 버벅거리는 현상이 발생했습니다.
- **해결**:
  - 이미지 다운샘플링을 통해 `JPEG` 에서 `UIImage`로 변환될 때, 이미지 최대 크기를 디바이스 사이즈로 축소하여 decode했습니다.
- **결과**:
  - 메모리 사용량이 800MB정도로 줄며, 스크롤 버벅임 현상이 개선되었습니다.



<br/>

## 📌 팀

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/HELLOHIDI"><img src="https://user-images.githubusercontent.com/57269348/210512867-9ba9bb75-2256-4b8f-bbf1-7b4250614144.jpg" width="220px;" alt=""/><br /><titleb><b>HELLOHIDI</b></titleb></a><br /><a href="https://github.com/TeamZOOC/ZOOC-iOS/commits?author=HELLOHIDI" title="Code"></a></td>
    <td align="center"><a href="https://github.com/meltsplit"><img src="https://user-images.githubusercontent.com/57269348/210512883-9b175a0e-d2f5-48a8-a311-a1fb41f9b338.JPG" width="220px;" alt=""/><br /><titleb><b>meltsplit</b></titleb></a><br /><a href="https://github.com/TeamZOOC/ZOOC-iOS/commits?author=meltsplit" title="Code" title="Code"></a></td>
  </tr>
</table>

<br>

