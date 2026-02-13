---
title: Proxy Pattern
layout: post
category: Pattern
tags: [proxy]
---

> **중간에서 흐름을 제어하는 역할**

![Untitled](./images/Untitled.png)

복합적인 오브젝트들의 다수의 복사본이 존재해야하는 상황에서 프록시패턴은 애플리케이션의 메모리 사용량을 줄이기 위해서 사용됨.

클라이언트가 proxy에게 요청을 보내면, 요청을 받은 proxy가 실제 서비스를 하는 메소드를 찾아 호출

- 대리인을 사용하는 것일뿐, 실제 실행은 하지안흥ㅁ

## 장점

- 사이즈가 큰 객체가 로딩되기 전에도 프록시를 통해 참조가능
- 실제 객체의 메소드를 숨길수 있음
- 전처리 및 후처리 사용에 용이

## 단점

- 가독성 저하
- 많이사용하면 성능 저하

---

참고

[프록시 패턴 - 위키백과, 우리 모두의 백과사전](https://ko.wikipedia.org/wiki/%ED%94%84%EB%A1%9D%EC%8B%9C_%ED%8C%A8%ED%84%B4)

![KakaoTalk_Photo_2022-08-18-10-10-34.jpeg](./images/KakaoTalk_Photo_2022-08-18-10-10-34.jpeg)
