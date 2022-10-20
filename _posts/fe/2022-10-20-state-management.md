---
title: 데이터 상태 관리 - 그것을 알려주마 
category: front-end
layout: post
tags: [ AngularJs , jQuery, Redux ]
---

> **[Tech concert : front-end 2019 - 데이터 상태관리. 그것을 알려주마](https://www.youtube.com/watch?v=o4meZ7MRd5o&ab_channel=naverd2)** 세미나를 보고난 후 정리한 내용입니다.

## FE에서 상태관리란?

페이지 작업을 하던 프론트 개발 방식에서 이제는 Web app으로 진화하여 동기, 비동기 로직을 수행하고 API를 AJAX를 통해 통신하게된다.

API를 통해 데이터를 주고 받으면서 상태관리에 대한 개념이 생기게된다.

## jQuery의 상태관리

웹 페이지는 3가지 구성으로 나눠진다. (HTML, CSS, JavaScript)
HTML은 layout, CSS는 스타일, JS는 동작을 수행하는 것을 기본원리로 사용하고, 여기서 jQuery는 HTML로 마크업된 태그에 동작을 입혀서 사용한다.
이렇게 HTML의 DOM을 기준으로 동작을 정의하며 동작의 base가 되는 Element의 data-set을 통해서 상태를 관리하는 방법이 있다.

Element에서 상태를 가져와 동작을 수행하는 방식은 **복잡하고 얽혀있는 상태를 이용한 동작 도중** 특정 element의 상태가 변경되었을때 예상과 다른 결과를 나올 수 있데, **jQuery 특성상 DOM에 동작을 입히는 방식이라 왜, 어떻게, 언제 변경되었는지 파악하는게 쉽지가 않다.**

간단한 페이지를 만드는 것에는 장점이 있을 수 있겠지만, 복잡한 상태를 다루는 화면에서는 jQuery로 관리하는것은 상당히 힘들고 어려운 작업이다. 이러한 방식에서 AngularJS는 새로운 방식의 상태관리 방법을 가지고 나온다.

## AngularJS의 상태관리

기존 방식은 변경이 필요한 대상의 Element를 선택하고, 이후 필요한 작업을 수행하는 형태로 진행하였다.

반면 AngularJS는 출력할 데이터에 초점을 맞추어 작입이 수행되며, 데이터의 값이 변경되면 화면도 자동적으로 변경되게 처리한다.

![angularJS_state_management](https://velog.velcdn.com/images/253eosam/post/305231e0-2298-41fd-8cff-6465a4112373/image.png)

- controller의 state를 통해 view를 구성한다.
- 공통된 상태값은 service를 통해관리하고 conteroller는 service에 접근하여 service state를 가져와 화면을 구성한다.

### 서비스를 이용한 데이터 관리 순서

![service modules](https://velog.velcdn.com/images/253eosam/post/79912cf1-ccf6-4833-8924-1c893574952f/image.png)

1. 서비스에서 데이터를 가져온다.
2. 가져온 데이터를 조합한다.
3. API를 호출한다.
4. 응답값을 받는다.
5. 응답값을 정제한다.
6. 모듈을 업데이트한다.

> API 호출도중 누군가의 개입으로 상태가 변경된다면 이것또한 예상치 못한 결과를 얻을 것이다. 서비스 모듈을 이용한다고해서 버그를 막을 순 없다. 
>
> 하지만 jQuery의 상태관리 방식보다 확인해야할 코드량이 줄어들어 보다 쉽고 빠르게 파악이 가능하다.

## Redux의 상태관리

상태(데이터)를 언제, 왜, 어떻게 변했는지 알기가 어렵다. 그것을 해결하기 위해서 Redux library가 생겼다.

Flux, CQRS, EventSourcing을 조합하여 만든 라이브러리

### Flux 

![flux](https://velog.velcdn.com/images/253eosam/post/ac49c85f-759d-4e90-9800-1426091c61e6/image.png)

- state를 변경하기 위해서는 action을 통해 변경해야한다.
- action은 dispatcher를 통해 상태값을 변경하고 변경된 state는 view를 그려낸다.
- action(쓰기), dispatcher(업데이트), state(상태), view(읽고/그리기)

### CQRS (Command and Query Responsibility Segregation) & EventSourcing

![cqrs](https://velog.velcdn.com/images/253eosam/post/a6998cae-94a9-472e-919d-079d4b662616/image.png)

### Redux

![redux](https://velog.velcdn.com/images/253eosam/post/343216c2-ed87-42c8-9c3a-785dd7fa47a1/image.png)

- 상태를 바꾸고 싶다면 reducer를 통해 변경하며 기록을 남긴다.
- state는 항상 읽기전용이다. 이것을 `=`을 통해 변경하려하면 reducer가 새로운 state를 생성하고 이것을 바꿔치기하는 것이기 때문에 매번 새로운 객체가 생기게된다 (물론 가비지가 지워주겠지만)

### Redux의 문제점

하지만 보일러플레이트가 많고, 간단한 작업에서도 많은 코드들이 작성되고 구조가 더 복잡해지다보니 과한 기술이 아니냐는 문제점도 있습니다. 

- 보일러플레이트가 많다. 
- 과한 기술

---

참고자료

- https://www.youtube.com/watch?v=o4meZ7MRd5o&ab_channel=naverd2
