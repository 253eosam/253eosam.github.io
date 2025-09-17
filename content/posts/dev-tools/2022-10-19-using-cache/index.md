---
title: 자바스크립트 - 캐시를 적용시킨 코드
category: javascript
layout: post
tag: ['javascript', 'cache']
---

## 🧑‍💻 Content

### 캐시란?

**자주 사용하는 데이터나 값을 미리 복사해 놓는 임시 장소**를 가르킨다.

### 사용하기 좋은 조건

**동일한 결과**를 돌려주는 경우에 아래 조건만 맞다면 사용을 고려하면 좋다.

- 복잡한 연산
- 반복적인 호출

### 사용하면 좋은점

Cache에 데이터를 미리 복사해 놓으면 계산이나 접근 시간 없이 빠르게 데이터를 가지고 올 수 있다.
결국 Cache는 반복적으로 데이터를 불러와야할 경우에, 지속적으로 같은 코드(연산)를 반복시키는 것이 아닌 이미 계산을 끝낸 코드(연산) 결과값 접근하는 것이다. 이렇게되면 필요하지않은 Memory를 할당하게되어 저장공간적으로는 손해이지만, 속도면에서 높은 성능을 발휘할 수 있다.

## 사용방법

1. 로직 작성
    - 리턴값이 있는 함수이여야한다.
2. 캐시를 함수를 작성
3. 함수의 결과에 대한 캐시 공간을 만든다.

```js
const MAX = 100_000_000

function myLogic (p) {
  for(let i = 0 ; i < MAX; i++) {}
    
  return p
}

function useCache (fn) {
  let cache = {}
  return function (p) {
    if (! cache[p] ) {
      cache[p] = fn(p)
    }
    return cache[p]
  }
}

function printPlayTime (fn) {
  let start = Date.now(); 
  const value = fn()
  let end = Date.now();  

  console.log(`Logic ${value} :: ${end - start}s`)
}

// normal
printPlayTime( myLogic.bind(null, 'A') )  // 67s

// using cache
const usedCacheMyLogic = useCache(myLogic)
printPlayTime( usedCacheMyLogic.bind(null, 'B') ) // 64s
printPlayTime( usedCacheMyLogic.bind(null, 'B'), ) // 0s
```

### 필요성

![Long Tail 법칙 그래프](https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fk.kakaocdn.net%2Fdn%2Fbzw7IJ%2FbtqCaglKbIT%2FUpQYleNiW3pKQsOrzYLR5K%2Fimg.jpg)

위 그래프는 Long Tail 법칙의 그래프이다.
위 그래프는 **20%의 요구가 시스템 리소스의 대부분을 사용한다는 법칙**이다.
그렇기 때문에 20%의 기능에 캐시를 적용한다면 리소스를 대폭 줄이고, 성능을 향상시킬 수 있다.