# SMS

- SMS 는 Social Management System 의 약자로서 소셜 서비스에 필요한 기본 기능을 제공하는 프레임입니다.

## 저작권

- 저작자: 송재호
- 연락처: thruthesky@gmail.com 010-8693-4225
- 본 프로젝트는 저작자가 온라인 스터디를 위해 개발 과정을 오픈하는 것으로 개발이 완료된 후 프로젝트는 공개되지 않을 수 있습니다.
- 본 프로젝트를 이용하기 위해서는 프로젝트에 참여한 사람외에는 저작자의 허가를 받아야지만 사용 할 수 있습니다.
- 저작자외 본 프로젝트를 판매하거나 다른 상품에 끼워팔기를 해서는 안됩니다.

## 개요

- 웹이나 앱을 만들때 가장 쉬운 방법이 무엇일까? 라는 질문을 저 스스로에게 하면서 가장 쉬운 방법이면서도 개발 트렌드에 가장 알맞는 방법을 찾기로 했습니다.

  - `간단하고 쉬운면서 견고한 코드` 작성을 최대의 가장 큰 목표로 하고 있습니다. 그래야 개발자들이 쉽게 이해하고 수정 할 수 있기 때문입니다.

  - 그 결과 데이터베이스는 `Firebase` 로 하기로 하였으며, 앱은 `Flutter`, 웹은 `Vue` 로 하기로 하였습니다. 이 세가지는 모두 현재 개발 패러다임을 대표하는 프레임워크들입니다.

- 본 프로젝트는 웹이나 앱을 개발 할 때

  - 가장 가단하고
  - 가장 쉬우면서도
  - 가장 견고하고
  - 재 활용 가치가 높은\
    기본이 되는 프로그램 뼈대(틀)를 만들고자하는 것이 목표입니다. 본 프로젝트가 가지는 기본 기능에 대해서는 주요 기능 항목을 참고해주세요.

- 본 프로젝트는 크게 백엔드는 `Firebase`로 만들어졌으며, 앱은 `Flutter` 로 만들어졌습니다. 그리고 웹은 `Vue` 를 통해 SPA 와 PWA 를 구현합니다.

  - 커스터마이징 부분을 참고해주세요.

## 설치

- 본 프로젝트에서 사용된 툴들의 버전은 아래와 같습니다. 버전이 달라서 충돌이 있을 수 있으니 참고하시기 발바니다.

  - Flutter 1.22.x
  - firebase_core:
  - firebase_auth:
  - clould_firestore:

- Firebase 콘솔에서 프로젝트 생성

  - Authentictaion => Sign-in Method 에서
    - Email/Password Enable
    - Anonymous Enable

- Cloud Firestore 생성
  - `protection mode` 선택
  - Region 은 적당히 선택. (한국인 대상 서비스는 홍콩이나 일본 추천)
  - `What file should be used for Firestore Rules? (firestore.rules)` 에서 기본 파일 firebase.rules 선택
  - `What file should be used for Firestore indexes? (firestore.indexes.json)` 에서 기본 파일 firebase.indexes.json 선택
- 작업 컴퓨터에 Firebase 설치

  - `# npm install -g firebase-tools`
  - `$ cd firebase`
  - `$ firebase login`
  - Update .firebaserc and change projects ⇒ default as your project id.

- Firebase Firestore Security Rules 를 Firebase 로 업로드

  - `$ firebase deploy --only firestore`

- 깃 프로젝트 [SMS Git project](https://github.com/thruthesky/sms) 클론 또는 포크

## 주요기능

- 회원 관리

  - 소셜 로그인. 구글, 페이스북 로그인을 기본 지원하며, 필요하면 개발자가 다른 소셜 로그인을 추가 가능.
  - 회원 가입. 이메일로 회원 가입.
  - 핸드폰 인증. 파이어베이스에서 제공하는 핸드폰 인증 방식을 통해 인증.

- 게시판

  - 관리자 기능: 게시판 생성, 수정, 삭제
  - 관리자 기능: 전체 글 한번에 목록하기
  - 글 생성, 수정, 삭제
  - 글 카테고리 변경,
  - 코멘트 생성, 수정 삭제
  - 첨부 파일 업로드, 삭제
  - 추천, 비추천
  - 글 신고
  - 사용자 글 쓰기 차단

- 푸시 알림
  - 전체 회원에게 푸시 알림
  - 자기가 쓴 글 아래에 코멘트가 달리면 푸시 알림. (옵션. 옵션 선택하지 않은 사용자들은 관리자가 On/Off 선택 )
  - 게시판 별 푸시 알림. (옵션)
    - 코멘트가 작성되어도 푸시가 알림될지 말지 결정

## 플러터 앱

- `절대원칙: 간단하고 쉬운면서 견고한 코드 작성`을 이루기 위해서 최대한 외부 플러그인을 사용하지 않으면서 꼭 필요하다면, 그 중에서 가장 쉬운 플러그인을 사용합니다.

## 커스터마이징

- 본 프로젝트의 구성은 크게 `Firebase 백엔드 코드`, `Flutter 앱 코드`, `Vue 웹 코드`로 나뉘어져 있으며 원한다면 `Firebase 백엔드 코드` 만 분리하여 다른 Clientend 프레임으로 개발을 해도 됩낟.
- 본 프로젝트에서 원한다면 웹이나 앱, 둘 중 하나만 사용해도 됩니다.
- 본 프로젝트에서 웹은 `Vue` 로 만들었는데, SEO 를 원한다면 `Vue` 를 통해 `SSR` 을 하시면 됩니다.
- 특정 언어로 고정하고 싶다면, main.dart 에서 `Service.updateLocale()` 을 호출 할 필요 없다.

## 프레임의 조합

- `절대원칙: 간단하고 쉬운면서 견고한 코드 작성`을 위해서 최적의 조합을 찾는 것이 목표입니다.

- Firebase 를 선택한 이유는 Social Login 이나 휴대폰 번호 인증, Push Notification, 실시간 데이터 업데이트 등에 있어서 파이어베이스는 필수적인 툴입니다. 만약 Linux, Nginx, PHP 와 MySQL 의 조합 같은 다른 백엔드를 선택한다고 하여도 파이어베이스는 같이 사용을 해야합니다.
  백엔드가 복잡해지면 개발자가 힘들어 할 것이며 커스터마이징은 더욱 힘들 것입니다.
  그래서 Firebase 하나로 쉽고 간단하게 필요한 모든 것을 다 할 수 있도록 하였습니다.

- 파이어베이스의 `Functions` 를 가능한 사용하지 않을 계획인데, 그 이유는 `Functions` 자체가 `Flutter` 앱이나 `Vue` Frontend 개발 방식과 많이 다르기 때문입니다. 개발자가 `Functions` 에 대해서 잘 알고 있다면 다행이지만, 그렇지 않다면, 설치 과정이 하나 더 늘게될 것이며 이것은 초보 개발자분들에게는 또 하나의 짐이 될 것이기 때문입니다. 필요하다면 최소한의 기능만 `Functions` 통해서 개발 할 것입니다.

## 파이어베이스 권한

### 권한 테스트

- 먼저 `$ npm i` 을 통해서 필요한 node module 을 설치합니다.

- 아래와 같이 emulator 를 실행합니다.

```
$ firebase emulators:start --only firestore
```

- 그리고 아래와 같이 테스트를 합니다.
  - 참고: 현재 테스트 코드는 작업 중에 있습니다.

```
$ npm run test
$ npm run test:basic
$ npm run test:user
$ npm run test:admin
$ npm run test:category
$ npm run test:post
$ npm run test:comment
$ npm run test:vote
$ npm run test:user.token
```

### Publish

- 테스트가 끝나면 아래와 같이 배포하면 됩니다.

```
$ firebase deploy --only firestore
```

## 프로젝트 이슈

- 문제가 있으면 [깃이슈](https://github.com/thruthesky/sms/issues)를 남겨주세요.
- [SMS 프로젝트 관리](https://github.com/thruthesky/sms/projects/2)

## 디자인

- 여백이나 각종 크기, 영역은 가능한 2, 4, 8, 16, 32 수치로 합니다.
  For spaces and sizes, it uses 2, 4, 8, 16, 32.

## 파이어베이스 데이터베이스 구조

### Admin account

- 사용자 문서에 `isAdmin: true` 이면 그 사용자는 관리자이다.
  - 이 값의 변경은 DB 에서 직접 변경을 하던지, 명령창에서 메일 주소를 기록 할 수 있다. 참고: 관리자 아이디 지정하기

## 관리 및 운영

### 관리자 아이디 지정하기

- 관리자로 지정을 하고자 한다면, `$ node set-admin.js abc@gmail.com` 와 같이 하면 된다.

### 설정

- 모든 설정은 `Firestore => settgins => global` 에서 overwrite 가능하다.

  - 참고로 global 도큐먼트에 설정은 Flutter 와 Vue 등 모든 클라이언트 앱에 다 적용되는 것이다.
  - 앱이 부팅되면, Firestore 에서 설정을 내려 받아, 앱에 적용한다.

- 플러터에서는 lib/settings.dart 에 기본 설정을 저장한다.

- Vue에서는 src/settings.dart 에 기본 설정을 저장한다.

### 언어 설정

- `defaultLanguage` 는 앱이 부팅되지 마자 사용할 언어이다.

- `changeUserLanguageOnBoot` 는 앱이 부팅 된 후, 운영체제에 있는 기본 언어로 변경 할 지, 지정한다.

  - 예를 들어, `defaultLanguage` 가 `ja` 인데, 운영체제의 기본 언어가 `ko` 라면,
    `changeUserLanguageOnBoot` 이 true 이면, 언어는 `ko` 되고, false 이면, 언어는 `ja`가 된다.

- 기본적으로 언어는 `service/translations.dart` 의 `translations` 변수에 있는 JSON 내용이 적용된다.

  - 이 값은 `Firebase => settings ==> translations ==> texts` 에 기록하여 overwrite 가능하다.
    - 참고로 번역 문자열 값은 실시간 업데이트 된다.
    - 가능하면 전체 문자열을 다 `translations` 에 기록한다. 또는 최소한 첫 페이지에 나오는 문자열만이라도 기록해서, 첫번째 페이지에서 번역 문자열을 다운로드 한 뒤, 두번재 페이지 부터는 번역된 문자열을 사용 하게 하면 된다.

- 단순히 메뉴에 표시될 문자열 뿐만아니라 각종 페이지/화면에 나타낼 컨텐츠로도 사용 가능하다.

- `supportedLanguages` 는 사용자가 선택 할 수 있는 언어인데, Flutter iOS 앱인 경우, Info.plist 에 언어셋을 추가해 주어야 하며, 그 언어셋 내에서만 선택 할 수 있다.
