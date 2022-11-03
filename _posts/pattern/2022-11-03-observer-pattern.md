---
title: Observer pattern
layout: post
category: Pattern
tags: [Observer]
---

## 디자인패턴

23개의 디자인 패턴이 존재하고, 크게 세가지 영역으로 나눌수 있음 (생성, 구조, 행동 패턴)

## Web Observer API

observer 패턴은 행동 패턴에 속함. Observer Pattern은 객체의 상태를 관찰하여, 객체 값의 변화를 감지할 때 사용함. 아래는 MDN에 존재하는 Web Observer API

![Untitled](/assets/post-img/2022-11-03-oberser-pattern/Untitled.png)

Observer는 `start` 와 `disconnect` 를 통해 타겟 객체를 관찰할지 말지를 정할 수 있음.

- 인스턴스를 생성하고 생성자의 파라미터 값으로 콜백함수를 넘겨줄수 있음.  이 콜백함수는 관찰대상이 변경되었을때 notify 할때 사용
- observe 함수를 통해 관찰 대상의 티켓을 받음

[ResizeObserver of Observer API](https://codepen.io/253eosam/pen/PoRZwgb)

ResizeObserver reference code of Web Observer API

## 문제점

사이드 이펙트가 발생가능

- 하나의 이펙트에 다른 이펙트를 물고 있다면 발생 가능.

따라서 필요없는 이벤트는 관찰하면 안되고, 우리가 원하는 실행 순서가 보장되어야하는데 이것을 위해 ReactiveX가 나온것 같음

> ReactiveX는 데이터가 동기식인지 비동기식인지에 관계없이 명령형 프로그래밍 언어가 데이터 시퀀스에서 작동할 수 있도록 하는 Microsoft에서 원래 만든 소프트웨어 라이브러리입니다. 시퀀스의 각 항목에 대해 작동하는 일련의 시퀀스 연산자를 제공합니다.
> 

## hook 과 observer 차이점

hook은 컴포넌트에 묶여서 상태를 관리한다면, observer는 독립적으로 존재하는 객체임

observer는 이벤트 실행되기전까지 state 값을 변경하지않음, 하지만 useEffect는 React의 렌더가 될때까지 이벤트의 실행을 미루고, state를 관련되어 있는 컴포넌트에 바인딩
또, useEffect는 값을 방출하지않지만, oberser는 변경된 값을 push하여 호출한 구독자에게 알려줌(여기서 사이드 발생우려)

## 정리

Observer 패턴을 사용하면 여러 객체에 notify 하기쉽지만 여러 이벤트를 물고있으면 위험함.

---

참고

[Observer 패턴 알아보기 (hooks와 observables)](https://www.howdy-mj.me/javascript/observer-pattern/)

![KakaoTalk_Photo_2022-08-18-10-10-34.jpeg](/assets/post-img/2022-11-03-oberser-pattern/KakaoTalk_Photo_2022-08-18-10-10-34.jpeg)