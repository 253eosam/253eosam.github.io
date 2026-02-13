---
title: "SSE"
date: "2025-09-17T07:46:48.593Z"
tags:
  - sse
description: "클라이언트에게 서버로부터 실시간 업데이트를 허용하는 웹 기술.text/event-stream 타입으로 서버에서 클라이언트에 단방향 통신을 할 수 있습니다. 클라이언트에서 매번 요청없이 한번의 연결을 통해 서버와 통신해야하는 경우WebSocket 방식보다 라이트한 방식을"
url: "https://velog.io/@253eosam/SSE"
---

# SSE(Server-Sent-Event)란?

클라이언트에게 서버로부터 실시간 업데이트를 허용하는 웹 기술.

`text/event-stream` 타입으로 서버에서 클라이언트에 단방향 통신을 할 수 있습니다.

## 필요 사항

*   클라이언트에서 매번 요청없이 한번의 연결을 통해 서버와 통신해야하는 경우
*   WebSocket 방식보다 라이트한 방식을 원하는 경우
*   이벤트 타입을통해 한번의 연결로 다양한 분기를 수행해야하는 경우
*   지속적인 연결을 유지해야야는 경우

## Client (JS)

![](https://velog.velcdn.com/images/253eosam/post/fce7ee27-a7bc-4481-9140-3f837d1a1fc6/image.png)

*   EventSource 객체를통해 서버와 통신이 가능합니다. (단방향)
    
    ```jsx
    const eventSource = new EventSource(url)
    ```
    
    선언과 동시에 해당 URL로 통신 시도
    
*   실시간 데이터 스트리밍 방식 (`text/event-stream`)
    
*   지속적인 연결 상태 유지
    
    *   호출을 통해 닫힐 때까지 연결
*   서버에서 보내주는 이벤트를 통해 action을 분리할 수 있습니다.
    
    *   server에서 내려주는 eventName을 통해 이벤트를 전달 받을 수 있습니다.
        
        ```jsx
        eventSource.addEventListener('eventname', (event) => {
          //...
        })
        ```
        
    *   server에서 eventName을 비어서 보낸다면 default값으로 “message” 이벤트로 받으면 됩니다.
        
        ```jsx
        eventSource.addEventListener('message', (event) => {
          //...
        })
        
        // or
        eventSource.onmessage = (event) => {
          //...
        }
        ```
        

### 응답값

*   lastEventId 값: 이것을 통해 통신이 끊겨있는동안 받지 못한 이벤트를 받을 수 있습니다.
*   type : 서버에서 전달해주는 이벤트 이름 (default: “message”)
*   data : 서버에서 전달해주는 값

### 요청값

SSE는 서버에서 클라이언트로 일반적인 단방향 통신을 지원합니다. 따라서 도중에 클라이언트가 서버에게 요청하는 방법은 없습니다.

### 🔐 인증

Event-Source 사용하여 서버 전송 이벤트를 구현할 때, 기본적으로는 HTTP 요청에 사용자 정의 헤더를 추가하는 기능을 제공하지 않습니다.

기본적으로, 서버 전송 이벤트(SSE)에서는 클라이언트가 HTTP 요청을 통해 데이터를 수신하는 방식이기 때문에, 인증 토큰이나 기타 정보를 URL 쿼리 파라미터로 전달하는 방식이 일반적입니다.

**URL 쿼리 파라미터 사용**

```javascript
const token = 'your-auth-token'
const eventSource = new EventSource(`your-url-here?token=${token}`)
```

이 방식은 간단하고, 서버에서 해당 토큰을 받아 인증을 처리할 수 있게 해줍니다. 다만, 보안상의 이유로 민감한 정보를 URL에 포함하는 것은 권장되지 않습니다.

**헤더 추가하기**

기본 EventSource API는 사용자 정의 헤더를 추가하는 기능을 제공하지 않지만, [Event-Source-Polyfill](https://www.npmjs.com/package/event-source-polyfill) 라이브러리를 사용하면 헤더를 추가할 수 있습니다. 이 라이브러리를 통해 Authorization 헤더를 포함하는 예시는 다음과 같습니다:

```javascript
import { EventSourcePolyfill } from 'event-source-polyfill'

const eventSource = new EventSourcePolyfill('your-url-here', {
  headers: {
    Authorization: `Bearer ${token}`,
  },
})
```

이렇게 하면 서버 측에서 인증을 위한 헤더를 처리할 수 있습니다.

## Server (kotlin)

*   SseEmitter 객체를 통해 emitter 인스턴스를 생성하고 리턴하면 연결 끝
    
    ```kotlin
    private val emitters: ConcurrentHashMap<String, SseEmitter> = ConcurrentHashMap()
    
        @GetMapping("/stream-sse", produces = [MediaType.TEXT_EVENT_STREAM_VALUE])
        fun streamEvents(@RequestParam(value = "user", required = false, defaultValue = "empty") user: String): SseEmitter {
            val emitter = SseEmitter(60_000L)
            emitters[user] = emitter
            emitter.send(
                    SseEmitter.event().name("message").data(user)
            )
            emitter.onCompletion { emitters.remove(user) }
            emitter.onTimeout { emitters.remove(user) }
    
            return emitter
        }
    ```
    
*   concurrentHansMap 방식 또는 CopyOnWriteArrayList 방식중에서 선택
    
    *   쓰레드로 접근시 값의 충돌이나 점유상태를 안전하게하기 위함
*   client로 발신
    
    ```kotlin
    private val scheduler: TaskScheduler = ConcurrentTaskScheduler(Executors.newSingleThreadScheduledExecutor())
    
    @PostConstruct
        fun startPeriodicTimeEvents() {
            scheduler.scheduleWithFixedDelay({
                // 모든 사용자 중 랜덤하게 한 명을 선택
                if (emitters.isNotEmpty()) {
                    val users = emitters.keys.toList()
                    val selectedUser = users[Random.nextInt(users.size)]
    
                    // 선택된 사용자에게만 메시지 전송
                    emitters[selectedUser]?.let { emitter ->
                        try {
                            val eventId = System.currentTimeMillis().toString()
                            val data = jacksonObjectMapper().writeValueAsString(mapOf("time" to eventId))
                            emitter.send(SseEmitter.event().id(eventId).name("message").data(data, MediaType.APPLICATION_JSON))
                        } catch (e: IOException) {
                            println("Error sending message: $e") // 로그 출력
                            emitters.remove(selectedUser)
                        }
                    }
                }
            }, 2000)
        }
    ```
    

## 예제 코드

*   client (html, css, JS)
    
    ```html
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>SSE Example</title>
        <style>
          /* 테이블 기본 스타일 */
          .table {
            width: 100%; /* 테이블의 너비를 페이지에 맞춤 */
            border-collapse: collapse; /* 테이블 사이의 간격 없애기 */
            font-family: Arial, sans-serif; /* 폰트 스타일 */
          }
    
          /* 테이블 헤더 스타일 */
          .table th {
            background-color: #4caf50; /* 헤더 배경 색 */
            color: white; /* 헤더 텍스트 색 */
            text-align: left; /* 텍스트 정렬 */
            padding: 12px; /* 패딩 */
          }
    
          /* 테이블 바디 셀 스타일 */
          .table td {
            border: 1px solid #ddd; /* 셀 테두리 스타일 */
            padding: 8px; /* 셀 내부 패딩 */
          }
    
          /* 행 호버 스타일 */
          .table tr:hover {
            background-color: #ddd;
          }
    
          /* 반응형 디자인을 위한 미디어 쿼리 */
          @media screen and (max-width: 600px) {
            .table th,
            .table td {
              display: block;
              width: 100%;
            }
          }
    
          .error {
            color: red;
          }
          .open {
            color: blue;
          }
          .message {
            color: green;
          }
          .split-container {
            padding: 0 10px;
            display: flex;
            gap: 10px;
          }
          .split {
            flex: 1;
          }
          .form {
            text-align: center;
            margin: 0 0 10px 0;
          }
        </style>
      </head>
      <body>
        <button class="all-submit">동시 접속</button>
        <div class="split-container">
          <div class="split">
            <form class="form">
              <label>
                사용자 ::
                <input name="user" type="text" value="Alpha User" />
              </label>
              <input type="submit" value="접속" />
            </form>
    
            <table class="table">
              <caption>
                EventStream
              </caption>
              <tr>
                <th>No</th>
                <th>lastEventId</th>
                <th>type</th>
                <th>data</th>
              </tr>
            </table>
          </div>
          <div class="split">
            <form class="form">
              <label>
                사용자 ::
                <input name="user" type="text" value="Beta User" />
              </label>
              <input type="submit" value="접속" />
            </form>
    
            <table class="table">
              <caption>
                EventStream
              </caption>
              <tr>
                <th>No</th>
                <th>lastEventId</th>
                <th>type</th>
                <th>data</th>
              </tr>
            </table>
          </div>
          <div class="split">
            <form class="form">
              <label>
                사용자 ::
                <input name="user" type="text" value="Theta User" />
              </label>
              <input type="submit" value="접속" />
            </form>
    
            <table class="table">
              <caption>
                EventStream
              </caption>
              <tr>
                <th>No</th>
                <th>lastEventId</th>
                <th>type</th>
                <th>data</th>
              </tr>
            </table>
          </div>
        </div>
    
        <script>
          const forms = document.querySelectorAll('.form')
          forms.forEach((form, idx) => {
            form.addEventListener('submit', (event) => {
              event.preventDefault()
              const user = event.target['user'].value
              client(user, idx)
            })
          })
          document.querySelector('.all-submit').addEventListener('click', (event) => {
            const submitBtns = document.querySelectorAll('input[type="submit"]')
            submitBtns.forEach((btn) => btn.click())
          })
    
          const client = (user, idx) => {
            let number = 1
            let eventSource = new EventSource('http://localhost:8080/stream-sse?user=' + user)
            const sseDataElement = document.querySelectorAll('.table')
            function scrollToBottom() {
              window.scrollTo(0, document.body.scrollHeight)
            }
            function addTableRow(event) {
              const trEl = document.createElement('tr')
              trEl.innerHTML = `
                <tr>
                  <td>${number++}</td>
                  <td>${event.lastEventId}</td>
                  <td class="${event.type}">${event.type}</td>
                  <td> ${event.data} </td>
                </tr>
                `
              sseDataElement[idx].append(trEl)
              scrollToBottom(document.body)
            }
            eventSource.addEventListener
            eventSource.onerror = (event) => {
              addTableRow(event)
            }
            eventSource.onmessage = function (event) {
              addTableRow(event)
            }
            eventSource.onopen = (event) => {
              addTableRow(event)
            }
          }
        </script>
      </body>
    </html>
    ```
    
*   server (spring boot, java 17, gradle, jar, kotlin)
    
    ```kotlin
    package com.example.demo.controller
    
    import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
    import jakarta.annotation.PostConstruct
    import org.springframework.http.MediaType
    import org.springframework.scheduling.TaskScheduler
    import org.springframework.scheduling.concurrent.ConcurrentTaskScheduler
    import org.springframework.web.bind.annotation.*
    import org.springframework.web.servlet.mvc.method.annotation.SseEmitter
    import java.io.IOException
    import java.util.concurrent.ConcurrentHashMap
    import java.util.concurrent.Executors
    import kotlin.random.Random
    
    @CrossOrigin(origins = ["*"])
    @RestController
    class SseController {
    
        private val emitters: ConcurrentHashMap<String, SseEmitter> = ConcurrentHashMap()
        private val scheduler: TaskScheduler = ConcurrentTaskScheduler(Executors.newSingleThreadScheduledExecutor())
    
        @GetMapping("/stream-sse", produces = [MediaType.TEXT_EVENT_STREAM_VALUE])
        fun streamEvents(@RequestParam(value = "user", required = false, defaultValue = "empty") user: String): SseEmitter {
            val emitter = SseEmitter(60_000L)
            emitters[user] = emitter
            emitter.send(
                    SseEmitter.event().name("message").data(user)
            )
            emitter.onCompletion { emitters.remove(user) }
            emitter.onTimeout { emitters.remove(user) }
    
            return emitter
        }
    
        @PostConstruct
        fun startPeriodicTimeEvents() {
            scheduler.scheduleWithFixedDelay({
                // 모든 사용자 중 랜덤하게 한 명을 선택
                if (emitters.isNotEmpty()) {
                    val users = emitters.keys.toList()
                    val selectedUser = users[Random.nextInt(users.size)]
    
                    // 선택된 사용자에게만 메시지 전송
                    emitters[selectedUser]?.let { emitter ->
                        try {
                            val eventId = System.currentTimeMillis().toString()
                            val data = jacksonObjectMapper().writeValueAsString(mapOf("time" to eventId))
                            emitter.send(SseEmitter.event().id(eventId).name("message").data(data, MediaType.APPLICATION_JSON))
                        } catch (e: IOException) {
                            println("Error sending message: $e") // 로그 출력
                            emitters.remove(selectedUser)
                        }
                    }
                }
            }, 2000)
        }
    }
    ```