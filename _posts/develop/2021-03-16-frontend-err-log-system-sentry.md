---
layout: post
title: '프론트엔드 에러 로그 시스템 Sentry 적용기'
categories: Develop
tags: [JavaScript, Integration, telegram, bot]
---

## 📖 들어가기

> 서비스를 개발하고 운영하면서 필요했던 클라이언트의 에러 로그 트래킹 시스템 도입을 정리

### 클라이언트 사이드 에러 로그 트래킹이 필요한 이유?

SPA(Single Page Application) + CSR(Client Side Rendering)로 구성된 서비스들이 많아지고 있습니다. 서비스를 운영하다보면 개발자의 예상과는 다르게 예기치 못한 오류가 발생하게됩니다. 서버 사이드 에러가 아닌 클라이언트 단에서 발생한 에러는 어떻게 파악할 수 있을까?

프론트엔드 개발자의 입장에서 클라이언트 단의 오류를 파악하는 가장 확실한 방법은 해당 브라우저의 개발자 도구 콘솔을 통해 오류 내용을 파악하는 것.

-   오류가 발생한 클라이언트 장비에 원격 접속해 직접 웹 브라우저를 확인
-   서비스를 이용중인 고객에게 직접 '웹 브라우저의 개발자 도구를 열고 > 콘솔에 찍힌 오류내용을 캡쳐해주세요.' 라는 요구를 한다.

이런 번거로운 상황을 만드지 않고 개발자가 직접 프론트엔드(클라이언트 단)의 오류를 트래킹 할 수 있다면 좀 덜 수고스럽게 이슈 대응을 할 수 있지 않은까?

#### 자바스크립트 오류 remote logging 필요성

- 자바스크립트의 자유로운 문법 특성상 런타임 오류가 발생하기 쉽다.
- 브라우저 콘솔에 찍히는 로그를 확인해야함 오류발생을 확인할 수 있다.
- 모바일, 웹뷰 테스트 시 콘솔을 확인하기 어렵다.
- 로그를 한 눈에 빠르게 파악할 수 있기 때문에 빠른 대응을 할 수 있다.


## Sentry란?

Sentry는 어플리케이션에서 오류가 발생하면 알려주는 에러 트래킹 서비스입니다. (무료 혹은 유료) 클라이언트의 오류 발생시 메일을 보내주고, 슬랙과 연동하면 슬랙 메시지를 통해 오류 발생과 해당 오류에 대한 정보 파악이 가능합니다.

Javascript, vue.js, java, python 등의 다양한 언어, 프레임워크, 라이브러리를 지원하여 여러 프로젝트의 이슈를 한 곳에서 관리함으로써 에러 모니터링을 일원화 할 수 있습니다.

### [지원하는 언어, 플랫폼 및 인티그레이션]

![](/assets/posts/frontend-err-log-system-sentry/1.png)

### [오류에 대한 다양한 정보들]

![](/assets/posts/frontend-err-log-system-sentry/2.png)


### [실제 누적된 Error 정보]

- 오류에 대한 상세한 정보 및 오류 내용
- 오류가 발생한 클라이언트 환경에 대한 정보
- 오류가 발생한 Vue Component에 대한 정보

### [무료 사용시 제한 사항]

- 멤버 수 제한 : 하나의 계정으로 로그인해야 해당 이슈들을 조회할 수 있음.
- 에러 수 제한 : 무료 사용시 5,000개로 제한
- 히스토리 저장 : 오류에 대한 히스토리 30일만 저장
- 기타 소소한 추가 기능들은 링크를 통해 확인 가능 [Sentry 유료 정책](https://sentry.io/pricing/)


## 적용하기 (Node.js)

Sentry에 가입 후 프로젝트를 생성한다.

@sentry/browser, @sentry/tracing
```bash
# Using yarn
$ yarn add @sentry/node @sentry/tracing

# Using npm
$ npm install --save @sentry/node @sentry/tracing
```

Sentry 설치 가이드에 따라 코드를 입력합니다. 가능하면 페이지가 로드되는 시점에 코드가 실행될 수 있도록 합니다.

index.js:
```js
const Sentry = require("@sentry/node");
// or use es6 import statements
// import * as Sentry from '@sentry/node';

const Tracing = require("@sentry/tracing");
// or use es6 import statements
// import * as Tracing from '@sentry/tracing';

Sentry.init({
  dsn: "여기에 dsn 키값이 들어갑니다.",

  // Set tracesSampleRate to 1.0 to capture 100%
  // of transactions for performance monitoring.
  // We recommend adjusting this value in production
  tracesSampleRate: 1.0,
});

const transaction = Sentry.startTransaction({
  op: "test",
  name: "My First Test Transaction",
});

setTimeout(() => {
  try {
    foo();
  } catch (e) {
    Sentry.captureException(e);
  } finally {
    transaction.finish();
  }
}, 99);
```

위 코드를 실행합니다. 위 코드를 보면 `foo()` 메소드가 정의되어있지않습니다. 따라서 에러가 발생합니다. 해당 에러는 Sentry에 접속하면 모니터링 할 수 있습니다.

![](/assets/posts/frontend-err-log-system-sentry/3.png)
![](/assets/posts/frontend-err-log-system-sentry/4.png)


## Telegram 연동하기

현재 Sentry는 많은 Integrations 지원합니다. 그 중에서 텔레그램은 지원하지 않습니다. 현재 진행중인 프로젝트의 메신저는 텔레그램을 사용중이기 때문에 텔레그램과 연결해 보겠습니다. axios를 사용해서 api를 싸주는 방법을 사용합니다.

1. 텔레그램 봇을 만듭니다.

    [텔레그램 봇을 만드는 방법](https://253eosam.github.io/integration/2021/03/15/make-telegram-bot/)은 이전에 써놓은 포스트를 참고해주시면 좋겠습니다.


2. 에러가 Sentry에 전송되기 전에 hook을 이용해서 Error message를 telegram에 전송합니다.

    ```js
    const Sentry = require('@sentry/node');
    // or use es6 import statements
    // import * as Sentry from '@sentry/node';

    const Tracing = require('@sentry/tracing');
    // or use es6 import statements
    // import * as Tracing from '@sentry/tracing';

    const axios = require('axios');
    const apiToken = '여기에 telegram http api token이 들어갑니다.'

    Sentry.init({
        dsn: '여기에 dsn 키값이 들어갑니다.',

        // Set tracesSampleRate to 1.0 to capture 100%
        // of transactions for performance monitoring.
        // We recommend adjusting this value in production
        tracesSampleRate: 1.0,
        beforeSend: (event, hint) => _sendErrorMessage(event, hint), // 에러를 Sentry에게 전달하기 전 처리할 수 있는 hook
    });

    const _sendErrorMessage = (event, hint) => {
        let errorMsg = 'Sentry error hook';

        // const vue = event.contexts.vue;
        const hintMsg = hint.originalException || hint.syntheticException;
        errorMsg = `[Error]: \n
        >>> Message: ${hintMsg.message}\n`

        const body = {
            chat_id: 'chat_id', // 텔레그램의 CHAT_ID
            text: errorMsg,
        };
        axios({
            method: 'POST',
            url: `https://api.telegram.org/bot${apiToken}/sendMessage`,
            headers: {
                'Content-Type': 'application/json;charset=UTF-8',
            },
            data: body,
        }).then(() => {
            console.log('Error logged!', hint.originalException || hint.syntheticException);
        });

        return event;
    };

    const transaction = Sentry.startTransaction({
        op: 'test',
        name: 'My First Test Transaction',
    });

    setTimeout(() => {
        try {
            throw new Error('telegram hook');
        } catch (e) {
            Sentry.captureException(e);
        } finally {
            transaction.finish();
        }
    }, 99);
    ```

실행시면 다음과 같은 결과를 얻을 수 있습니다.

![](/assets/posts/frontend-err-log-system-sentry/6.png)
![](/assets/posts/frontend-err-log-system-sentry/7.png)

---

참고

- <https://tech.urbanbase.com/dev/2021/03/04/Sentry.html?fbclid=IwAR0Pjpr8fwa1262-FkhfozvUTvEvqZ8qE7xoowq4wj8DNLY5HGmnu3nD6CI>
