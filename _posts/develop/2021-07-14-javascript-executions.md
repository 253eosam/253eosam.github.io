---
layout: post
title: 'JavaScript 동작방법 이해하기'
categories: Develop
tags: [JavaScript]
---

## 📖 들어가기

자바스크립트는 싱글 스레드로 돌아가는 언어이다. 하지만 비동기적 로직들로 인해 이를 헷갈려하는 사람들이 존재한다. 그래서 자바스크립트가 어떤 방식으로 동작하는지에 대해서 알아보고 왜 **싱글 스레드**인지를 학습하려합니다.

자바스크립트가 동작하는 방법을 이해하기 위해서는 JS 모델의 Call stack, Heap, Web APIs, Queue들이 어떤 역할을 수행하는지를 알아야합니다. <br>

![js model](/assets/posts/javascript-executions/js_model.png)

## Call Stack

> 기능 호출을 기록하는 데이터 구조

실행하고자하는 코드를 stack에 밀어넣고 하나하나 뽑아서 사용합니다.
이때 코드라고한다면 `console.log(1)`와 같은 한줄 코드도 될 수 있고, `function fn ()` 함수도 될 수 있습니다.

함수의 경우에는 함수 내의 또 다른 함수의 호출이 있으면 계속 추적하면서 stack을 쌓아갑니다.

![call stack execution](https://miro.medium.com/max/600/1*E3zTWtEOiDWw7d0n7Vp-mA.gif)

call stack은 한번에 하나의 일만 수행하는데 이 동작 방식때문에 JS를 싱글 스레드 방식이라고합니다. (Single Call Stack)

## Heap

> 메모리를 할당받는 영역

변수와 같은 메로리를 할당받는 녀석들이 이곳에 저장됩니다.

## 비동기 로직

> 자바 스크립트는 `동기적인 언어`

자바스크립트에서 지원하는 비동기 로직으로는 Timer, 이벤트 리스너, AJAX 등을 뽑아볼 수 있는데 이런 비동기적 로직들은 call stack에 쌓였을때 일반 코드와는 다른 방식으로 동작합니다.<br>

![javascript event loop](/assets/posts/javascript-executions/javascript_event_loop.png)

위 그림을 보면 call stack에 비동기 코드가 들어오면 이를 Web APIs 영역으로 보낸다. 그리고 여기서 비동기적 로직이 수행되고 수행된 결과값은 Callback의 Queue에 쌓이게된다. 그리고 이때 call stack이 비어있을경우 callback queue에 들어있던 값들이 스택에 들어오게됩니다.

### 예를들어

아래와 같은 코드에서 위 동작을 이해한다면 예상되는 결과는 🧐 ?

```js
console.log(1)
setTimeout(() => console.log(2), 0)
console.log(3)
```

`1 3 2`가 순서대로 찍히는 것을 볼 수있습니다.

### 결과적으로

위 매커니즘을 이해했다면 아래 교훈을 얻을 수 있습니다.

1. 스택을 바쁘게 하지 않는다.

   스택에 어려운 연산을 넣는다면 퍼포먼스가 급격하게 떨어지는 것을 체감하실 수 있을껍니다.

2. 큐를 적게 사용한다.

---

참고

- <https://medium.com/@gaurav.pandvia/understanding-javascript-function-executions-tasks-event-loop-call-stack-more-part-1-5683dea1f5ec>
