---
title: "코어 자바스크립트 책을 읽고 실무에서 확인해본 개념들"
category: javascript
layout: post
tags: [JavaScript, 실행컨텍스트, this, 클로저, 데이터타입]
description: "코어 자바스크립트 책을 읽고 실무에서 자주 마주치는 개념들을 직접 확인해보면서 정리한 내용입니다. 특히 실행 컨텍스트와 this 바인딩 관련해서 실제 경험한 내용을 포함했습니다."
---

회사에서 JavaScript 코드를 리팩토링하다가 스코프와 this 관련해서 예상과 다르게 동작하는 경우가 많아서 기초를 다시 정리해야겠다고 생각했습니다.

## 책을 읽게 된 계기

특히 이런 코드에서 문제가 생겼어요:

```js
const ApiService = {
  baseUrl: 'https://api.example.com',

  fetchData: function(endpoint) {
    return fetch(this.baseUrl + endpoint)
      .then(response => response.json())
      .then(data => {
        this.processData(data); // 여기서 에러!
      });
  },

  processData: function(data) {
    console.log('Processing:', data);
  }
};
```

`this.processData is not a function` 에러가 계속 발생해서 근본적으로 this가 어떻게 동작하는지 알아보려고 책을 읽게 되었습니다.

## 실무에서 자주 마주치는 개념들

### 1. 데이터 타입과 메모리 관리

#### 변수 영역과 데이터 영역의 분리

JavaScript가 변수 영역과 데이터 영역을 분리해서 관리한다는 걸 알고 나니 왜 이런 코드가 메모리 효율적인지 이해됐어요:

```js
// 같은 문자열을 여러 변수에 할당
const message1 = "안녕하세요";
const message2 = "안녕하세요";
const message3 = "안녕하세요";

// 실제로는 하나의 데이터 영역을 참조
// 메모리 주소: @5002 "안녕하세요"
// message1, message2, message3 모두 @5002를 참조
```

실무에서는 상수 관리할 때 이런 특성을 활용하고 있어요:

```js
// API 상수들
const API_ENDPOINTS = {
  USERS: '/api/users',
  ORDERS: '/api/orders',
  PRODUCTS: '/api/products'
};

// 여러 파일에서 import해도 메모리는 한 번만 할당
```

#### 배열의 empty와 undefined 차이

이 부분은 실제로 버그를 만들어본 경험이 있어요:

```js
// 처음에 이렇게 배열을 만들었더니
const items = new Array(3);
console.log(items); // [empty × 3]

// map이 동작하지 않음
items.map((item, index) => index); // 여전히 [empty × 3]

// 이렇게 해야 제대로 동작
const items2 = Array(3).fill(undefined);
items2.map((item, index) => index); // [0, 1, 2]
```

배열 메서드들이 empty를 순회 대상에서 제외한다는 걸 몰라서 한참 삽질했던 기억이 있습니다.

### 2. 실행 컨텍스트와 스코프 체인

#### 렉시컬 스코프의 실제 경험

책에서 나온 이 예제가 실무 상황과 정확히 일치했어요:

```js
// 전역에서 설정한 API URL
const apiUrl = 'https://prod-api.example.com';

function createApiClient() {
  console.log(apiUrl); // 전역의 apiUrl 참조
}

function initializeApp() {
  const apiUrl = 'https://dev-api.example.com'; // 지역 변수
  createApiClient(); // 여전히 전역 apiUrl 출력
}

initializeApp(); // "https://prod-api.example.com"
```

함수가 **선언된 위치**에서 스코프가 결정된다는 게 실무에서는 이런 식으로 나타납니다.

### 3. this 바인딩 문제 해결

#### 처음 겪었던 문제의 해결

```js
const ApiService = {
  baseUrl: 'https://api.example.com',

  fetchData: function(endpoint) {
    return fetch(this.baseUrl + endpoint)
      .then(response => response.json())
      .then(data => {
        // 화살표 함수로 변경해서 해결
        this.processData(data); // 이제 정상 동작
      });
  },

  processData: function(data) {
    console.log('Processing:', data);
  }
};
```

화살표 함수가 this를 바인딩하지 않아서 상위 스코프의 this를 그대로 사용한다는 걸 알고 나서 해결됐어요.

#### 실무에서 자주 쓰는 this 우회 패턴

```js
// 1. 전통적인 self 패턴
const component = {
  name: 'UserList',

  init: function() {
    const self = this; // this 저장

    document.addEventListener('click', function() {
      self.handleClick(); // self로 접근
    });
  },

  handleClick: function() {
    console.log(this.name + ' clicked');
  }
};

// 2. 화살표 함수 패턴 (더 간단)
const component2 = {
  name: 'UserList',

  init: function() {
    document.addEventListener('click', () => {
      this.handleClick(); // 바로 this 사용 가능
    });
  }
};
```

### 4. 클로저 활용 사례

#### 실무에서 클로저를 사용하는 경우

API 요청 캐싱 로직에서 클로저를 활용하고 있어요:

```js
function createApiCache() {
  const cache = new Map(); // private 변수

  return {
    get: function(key) {
      return cache.get(key);
    },

    set: function(key, value) {
      cache.set(key, value);
    },

    clear: function() {
      cache.clear();
    }
  };
}

const userCache = createApiCache();
const productCache = createApiCache();

// cache 변수에 직접 접근 불가, 정보 은닉화 달성
```

#### 메모리 관리 주의사항

클로저 사용할 때 메모리 누수 방지를 위해 이렇게 처리해요:

```js
function setupEventHandler() {
  const heavyData = new Array(1000000).fill('data'); // 큰 데이터

  const handler = function() {
    // heavyData 사용
    console.log('Handler called');
  };

  document.addEventListener('click', handler);

  // 정리 함수 반환
  return function cleanup() {
    document.removeEventListener('click', handler);
    // heavyData는 자동으로 가비지 컬렉션 대상이 됨
  };
}

const cleanup = setupEventHandler();
// 나중에 정리할 때
cleanup();
```

## 책을 읽고 달라진 점

### 1. this 바인딩 예측 가능해짐

이제 함수 호출 방식을 보면 this가 무엇인지 바로 알 수 있어요:

```js
// 1. 메서드 호출: 점 앞의 객체가 this
obj.method(); // this = obj

// 2. 함수 호출: 전역 객체가 this
function func() {}
func(); // this = window (브라우저) or global (Node.js)

// 3. 생성자 호출: 새로 만들어진 인스턴스가 this
new Constructor(); // this = 새 인스턴스

// 4. call/apply/bind: 명시적으로 지정한 객체가 this
func.call(obj); // this = obj
```

### 2. 스코프 관련 버그 줄어듦

변수 선언 위치를 더 신중하게 결정하게 되었어요:

```js
// Before: 혼란스러운 스코프
function processUsers() {
  for (var i = 0; i < users.length; i++) {
    setTimeout(function() {
      console.log(users[i]); // undefined (i는 이미 users.length)
    }, 100);
  }
}

// After: 명확한 스코프
function processUsers() {
  for (let i = 0; i < users.length; i++) {
    setTimeout(function() {
      console.log(users[i]); // 의도한 대로 동작
    }, 100);
  }
}
```

### 3. 메모리 효율적인 코드 작성

데이터 영역과 변수 영역의 분리를 이해하고 나니 더 효율적인 코드를 작성하게 되었어요:

```js
// 상수는 한 곳에 모아서 관리 (메모리 재사용)
const CONSTANTS = {
  API_BASE_URL: 'https://api.example.com',
  MAX_RETRY_COUNT: 3,
  TIMEOUT_MS: 5000
};

// 함수형 프로그래밍에서 불변성 유지
const updateUser = (user, updates) => ({
  ...user,
  ...updates,
  updatedAt: new Date().toISOString()
});
```

JavaScript의 기본 동작 원리를 이해하니 코드 작성할 때 훨씬 자신감이 생겼고, 예상치 못한 버그도 많이 줄어들었습니다.
