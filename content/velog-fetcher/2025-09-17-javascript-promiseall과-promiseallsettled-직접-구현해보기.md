---
title: "JavaScript Promise.all과 Promise.allSettled 직접 구현해보기"
date: "2025-09-17T07:45:51.812Z"
tags:
  - promise
  - 동시성
description: "Promise는 JavaScript의 비동기 처리를 위한 핵심 개념입니다. 특히 여러 개의 비동기 작업을 동시에 처리할 때 Promise.all과 Promise.allSettled를 자주 사용하게 되는데, 이들이 내부적으로 어떻게 동작하는지 직접 구현해보면서 이해해보겠"
url: "https://velog.io/@253eosam/JavaScript-Promise.all%EA%B3%BC-Promise.allSettled-%EC%A7%81%EC%A0%91-%EA%B5%AC%ED%98%84%ED%95%B4%EB%B3%B4%EA%B8%B0"
---

Promise는 JavaScript의 비동기 처리를 위한 핵심 개념입니다. 특히 여러 개의 비동기 작업을 동시에 처리할 때 `Promise.all`과 `Promise.allSettled`를 자주 사용하게 되는데, 이들이 내부적으로 어떻게 동작하는지 직접 구현해보면서 이해해보겠습니다.

## async/await vs .then() 병렬 처리의 차이점

먼저 많은 개발자들이 헷갈려하는 부분부터 살펴보겠습니다.

### async/await의 한계

```javascript
// 이렇게 하면 순차 실행됩니다
const sequentialExecution = async (promises) => {
  const results = []
  for (let i = 0; i < promises.length; i++) {
    const value = await Promise.resolve(promises[i]) // 하나씩 기다림
    results[i] = value
  }
  return results
}
```

async/await은 코드가 깔끔하지만 `await` 키워드가 해당 Promise가 완료될 때까지 기다리기 때문에 순차적으로 실행됩니다.

### 진정한 병렬 처리

```javascript
// .then()을 사용한 병렬 실행
const parallelExecution = (promises) => {
  return new Promise((resolve, reject) => {
    const results = new Array(promises.length)
    let completed = 0

    promises.forEach((promise, index) => {
      Promise.resolve(promise) // 즉시 시작
        .then(value => {
          results[index] = value
          completed++
          if (completed === promises.length) {
            resolve(results)
          }
        })
        .catch(reject)
    })
  })
}
```

`.then()` 방식에서는 모든 Promise가 동시에 시작되고 각각 독립적으로 완료됩니다.

## Promise.all 직접 구현하기

Promise.all의 특징을 먼저 정리해보겠습니다:

*   모든 Promise가 성공하면 결과를 배열로 반환
*   하나라도 실패하면 즉시 reject
*   입력 순서대로 결과 반환
*   빈 배열이면 즉시 빈 배열 반환

```javascript
const promiseAll = (promises) => {
  return new Promise((resolve, reject) => {
    // 빈 배열 처리
    if (promises.length === 0) {
      return resolve([])
    }

    const results = new Array(promises.length)
    let completed = 0

    promises.forEach((promise, index) => {
      Promise.resolve(promise) // Promise가 아닌 값도 처리
        .then(value => {
          results[index] = value // 순서 보장
          completed++
          if (completed === promises.length) {
            resolve(results)
          }
        })
        .catch(reject) // 하나라도 실패하면 즉시 reject
    })
  })
}
```

### 핵심 포인트

1.  **Promise.resolve() 사용**: Promise가 아닌 일반 값도 처리할 수 있습니다
2.  **인덱스 기반 결과 저장**: 완료 순서와 관계없이 입력 순서를 보장합니다
3.  **즉시 reject**: 하나라도 실패하면 나머지를 기다리지 않고 바로 실패 처리합니다

## Promise.allSettled 구현하기

Promise.allSettled는 Promise.all과 다르게 모든 Promise의 완료를 기다립니다:

```javascript
const promiseAllSettled = (promises) => {
  return new Promise((resolve) => {
    if (promises.length === 0) {
      return resolve([])
    }

    const results = new Array(promises.length)
    let completed = 0

    promises.forEach((promise, index) => {
      Promise.resolve(promise)
        .then(value => {
          results[index] = { status: 'fulfilled', value }
          completed++
          if (completed === promises.length) {
            resolve(results)
          }
        })
        .catch(reason => {
          results[index] = { status: 'rejected', reason }
          completed++
          if (completed === promises.length) {
            resolve(results)
          }
        })
    })
  })
}
```

### Promise.allSettled의 특징

*   성공/실패 상관없이 모든 Promise 완료까지 기다림
*   결과를 `{ status, value/reason }` 형태로 반환
*   절대 reject되지 않음 (항상 resolve)

## 실제 테스트해보기

구현한 함수들이 제대로 동작하는지 확인해보겠습니다:

```javascript
const runTests = async () => {
  console.log('=== Promise.all 테스트 ===')

  // 성공 케이스
  try {
    const result1 = await promiseAll([
      Promise.resolve(1),
      2, // Promise가 아닌 값
      Promise.resolve(3)
    ])
    console.log('✅ 성공 케이스:', result1) // [1, 2, 3]
  } catch (error) {
    console.log('❌ 예상치 못한 에러:', error)
  }

  // 실패 케이스
  try {
    const result2 = await promiseAll([
      Promise.resolve(1),
      promiseReject('error'),
      Promise.resolve(3)
    ])
    console.log('❌ 실패해야 하는데 성공:', result2)
  } catch (error) {
    console.log('✅ 실패 케이스 정상:', error) // "error"
  }

  // allSettled 테스트
  const result3 = await promiseAllSettled([
    Promise.resolve(1),
    promiseReject('error'),
    Promise.resolve(3)
  ])
  console.log('✅ allSettled 결과:', result3)
  // [
  //   { status: "fulfilled", value: 1 },
  //   { status: "rejected", reason: "error" },
  //   { status: "fulfilled", value: 3 }
  // ]
}

runTests()
```

## 정리

이번 포스트에서 다룬 내용들을 정리하면:

1.  **병렬 처리의 중요성**: async/await은 순차 실행, `.then()`은 병렬 실행
2.  **Promise.all**: 하나라도 실패하면 즉시 실패, 모두 성공하면 결과 배열 반환
3.  **Promise.allSettled**: 모든 Promise 완료까지 기다리며 성공/실패 정보를 모두 포함
4.  **구현의 핵심**: `forEach`로 동시 시작, 카운터로 완료 확인, 인덱스로 순서 보장

Promise의 내부 동작을 이해하면 비동기 코드를 더 효율적으로 작성할 수 있습니다. 특히 여러 API 호출을 동시에 처리할 때 이런 지식이 큰 도움이 됩니다.

실제 프로젝트에서는 내장된 Promise.all과 Promise.allSettled를 사용하시면 되지만, 이렇게 직접 구현해보는 과정을 통해 Promise의 동작 원리를 깊이 이해할 수 있었습니다.