---
title: "lodash 꼭 써야 할까? 가벼운 대안 라이브러리 찾아보기"
date: "2025-09-17T07:46:31.356Z"
tags:
  - lodash
  - package
description: "외부 라이브러리 사용이 많은 lodash. 바로 쓰기 편하고 평가가 높은 라이브러리이지만, 모든 프로젝트에서 무조건 사용하는 것이 좋은 선택일지는 고민이 따릅니다.이 글에서는 lodash의 성능 문제 여부와, 대안으로 고려할 만한 가벼운 유틸리티 라이브러리들을 소개해 "
url: "https://velog.io/@253eosam/lodash-%EA%BC%AD-%EC%8D%A8%EC%95%BC-%ED%95%A0%EA%B9%8C-%EA%B0%80%EB%B2%BC%EC%9A%B4-%EB%8C%80%EC%95%88-%EB%9D%BC%EC%9D%B4%EB%B8%8C%EB%9F%AC%EB%A6%AC-%EC%B0%BE%EC%95%84%EB%B3%B4%EA%B8%B0"
---

외부 라이브러리 사용이 많은 **lodash**. 바로 쓰기 편하고 평가가 높은 라이브러리이지만, 모든 프로젝트에서 무조건 사용하는 것이 좋은 선택일지는 고민이 따릅니다.

이 글에서는 **lodash의 성능 문제 여부와, 대안으로 고려할 만한 가벼운 유틸리티 라이브러리들**을 소개해 드립니다.

* * *

## lodash, 성능에 무시해도 될 수준일까?

결론부터 말하면 **lodash 자체는 잘 최적화되어 있어 심각한 성능 문제는 없습니다.** 다만 **사용 방식에 따라 퍼포먼스 저하가 발생할 수 있습니다.**

### 주의해야 할 상황:

*   lodash 전체 import (`import _ from 'lodash'`) → **번들 크기 증가**
*   `_.cloneDeep`, `_.merge` 같은 깊은 복사 함수 반복 사용 → **대규모 데이터 처리에서 성능 저하**
*   체이닝을 과하게 사용해 불필요한 연산 증가
*   React, Vue에서 렌더링 단계에 무분별하게 사용 → **렌더링 성능 문제**

**필요한 함수만 개별 import**하고, 사용 위치와 빈도를 조절하면 대부분 문제는 발생하지 않습니다.

* * *

## lodash 대안 라이브러리 TOP 4

### 1️⃣ **Ramda**

*   함수형 프로그래밍(FP) 지향
*   **불변성 유지, 커링, 함수 조합**에 최적화
*   lodash보다 함수형 처리에 더 적합

```jsx
import { map } from 'ramda'
map(x => x * 2, [1, 2, 3]) // [2, 4, 6]
```

* * *

### 2️⃣ **Nano-lodash**

*   lodash 주요 기능을 **가볍게 재구현**
*   **번들 크기 2KB 내외로 매우 가볍고 빠름**

```jsx
import cloneDeep from 'nano-lodash/cloneDeep'
```

* * *

### 3️⃣ **Just**

*   특정 함수별로 **Zero dependency** 제공
*   필요한 함수 하나만 import 가능

```jsx
import debounce from 'just-debounce-it'
```

* * *

### 4️⃣ **lodash-es**

*   lodash의 ES module 버전
*   tree-shaking이 가능해 **개별 import로 번들 크기 최소화**

```jsx
import debounce from 'lodash-es/debounce'
```

* * *

### 네이티브 JS API + 유틸 함수 직접 작성

최근 브라우저 내장 기능이 강력해져서:

*   `map`, `filter`, `reduce`, `Object.assign`, `structuredClone`
*   `debounce`, `throttle` 등은 **10~20줄 내외로 간단히 직접 구현 가능**

* * *

## 상황별 추천 정리

상황

추천

불변성 + 함수형 가치 중심

**Ramda**

lodash 대체로 가벼운 크기 선호

**nano-lodash, Just**

lodash 문법에 익숙

**lodash-es**

의존성 최소화 + 성능 최대화

**네이티브 API + 직접 작성**