---
title: 'JavaScript 이벤트 루프의 작업 단위: 매크로 테스크와 마이크로 테스크'
date: '2025-09-23'
category: 'frontend'
tags: ['JavaScript', '이벤트루프', '비동기', 'Promise', 'setTimeout', '웹개발']
description: '매크로 테스크와 마이크로 테스크의 실행 순서를 정확히 이해하고 복잡한 비동기 코드의 동작을 예측하는 방법'
thumbnail: ''
status: 'ready-to-publish'
velog_url: ''
quality_score: '8.5'
---

# JavaScript 이벤트 루프의 작업 단위: 매크로 테스크와 마이크로 테스크

비동기 코드를 작성할 때 이런 경험 있으시죠?

```javascript
console.log('시작');

setTimeout(() => console.log('setTimeout'), 0);

Promise.resolve().then(() => console.log('Promise'));

console.log('끝');
```

이 코드의 출력 순서를 정확히 예측할 수 있나요? 많은 개발자들이 `setTimeout`의 딜레이가 0이니까 바로 실행될 거라고 생각하지만, 실제로는 Promise가 먼저 실행됩니다.

실제 출력 결과는 다음과 같습니다:
```
시작
끝
Promise
setTimeout
```

이런 현상이 일어나는 이유를 정확히 알고 있다면, 복잡한 비동기 코드의 실행 순서도 정확히 예측할 수 있습니다. 핵심은 바로 **매크로 테스크(Macro Task)**와 **마이크로 테스크(Micro Task)**의 개념을 이해하는 것입니다.

## 매크로 테스크와 마이크로 테스크란?

JavaScript의 이벤트 루프는 두 가지 종류의 작업 큐를 관리합니다.

### 매크로 테스크 (Macro Task)
브라우저나 Node.js가 제공하는 비동기 API들이 생성하는 작업들입니다.

**주요 매크로 테스크들:**
- `setTimeout` / `setInterval`
- `setImmediate` (Node.js)
- I/O 작업 (파일 읽기, 네트워크 요청)
- UI 이벤트 (click, scroll 등)
- MessageChannel
- postMessage

### 마이크로 테스크 (Micro Task)
JavaScript 엔진 자체에서 생성하는 작업들로, 매크로 테스크보다 높은 우선순위를 가집니다.

**주요 마이크로 테스크들:**
- `Promise.then()` / `Promise.catch()` / `Promise.finally()`
- `async/await`
- `queueMicrotask()`
- `MutationObserver` (브라우저)
- `process.nextTick` (Node.js, 최고 우선순위)

## 이벤트 루프의 실행 순서

이벤트 루프는 다음과 같은 순서로 작업을 처리합니다:

1. **현재 실행 중인 코드 완료** (Call Stack이 비워질 때까지)
2. **모든 마이크로 테스크 처리** (마이크로 테스크 큐가 빌 때까지)
3. **하나의 매크로 테스크 처리**
4. **다시 2번으로 돌아가서 반복**

이를 간단히 표현하면:
```
동기 코드 → 모든 마이크로 테스크 → 하나의 매크로 테스크 → 모든 마이크로 테스크 → ...
```

## 실제 코드로 살펴보는 실행 순서

### 기본 예제

```javascript
console.log('1'); // 동기 코드

setTimeout(() => console.log('2'), 0); // 매크로 테스크

Promise.resolve().then(() => console.log('3')); // 마이크로 테스크

console.log('4'); // 동기 코드
```

**실행 과정:**
1. `console.log('1')` 실행 → 출력: `1`
2. `setTimeout` 콜백이 매크로 테스크 큐에 추가
3. `Promise.then` 콜백이 마이크로 테스크 큐에 추가
4. `console.log('4')` 실행 → 출력: `4`
5. 동기 코드 완료, 마이크로 테스크 처리 → 출력: `3`
6. 매크로 테스크 처리 → 출력: `2`

**최종 출력:** `1`, `4`, `3`, `2`

### 조금 더 복잡한 예제

```javascript
console.log('시작');

setTimeout(() => {
  console.log('매크로 1');
  Promise.resolve().then(() => console.log('매크로 1 안의 마이크로'));
}, 0);

setTimeout(() => console.log('매크로 2'), 0);

Promise.resolve().then(() => {
  console.log('마이크로 1');
  return Promise.resolve();
}).then(() => console.log('마이크로 2'));

console.log('끝');
```

**실행 과정 분석:**
1. `console.log('시작')` → 출력: `시작`
2. 첫 번째 `setTimeout` 콜백이 매크로 테스크 큐에 추가
3. 두 번째 `setTimeout` 콜백이 매크로 테스크 큐에 추가
4. `Promise.then` 체인이 마이크로 테스크 큐에 추가
5. `console.log('끝')` → 출력: `끝`
6. 모든 마이크로 테스크 처리:
   - `마이크로 1` 출력
   - `마이크로 2` 출력
7. 첫 번째 매크로 테스크 처리:
   - `매크로 1` 출력
   - 새로운 마이크로 테스크 생성
8. 마이크로 테스크 처리: `매크로 1 안의 마이크로` 출력
9. 두 번째 매크로 테스크 처리: `매크로 2` 출력

**최종 출력:**
```
시작
끝
마이크로 1
마이크로 2
매크로 1
매크로 1 안의 마이크로
매크로 2
```

## async/await와 실행 순서

`async/await`도 내부적으로는 Promise를 사용하므로 마이크로 테스크로 처리됩니다.

```javascript
async function test() {
  console.log('async 함수 시작');

  await Promise.resolve();
  console.log('await 이후'); // 마이크로 테스크

  setTimeout(() => console.log('async 안의 setTimeout'), 0);
}

console.log('1');
test();
console.log('2');

setTimeout(() => console.log('외부 setTimeout'), 0);
```

**출력 결과:**
```
1
async 함수 시작
2
await 이후
외부 setTimeout
async 안의 setTimeout
```

`await` 이후의 코드는 마이크로 테스크로 처리되기 때문에 `setTimeout`보다 먼저 실행됩니다.

## 흔한 함정과 디버깅 팁

### 1. 무한 마이크로 테스크 함정

```javascript
function infiniteMicrotask() {
  Promise.resolve().then(() => {
    console.log('마이크로 테스크 실행');
    infiniteMicrotask(); // 계속해서 새로운 마이크로 테스크 생성
  });
}

setTimeout(() => console.log('이것은 절대 실행되지 않음'), 0);

infiniteMicrotask();
```

마이크로 테스크가 계속 생성되면 매크로 테스크는 영원히 실행되지 않습니다. 브라우저가 멈춘 것처럼 보일 수 있으니 주의하세요.

### 2. Promise 체인에서의 실행 순서

```javascript
Promise.resolve()
  .then(() => {
    console.log('첫 번째 then');
    return Promise.resolve();
  })
  .then(() => console.log('두 번째 then'));

Promise.resolve()
  .then(() => console.log('다른 Promise의 then'));
```

**출력 결과:**
```
첫 번째 then
다른 Promise의 then
두 번째 then
```

`Promise.resolve()`를 반환하면 추가적인 마이크로 테스크 틱이 필요합니다.

### 3. 실행 순서 예측 체크리스트

복잡한 비동기 코드를 분석할 때 다음 순서로 확인해보세요:

1. **동기 코드를 모두 찾아 순서대로 나열**
2. **각 비동기 작업이 언제 큐에 추가되는지 확인**
3. **마이크로 테스크와 매크로 테스크를 구분**
4. **동기 코드 완료 후 마이크로 테스크부터 처리**
5. **각 매크로 테스크 후에 마이크로 테스크 큐 확인**

### 4. 디버깅할 때 유용한 코드

실행 순서를 시각적으로 확인하고 싶다면:

```javascript
function logWithType(message, type) {
  console.log(`[${type}] ${message}`);
}

console.log = ((originalLog) => {
  return function(message) {
    originalLog.call(console, `[SYNC] ${message}`);
  };
})(console.log);

// 사용 예시
console.log('동기 코드');
setTimeout(() => logWithType('매크로 테스크', 'MACRO'), 0);
Promise.resolve().then(() => logWithType('마이크로 테스크', 'MICRO'));
```

## 브라우저별, 환경별 차이점

### Node.js의 특별한 경우

Node.js에는 `process.nextTick`이라는 특별한 마이크로 테스크가 있습니다:

```javascript
setTimeout(() => console.log('setTimeout'), 0);
setImmediate(() => console.log('setImmediate'));
process.nextTick(() => console.log('nextTick'));
Promise.resolve().then(() => console.log('Promise'));

// Node.js 출력 순서: nextTick → Promise → setTimeout → setImmediate
```

`process.nextTick`은 일반 마이크로 테스크보다도 높은 우선순위를 가집니다.

### 브라우저 호환성

대부분의 모던 브라우저는 동일한 방식으로 동작하지만, 아주 오래된 브라우저에서는 차이가 있을 수 있습니다. 실제 개발 환경에서 테스트해보는 것이 좋습니다.

## 실무에서 활용하기

### 성능 최적화

마이크로 테스크의 높은 우선순위를 활용해 중요한 작업을 우선 처리할 수 있습니다:

```javascript
// 사용자 인터랙션에 즉시 반응
button.addEventListener('click', () => {
  // 중요한 상태 업데이트는 마이크로 테스크로
  Promise.resolve().then(() => {
    updateCriticalState();
    renderImportantUI();
  });

  // 무거운 작업은 매크로 테스크로 지연
  setTimeout(() => {
    performHeavyCalculation();
  }, 0);
});
```

### 테스트 코드 작성

비동기 테스트를 작성할 때 실행 순서를 정확히 예측할 수 있습니다:

```javascript
test('비동기 실행 순서 테스트', async () => {
  const results = [];

  setTimeout(() => results.push('macro'), 0);
  Promise.resolve().then(() => results.push('micro'));

  // 마이크로 테스크가 완료될 때까지 대기
  await Promise.resolve();
  expect(results).toEqual(['micro']);

  // 매크로 테스크까지 완료 대기
  await new Promise(resolve => setTimeout(resolve, 0));
  expect(results).toEqual(['micro', 'macro']);
});
```

## 정리하며

이벤트 루프의 작업 단위를 이해하면 다음과 같은 능력을 얻을 수 있습니다:

- **복잡한 비동기 코드의 실행 순서를 정확히 예측**
- **성능 문제의 원인을 빠르게 파악**
- **더 효율적인 비동기 코드 작성**
- **디버깅 시간 단축**

핵심 규칙을 다시 한번 정리하면:
1. 동기 코드가 가장 먼저 실행
2. 마이크로 테스크가 매크로 테스크보다 높은 우선순위
3. 각 매크로 테스크 실행 후 마이크로 테스크 큐를 완전히 비움
4. `process.nextTick` (Node.js)이 가장 높은 우선순위

다음에 복잡한 비동기 코드를 만나면 이 규칙들을 떠올려 보세요. 처음에는 어려울 수 있지만, 몇 번 연습하다 보면 코드만 보고도 실행 순서를 정확히 예측할 수 있게 됩니다.