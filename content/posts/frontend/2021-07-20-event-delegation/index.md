---
layout: post
title: '이벤트 핸들링'
categories: Develop
tags: [DOM, Browser, Vue.js, Event Handling]
---

## 📖 들어가기

이벤트 관련 이슈를 작업 도중 자꾸 헷갈리는 이벤트 수식어와 핸들 과정을 정리해보는 시간을 가져볼까한다.

브라우저에서 이벤트가 어떻게 감지되는지 또 어떻게 전파되는지 확인해본다.

## 이벤트 버블링 - Event Bubbling

이벤트 버블링은 특정 화면 요소에서 이벤트가 발생하였을때 해당 이벤트가 더 상위의 요소들로 전달되는 특징을 말한다.
기본적인 옵션으로 적용되어있다.

![이벤트 버블링](/assets/posts/eventdelegation/event-bubbling.png)

> Tip. HTML은 기본적으로 트리 구조를 갖고있다.

위 지식을 알고있는 사람들은 대충 무슨 말인지 이해하고있을것이다.
하지만 나도 브라우저의 이벤트 동작 원리를 공부하지 않았을땐 반대의 개념으로 이해하고있던터라 상당히 충격이였다.
자세한 내용은 아래 코드를 보면서 이해해보면 좋을 것이다.

![이벤트 버블링 코드](/assets/posts/eventdelegation/event-bubbling-code.png)

초록색 영역을 한번 클릭시 콘솔창에는 `green` > `blue` > `red` 순으로 찍히는 것을 불 수있다. <br>
이것을 통해서 알수있는 것은 **왜 한번의 클릭으로 3개의 이벤트가 발생하였는가?**이다. <br>
그 이유는 브라우저가 이벤트를 감지하는 방식에 있다.

브라우저는 특정 화면 요소에서 이벤트가 발생했을 때 그 이벤트를 최상위에 있는 화면 요소까지 이벤트를 전파시킨다.
따라서 위와 같은 결과를 얻은것이다. 여기서 `blue` 영역을 클릭했다면 `blue` > `red` 의 출력을 볼 수 있을 것이다.

이러한 메커니즘을 이해한다면 자식 요소를 제어하다 부모요소에 등록된 이벤트가 실행되는 현상을 이해할 수 있을 것이다.
또 이벤트를 등록할때 위 방식을 이용한다면 새롭게 추가되는 요소에대한 이벤트 등록을 쉽게 할 수 있습니다. 바로 부모 요소의 이벤트를 등록하는 방법이죠...😋

## 이벤트 캡쳐 - Event Capture

이벤트 캡쳐는 이벤트 버블링과 반대 방향으로 진행되는 이벤트 전파 방식이다.

![이벤트 캡쳐링](/assets/posts/eventdelegation/event-capture.png)

위 방식은 버블링과는 반대되는 개념인데 최상위 요소인 body 태그에서 해당 태그를 찾아 내려간다.

![이벤트 캡쳐링 코드](/assets/posts/eventdelegation/event-capture-code.png)

캡쳐링은 이벤트 옵션을 통해 설정할 수 있다.

위 코드를 입력 후 초록 여역을 클릭한다면 `red` > `blue` > `green` 순으로 출력되는 것을 확인할 수 있다.

## 이벤트 전파 정지 - Event stopPropagation()

위 두가지 방법과는 다른 방식으로 `event.stopPropagation()` 코드를 이벤트 리스너에 등록하시면 이벤트 전달을 막을 수 있습니다.

```js
div.addEventListener('click', evt => {
  evt.stopPropagation()
  console.log(evt.currentTarget.className)
})
```

### 버블링의 경우

- 자기 자신의 요소로 부터 이벤트가 전달되므로 위 코드를 적용하면 본인의 className만 콘솔에 찍히는 것을 알 수 있습니다.

### 캡쳐링의 겨우

- body 태그에서 찾아 내려가므로 가장 외부에 있는 red, blue, green 어느 영역을 눌러도 `red`만 찍히는 것을 알 수 있습니다.

## Vue.js의 이벤트 수식어 정리

| 수식어   | 설명                                                                                               |
| :------- | -------------------------------------------------------------------------------------------------- |
| .stop    | 클릭 이베트 전파가 중단                                                                            |
| .prevent | event.preventDefault() 와 동일                                                                     |
| .capture | 이벤트 캡쳐링                                                                                      |
| .self    | event.target이 엘리먼트 자체인 경우에만 트리거를 처리, 자식에서는 실행안됨                         |
| .once    | 클릭 이벤트는 최대 한번만 트리거                                                                   |
| .passive | 기본 이벤트를 취소할 수 없게함, .preventDefault()를 실행 안되게함.                                 |
| .native  | Vue는 기본 요소에 바인딩되려는 특징을 가지고있음.<br> **생성한 컴포넌트에 이벤트를 등록할때 사용** |

- 수식어는 체이닝이 가능
- 단순히 수식어만 입력 가능 (ex: `@on.submit.prevent`)

---

[참고]

- <https://joshua1988.github.io/web-development/javascript/event-propagation-delegation/>
- <https://kr.vuejs.org/v2/guide/events.html>
