---
layout: post
title: '텔레그램 봇 만드는 방법'
categories: Develop
tags: [JavaScript, Integration, Messenger, telegram, bot]
---

## 📖 들어가기

텔레그램 메신는 안드로이드, iOS, Mac, Window 등 모든 플랫폼에서 사용 가능한 무료 메신저입니다.
텔레그램 메신저의 장점 중 하나로는 API가 공개되어 다른 프로그램 또는 플랫폼과 연계해 사용 가능하다는 점입니다.

> 텔레그램 봇을 만드는 방법에 대해서 알아보겠습니다.

## 텔레그램 봇 만드는 순서

1.  텔레그램에서 **BotFather** 채팅방에 접속합니다.

    ![1](/assets/posts/make-telegram-bot/1.png)

2.  **BotFather** 채팅방에서 봇 생성 명령어를 입력합니다. 채팅방에 `/newbot` 명령어를 입력하고 전송버튼을 눌러줍니다.

    ![2](/assets/posts/make-telegram-bot/2.png)

3.  텔레그램 봇 이름을 입력합니다.

    1.  첫번째 질문은 봇의 이름입니다. (한글 설정가능)

        ![3](/assets/posts/make-telegram-bot/3.png)

    2.  두번째 질문은 보 유저네임입니다. (마지막은 `_bot` or `Bot`으로 끝나야합니다) <br>
        기존의 사용중인 이름이나 `-`의 경우 사용이 안되는 것을 볼 수 있습니다.

        ![4](/assets/posts/make-telegram-bot/4.png)

4.  [t.me/todo_noti_FE_bot]() 링크를 클릭하면 제가 만든 봇으로 이동합니다. 이동하고나서 `/start` 를 눌러줍니다.

    - 초록색 부분은 API를 요청할 때 사용할 토큰입니다.

      ![5](/assets/posts/make-telegram-bot/5.png)

## 봇과 통신하기

이제 봇을 이용해서 특정 트리거가 발생할 때 원하는 메시지가 오게끔 만들어보겠습니다.
여기서 사용해 볼 방식은 두가지인데,

1. `node-telegram-bot-api` package를 이용하는 방법과
2. `axios`를 이용해서 api를 보내는 방법입니다.

두가지 뭘 사용하든 상관없습니다. 그리고 두가지 이외의 방법도 있습니다. 저는 위 두가지 방식을 사용해보도록 하겠습니다.

### node-telegram-bot-api

> 참고 : [https://github.com/yagop/node-telegram-bot-api](https://github.com/yagop/node-telegram-bot-api)

위 패키지를 사용하기 위해서는 간단하게 프로젝트를 생성해야합니다. 디렉토리 생성 후 이동하겠습니다.

```bash
$ mkdir telegram-bot
$ cd telegram-bot
```

이후 npm을 이용하기 위해서 `package.json`을 만들어줍니다. 그리고 `node-telegram-bot-api`를 설치합니다.

```bash
$ npm init -y
$ npm i node-telegram-bot-api
```

설치 후 **index.js**를 생성 후 **node.js**를 통해 index.js 파일을 돌려줍니다. 아래 코드는 `node-telegram-bot-api`에서 제공되는 코드입니다.

index.js:

```js
const TelegramBot = require('node-telegram-bot-api')

// replace the value below with the Telegram token you receive from @BotFather
const token = 'Here is HTTP API token'

// Create a bot that uses 'polling' to fetch new updates
const bot = new TelegramBot(token, { polling: true })

// Matches "/echo [whatever]"
bot.onText(/\/echo (.+)/, (msg, match) => {
  // 'msg' is the received Message from Telegram
  // 'match' is the result of executing the regexp above on the text content
  // of the message

  const chatId = msg.chat.id
  const resp = match[1] // the captured "whatever"

  // send back the matched "whatever" to the chat
  bot.sendMessage(chatId, resp)
})

// Listen for any kind of message. There are different kinds of
// messages.
bot.on('message', msg => {
  const chatId = msg.chat.id

  // send a message to the chat acknowledging receipt of their message
  bot.sendMessage(chatId, `${chatId}: Received your message`)
})
```

무사히 잘 정상작동 하는 것을 볼 수있습니다.

![6](/assets/posts/make-telegram-bot/6.png)

### axios를 이용해서 API 보내기

axios를 이용해서 get, post 방식을 통해 api를 전송하는 방법을 시도해보겠습니다. API를 전송할땐 반드시 axios일 필요는 없습니다.

먼저 axios를 설치합니다

```bash
$ npm i axios
```

index.js:

```js
const axios = require('axios')

const init = (() => {
  const apiToken = 'Here is HTTP API token'
  const apiUrl = `https://api.telegram.org/bot${apiToken}`

  axios({
    method: 'GET',
    url: `${apiUrl}/getMe`,
    headers: {
      'Content-Type': 'application/json;charset=UTF-8',
    },
  })
    .then(res => {
      console.log('[🐱 DDD] ~ file: propertyAxios.js ~ line 19 ~ init ~ res', res.data)
    })
    .catch(err => {
      console.log('[🐱 DDD] ~ file: propertyAxios.js ~ line 26 ~ init ~ err', err)
    })

  axios({
    method: 'GET',
    url: `${apiUrl}/getUpdates`,
    headers: {
      'Content-Type': 'application/json;charset=UTF-8',
    },
  })
    .then(res => {
      console.log('[🐱 DDD] ~ file: propertyAxios.js ~ line 19 ~ init ~ res', res.data)
    })
    .catch(err => {
      console.log('[🐱 DDD] ~ file: propertyAxios.js ~ line 26 ~ init ~ err', err)
    })

  axios({
    method: 'POST',
    url: `${apiUrl}/sendMessage`,
    headers: {
      'Content-Type': 'application/json;charset=UTF-8',
    },
    data: {
      chat_id: 'chat_id', // 텔레그램의 CHAT_ID
      text: '메시지 잘 갔나용 🐱',
    },
  })
    .then(res => {
      console.log('[🐱 DDD] ~ file: propertyAxios.js ~ line 33 ~ init ~ res', res.data)
    })
    .catch(err => {
      console.log('[🐱 DDD] ~ file: propertyAxios.js ~ line 23 ~ init ~ err', err.message)
    })
})()
```

#### getMe method(GET)

- 봇의 대한 정보를 가지고 있습니다.

```json
{
  "ok": true,
  "result": {
    "id": "chat_id", // 이부분을 chat_id에 넣어주면된다.
    "is_bot": true,
    "first_name": "투두노티 프론트 봇",
    "username": "todo_noti_FE_bot",
    "can_join_groups": true,
    "can_read_all_group_messages": false,
    "supports_inline_queries": false
  }
}
```

#### getUpdates method(GET)

- 마지막으로 보낸 메시지의 정보를 가지고 있습니다.

```json
{
  "ok": true,
  "result": [
    {
      "update_id": 957584811,
      "message": {
        "message_id": 10,
        "from": {
          "id": "chat_id", // 이부분을 chat_id에 넣어주면된다.
          "is_bot": false,
          "first_name": "성준",
          "last_name": "이",
          "language_code": "ko"
        },
        "chat": {
          "id": "chat_id", // 이부분을 chat_id에 넣어주면된다.
          "first_name": "성준",
          "last_name": "이",
          "type": "private"
        },
        "date": 1615804255,
        "text": "이건 테스트용으로 메시지를 보내는겁니다."
      }
    }
  ]
}
```

#### sendMessage method(POST)

- 위 값을 해당 API에 전달하면 텔레그램에 text값인 `Hello world~!`값이 전달됩니다.

```js
const body = {
    "chat_id": "chat_id"
    "text": "Hello world~!"
}
```
