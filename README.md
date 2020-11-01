# SMS

- SMS 는 Social Management System 의 약자로서 소셜 웹/앱 서비스에 필요한 기본 기능을 제공하는 프레임입니다.

## 개요

- 웹이나 앱을 만들때 가장 쉬운 방법이 무엇일까, 현재 웹/앱의 흐름에 맞는 기능을 포함하며 가장 알맞는 방법은 무엇일까하는 고민을 수 없이 하였습니다.

  - SMS 는 `간단하고 쉬운면서 견고한 프레임` 작성을 최대의 가장 큰 목표로 하고 있습니다. 그래야 개발자들이 쉽게 이해하고 수정 할 수 있기 때문입니다.

  - 그 결과 데이터베이스는 `Firebase` 로 하기로 하였으며, 앱은 `Flutter`, 웹은 `Vue` 로 하기로 하였습니다. 이 세가지는 모두 현재 개발 패러다임을 대표하는 프레임워크들입니다.
    - 참고로 처음 개발 버전에서 백엔드는 LEMP(Linux + Nginx + PHP + MySQL) 와 Firebase 의 조합으로 구성되었는데, `단순한 것이 쉬운 것`이라는 생각에 LEMP 를 빼고, Firebase 로만 백엔드를 구성하기로 했습니다.

- 본 프로젝트는 웹이나 앱을 개발 할 때

  - 가장 가단하고
  - 가장 쉬우면서도
  - 가장 견고하고
  - 재 활용 가치가 높은\
    기본이 되는 프로그램 뼈대(틀)를 만들고자하는 것이 목표입니다. 본 프로젝트가 가지는 기본 기능에 대해서는 주요 기능 항목을 참고해주세요.

- 본 프로젝트는 크게 백엔드는 `Firebase`로 만들어졌으며, 앱은 `Flutter` 로 만들어졌습니다. 그리고 웹은 `Vue` 를 통해 SPA 와 PWA 를 구현합니다.

  - 커스터마이징 부분을 참고해주세요.

## 구성

- `sms/firebase` 폴더에는 Firebase 관련 코드가 있습니다. Firestore, Functions 와 관련된 코드라고 보시면 됩니다.
  - `sms/firebase` 에는 Security Rules 나 Clould Functions 에 대한 코드가 있으며 공식 문서에서 권하는 방식으로 테스트를 하고 있습니다.
- `sms/flutter` 폴더에는 플러터 앱 관련 코드가 있습니다.
  - 플러터에서는 `FireFlutter` 라는 패키지를 통해서 코딩을 합니다.
- `sms/vue` 폴더에는 Vuejs 코드가 있습니다.
  - Vuejs 에서는 `FireWeb` node module 로 코딩을 합니다.

## 설치

- 설치는 Firebase, Flutter, Vue 등 여러 단계로 나뉘어 설명이 됩니다. 참고로 Facebook 로그인과 같이 파이어베이스에 설정을 하고, 페이스북 개발자 계정에서도 설정을 해야하는 등 처음 하시는 분들은 힘들어 할 수 있습니다. FAQ 게시판을 참고 해 주시기 바랍니다.

### 파이어베이스 설치

- Firebase 콘솔에서 프로젝트 생성

  - Authentictaion => Sign-in Method 에서 아래의 로그인을 Enable 하세요.
    - Email/Password
    - Anonymous
    - Google
    - Facebook
    - Phone

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

### 플러터 앱 설정

- 본 프로젝트에서 사용된 툴들의 버전은 아래와 같습니다. 버전이 달라서 충돌이 있을 수 있으니 참고하시기 바랍니다.

  - Flutter 1.22.x
  - firebase_core: "0.5.0+1"
  - firebase_auth: "^0.18.1+2"
  - google_sign_in: "^4.5.1"
  - cloud_firestore: "^0.14.1+3"

### 구글 소셜 로그인 설정

- [FlutterFire 공식문서 - Google](https://firebase.flutter.dev/docs/auth/social#google)에 나오는데로 하면 됩니다.

### 페이스북 소셜 로그인 설정 및 코딩

- [FlutterFire 공식문서 - Facebook](https://firebase.flutter.dev/docs/auth/social#facebook)에 나오는 대로 하면 됩니다.

### 푸시 알림 설정

- [firestore_messaging 패키지](https://pub.dev/packages/firebase_messaging)를 참고하시 설정하면 됩니다.

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

- 파이어베이스를 기반으로 하는 만큼 Firestore 데이터베이스의 실시간, 오프라인 지원 기능을 최대한 할용하여 개발을 합니다. 그 결과, 아래와 같이 실시간으로 인터액티브한 기능이 만들어집니다.

  - 언어 및 기타 설정을 Firestore 에 저장하는데, 실시간으로 앱 화면에 변경이 되어져 나타나며, 인터넷이 안되어도 사용 할 수 있습니다.
  - 게시판에 새로운 글 또는 코멘트가 작성되면, 화면 리프레시(또는 종료 후 재 실행)하지 않아도 실시간으로 화면에 새 글 또는 코멘트가 나타납니다.
  - 글/코멘트 추천을 하면 실시간으로 그 추천 증가/감소 수가 표시됩니다.

## 플러터 앱

- `절대원칙: 간단하고 쉬운면서 견고한 프레임` 제작을 이루기 위해서 최대한 외부 플러그인을 사용하지 않으면서 꼭 필요하다면, 그 중에서 가장 쉬운 플러그인을 사용합니다.

## 커스터마이징

- 본 프로젝트의 구성은 크게 `Firebase 백엔드 코드`, `Flutter 앱 코드`, `Vue 웹 코드`로 나뉘어져 있으며 원한다면 `Firebase 백엔드 코드` 만 분리하여 다른 Clientend 프레임으로 개발을 해도 됩낟.
- 본 프로젝트에서 원한다면 웹이나 앱, 둘 중 하나만 사용해도 됩니다.
- 본 프로젝트에서 웹은 `Vue` 로 만들었는데, SEO 를 원한다면 `Vue` 를 통해 `SSR` 을 하시면 됩니다.
- 특정 언어로 고정하고 싶다면, main.dart 에서 `Service.updateLocale()` 을 호출 할 필요 없다.

## 프레임의 조합

- `절대원칙: 간단하고 쉬운면서 견고한 프레임` 제작을 위해서 최적의 조합을 찾는 것이 목표입니다.

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

### Functions 테스트

```
$ cd functions
$ npm test
```

### 파이어베이스 베포

- 테스트가 끝나면 아래와 같이 배포하면 됩니다.
- 참고로 firebase deploy 명령은 Blaze 플랜에서만 할 수 있습니다. Free 플랜에서는 할 수 없습니다.

```
$ firebase deploy --only firestore,functions
```

## 프로젝트 이슈

- 문제가 있으면 [깃이슈](https://github.com/thruthesky/sms/issues)를 남겨주세요.
- [SMS 프로젝트 관리](https://github.com/thruthesky/sms/projects/2)

## 디자인

- 여백이나 각종 크기, 영역은 가능한 2, 4, 8, 16, 32 수치로 합니다.
  For spaces and sizes, it uses 2, 4, 8, 16, 32.

## 파이어스토어 데이터베이스 구조

### 파이어스토어의 데이터 관리와 비용 관계에 의한 설계

- 문서를 read, write, update 할 때마다 비용이 발생한다.

  - 문서의 크기와는 상관이 없다.
  - 다만, 문서를 네트워크로 전송 할 때에는 용량에 따라 비용이 달라진다.
  - 이에 따라 다음과 같은 구조를 만들 수 있다.
    - 한 번 데이터를 읽을 때, 반드시 같이 읽어야 하는 데이터는 각 값마다 컬렉션에 따로 도큐먼트를 만들지 말고, 하나의 도큐먼트로 만든다.
      - 예를 들면, 사용자 푸시 알림 토큰의 경우, 사용자 A 가 토큰 50개를 가지고 있는 경우, A 에게 푸시 알림을 보내고자 한다면, 50개의 토큰 모두를 파이어스토어에서 가져와야 한다.
        - 이때, 만약, `/users/{uid}/tokens/{tokenId}` 와 같이 tokens 아래에 `푸시 토큰 아이디`로 도큐먼트를 만들고 그 안에 토큰 아이디를 저장한다면, 50개의 문서를 읽어야하므로 비용이 낭비된다.
        - `/users/{uid}/meta/tokens` 와 같이 tokens 도큐먼트 하나에 모든 토큰을 저장하면 50개의 문서를 읽을 필요 없이 1개의 문서만 읽으면 된다.

- 도큐먼트 전용 속성은 도큐먼트 하위에 저장한다.
  - 예를 들면, 사용자 속성은 `/users/{uid}/meta` 컬렉션에 저장한다.
    - 대부분 `/users/{uid}`에 저장하면 되지만,
      - 푸시 알림 토큰의 경우, 사용자 정보를 읽을 때, 같이 가져 올 필요 없다. 즉, 쓸데없이 네트워크 전달 용량을 키울 필요 없는 것이다.
  - 또 다른 예로 게시글이나 코멘트의 추천(like, dislike) 기록이다.
    - 기록을 남겨야, 동일한 사용자가 2번 추천을 하지 않는다.
    - 그리고 게시글/코멘트가 삭제될 때, 이러한 정보가 같이 삭제되어야 한다.
    - 추천 기록은 `/posts/{postId}/vote-history/{uid}` 와 같이 남기면 된다.
  - 그래서 도큐먼트가 삭제되면, 그 하위의 모든 속성도 삭제되도록 한다.
    - 파이어스토어에서 도큐먼트를 삭제 할 때, 하위 컬렉션이나 그 하위 정보가 자동으로 삭제되지 않는다.
    - 버전 2.0 에서는 삭제된 사용자 정보나 게시판, 코멘트 정보 등을 찾아서 상위 도큐먼트/컬렉션이 삭제되면, 하위의 컬렉션을 삭제하는 CLI 를 제공 할 예정이다.

### 추천 로직

- 글/코멘트가 동일한 로직 사용.
- choice 는 like, dislike 또는 빈문자열 중 하나.

- 글/코멘트에 likes, dislikes 가 없으면 0으로 초기화

- /posts/{postId}/votes/{uid} 또는 /posts/{postId}/comments/{commentId}/votes/{uid} 로 사용자 추천 도큐먼트 저장

- choice 의 값이 빈문자열, like, 또는 dislike 중 하나가 아니면, security fules 로 에러를 내야 함 그리고 클라이언트에서 미리 방지해야 함.

- 본인의 글/코멘트에 추천 할 수 있음

- 처음 추천 할 때, like 를 하는 경우, 글/코멘트의 likes 1 증가.
- 처음 추천 할 때, dislike 를 하는 경우, 글/코멘트의 dislikes 1 증가.
- 처음 추천 할 때, choice 가 없는(빈 문자열 인) 경우, 아무런 변화 없음. 클라이언트에서 방지해야 함.
- 파이어베이스 콘솔에서 직접 해당 votes 도큐먼트에 { choice: ... } 가 아닌 { abc: 'def' } 와 같은 값이나, { choice: 'wrongValue' } 와 같은 임의의 값을 넣을 수 있다. 특히, { choice: 'wrongValue' } 와 같은 값을 넣었다가 { choice: 'dislike' } 와 같이 수정하면, 로직에 따라 likes 가 1 감소하고, dislikes 가 1 증가한다.
  하지만, 이것은 관리자가 콘솔에서 직접 값을 지정 할 때에만 해당하며, 실제로는 Security Rules 에 의해서 이런 상황이 발생하지 않는다.

- like 를 한 글/코멘트에 또 like 를 하는 경우, 변화 없음. security rules 로 막고 클라이언트에서 못하도록 미리 방지 해야 함.
- dislike 를 한 글/코멘트에 또 dislike 를 하는 경우, 변화 없음. security rules 로 막고 클라이언트에서 못하도록 미리 방지 해야 함.

- like 를 한 글/코멘트에 dislike 를 하는 경우, like 1 감소, dislike 1 증가
- dislike 를 한 글/코멘트에 like 를 하는 경우, like 1 증가, dislike 1 감소

- like, dislike 가 아닌, 빈 문자열을 저장하는 경우, 이전에 (글/코멘트에)

  - like 를 했다면, 글/코멘트에 like 1 감소,
  - dislike 를 했다면, 글/코멘트에 dislike 1 감소

- 추천은 async 하게 동작한다.

  - 추천, 추천 취소를 빠르게
    `like => '' => like => '' => like => ''`
    와 같은 형태로 했을 경우,
    실제 Firestore 에 적용되는 순서가
    `'' => '' => '' => '' => like => like => like` 와 같이 변경 될 수 있다.
    그래서 결국은 like 가 3 이나 증가하게된다.

    이는 일반적인 side effect 로서, 이를 방지하기 위해서 클라이언트에서 progress spinner 나 disabled 형태로 최소 3초 정도 보여주거나, 3초 이내에 재 추천을 못하도록 하면 된다.

### 사용자

- 사용자 문서는 `users` 컬렉션 아래에 저장되며, 도큐먼트 아이디는 사용자 UID 입니다.
- 사용자 문서에는 어떤 정보라도 추가 할 수 있습니다.

#### 푸시 알림 토큰

- 푸시 알림 토큰은 `users/{uid}/tokens` 컬렉션에 저장됩니다.

### Admin account

- 사용자 문서에 `isAdmin: true` 이면 그 사용자는 관리자이다.
  - 이 값의 변경은 DB 에서 직접 변경을 하던지, 명령창에서 메일 주소를 기록 할 수 있다. 참고: 관리자 아이디 지정하기

### 게시판 카테고리

- `categories` 컬렉션에 게시판 설정을 저장합니다.
- 처음 생성 할 때에는 `id`, `title`, `description` 이 필수 값입니다. 그 외 임의의 필드/값을 추가 할 수 있습니다.
- 카테고리 도큐먼트 아이디는 도큐먼트 필드에 있는 `id` 의 값과 동일해야 합니다.
- 도큐먼트는 모든 사용자가 읽을 수 있으며, 관리자만 생성, 수정, 삭제가 가능합니다.

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

## 개발자 가이드라인

- 회원 가입을 하면, `users/{uid}` 에 사용자 도큐먼트가 생성된다.

- 단, 소셜 로그인을 하는 경우, 로그인 직후 홈 화면으로 이동한다. 즉, 성별, 생년월일 등을 입력하지 않으므로, 사용자 도큐먼트가 생성되지 않는다. 즉, 로그인 사용자에 사용자 도큐먼트가 없을 수 있다.

### 언어 번역

- 에러 메지를 번역 할 때 에러 코드를 키로 저장하면 된다.
  - 주의 할 점은 에러코드에 슬래시(/)가 들어가 있으면 언더바(\_)로 변경해야 한다.
  - 예를 들어, 파이어베이스 로그인 에러 코드가 `auth/account-exists` 와 같다면,
    `auth_account-exists` 로 키를 저정해야 한다.

### 플러터 개발자 가이드라인

#### 사용하는 패키지

[공개된 플러터 패키지](https://pub.dev/) 중에서 쉽고 좋은 패키지를 엄선하여 사용하고 있습니다. 예를 들면, 플러터에서는 Provider 상태 관리자를 많이 사용하는데, 대신 GetX 상태 관리자를 사용하고 있습니다. 그 이유는 Provider 보다 상태 관리가 쉬우며, 라우팅이나, 글로벌 context 를 통한 위젯, 언어 다국화 등 좋은 기능을 매우 쉽게 사용 할 수 있게 해 주기 때문입니다.

여기서는 주요 패키지를 나타냅니다. 모든 패키지에 대해서는 pubspec.yaml 을 참고해주세요.

- GetX - https://pub.dev/packages/get
  이 패키지를 통해서 상태관리, 라우팅, 다국어, 스낵바, Bottom Sheets 등을 사용
- Dio - https://pub.dev/packages/dio
  원격 서버 접속
- Firebase packages - https://firebase.flutter.dev/
  파이어베이스를 사용
- Cached network image - https://pub.dev/packages/cached_network_image
  이미지를 로컬 캐시해서 사용
- Jiffy https://pub.dev/packages/jiffy
  날짜 변환 함수

## 테스트

- 코멘트 계층형 구조 테스트

```
ForumTest();
```

## 풀 텍스트 검색

- 게시판 글, 코멘트 검색은 Firestore 로 할 수 없다. 그래서 Algolia 로 한다.

- 설정은

  - `settings/app` 도큐먼트에 ALGOLIA_APP_ID(Application ID), ALGOLIA_SEARCH_KEY(Search Only Api Key), ALGOLIA_INDEX_NAME 를 기록한다.
  - firebase/functions/index.js 의 상수 ALGOLIA_ID(Application ID), ALGOLIA_ADMIN_KEY, ALGOLIA_INDEX_NAME 에 해당 설정 값을 저장한다.

- Cloud Functions 를 deploy 를 한다.

- 참고로 Algolia 무료 버전은 월 1만번 검색이 가능하다. 대 부분의 소규모 앱은 월 1만번이면 충분하다.

- 테스트는 % npm run test:algolia 와 같이 하면 된다.
