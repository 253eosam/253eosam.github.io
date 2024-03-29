---
layout: post
title: 'Vue.js Performance - 대용량 데이터 처리 방법'
categories: Develop
tags: [JavaScript, Vue.js]
link: https://kdydesign.github.io/2019/04/10/vuejs-performance/
---
<!-- 
# 📖 들어가기

Vue.js 성능 개선시 가장 고려해야할 내용
- Observe 
- defineReactive
이해하고 사용하기

나아가서 computed와 getter 사용을 최소화 하는 것


대규모 프로젝트를 진행하면서 어려웠던 점이 
Vue 성능.. 

Vue의 성능이 느리다는 것은 아니다. Vue는 자기 자신이 할 일을 다하고도 감탄스러운 프레임워크

> Vue의 성능 최적화는 Vue의 core를 수정하는 것이 아니며, Vue의 반응형에 대해서 깊이 있게 알고 확인해본다면 충분히 해결할 수 있다.

<br>

# 빅 데이터 처리

한 페이지에 출력하여 보여줘야 하는 데이터가 10만건 이상일때 문제가된다.

element 개수가 최소 10만개를 넘어가면 웹에서 표현하기 어렵다. 브라우저가 뻗어버리거나 사용이 불가능할 정도의 성능이 나온다.

## client 페이징 처리

물론 10만건의 데이터를 한번에 표현할 수 있다. `virtual scroll 기법`을 사용하여 현재 화면에서 실질적으로 보여지는 row만 DOM을 생성하고 이후 scrolling 시에 이어서 DOM을 업데이트(화면에서 사라지는 부분을 삭제하든, 아니면 업데이트를 해주든) 해 주면 10만건이든 100만건이든 생성되는 DOM의 개수는 제한적이다. 최초 기능의 컨셉을 이렇게 잡고 진행을 하였지만, 

## JS Heap Memory의 최소화

Vue의 성능 최적화를 시키는 방법 결론부터 말하자면 `js heap memory`를 최소화하는 것.

대용량 데이터에 대해 서버 페이징 처리 없이 Front-End 측면에서 처리하기 위해서는 최대한 `js heap memory`를 낮춰야한다.
js heap memory가 증가하면 할수록 UI 상의 모든 컴포넌트가 느려지고 렌더링 역시 느려진다.

메모리가 증가하는 이유는 무언가가 읽고 쓰고 하는 행위를 할 때 증가한다고 볼 수 있다. 변수를 선언할 때에도, **객체의 속성을 읽거나 수정**할 때에도 증가한다. 이렇게 증가한 메모리는 GC(Garbage Collect)에 의해 주기적으로 불필요하게 잡힌 메모리를 해제하여 메모리를 확보하는데 그렇지 않고 계속 쌓이는 경우가 있다. 이럴 경우 일반적으로는 메모리 누수로 판단하고 적절한 조치를 진행한다. 메모리 누수에 대한 몇 가지 조치방법.

- 전역 변수의 사용
- 타이머와 콜백
- 외부에서 참조
- Closures의 사용

Vue에서는 이 내용도 중요하지만 가장 중요한 것은 위에서 언급한 **객체의 속성을 읽거나 수정** 항목이다.

Vue는 data, state, computed, getters와 같은 모델이 선언되면 `defineReactive`를 통해 해당 객체는 반응형 관리 대상으로 등록되어 반응적으로 변경이 되는데 이 과정에서 각 객체마다 `Observe`가 생성되고 내부적으로 getter/setter가 생성된다. 실제로 모델의 데이터를 열어보면 `__Ob__`가 붙은 것을 확인할 수 있다.

생각해보자 10만건에 대해서 객체가 반응형이라면 개체 1개마다 getter/setter가 생성될 것이다. 10만개의 데이터가 단순 배열이 아닌 객체구조라면..? 10만건에 대해 이러한 과정을 거치는 것이(memory write) js heap memory의 증가 이유가 된다.

> 항상 문제가 되는것은 아니다. 하지만 도메인이 많아서 관리할 state 많아지거나 많은 양의 데이터를 관리할때는 고려하는 것이 좋아본인다.

**가장 중요한 것은 대용량의 데이터를 가지고 있는 모델은 Vue의 반응형 관리대상에서 제외를 시키는 것이다.**

## 모델에 대한 가공은 최소화

API를 통해서 데이터를 조회하고 Model또는 State에 담아 놓는 게 일반적이다. 하지만 API를 통해 조회된 데이터가 실제로 화면에 서는 다른 형태의 데이터로 표현해야 하는 경우가 있을 것이다.


 -->
