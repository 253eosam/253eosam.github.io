---
title: "Nuxt.js 의 API Request 간단 정리"
date: "2025-09-17T07:46:01.572Z"
tags:
  - nuxt
  - <script setup lang="ts">
  - <script
  - </script>
  - </script
description: "Nuxt3 \\$fetch, useAsyncData, useFetch 차이 정리용도: 클라이언트 사이드 HTTP 요청 처리특징: ofetch 기반, Node.js 및 브라우저 환경 자동 감지주의사항: SSR 시 사용 시 중복 호출 위험, 초기 데이터 패칭에 부적합사용 "
url: "https://velog.io/@253eosam/Nuxt.js-%EC%9D%98-API-Request-%EA%B0%84%EB%8B%A8-%EC%A0%95%EB%A6%AC"
---

> Nuxt3 $fetch, useAsyncData, useFetch 차이 정리

### 1\. $fetch

*   **용도**: 클라이언트 사이드 HTTP 요청 처리
*   **특징**: ofetch 기반, Node.js 및 브라우저 환경 자동 감지
*   **주의사항**: SSR 시 사용 시 중복 호출 위험, 초기 데이터 패칭에 부적합
*   **사용 예시**: 버튼 클릭 시 데이터 호출 등 사용자 인터랙션 기반 요청 처리

```vue
<script setup lang="ts">
const data = ref();
const testFetch = async () => {
    const result = await $fetch<number>("/api/temp");
    data.value = result;
};
</script>
```

### 2\. useAsyncData

*   **용도**: 서버 및 클라이언트 모두에서 초기 데이터 패칭 지원
*   **특징**: Top-level await 지원, key 기반 캐싱, 리액티브 데이터 반환
*   **장점**: 외부 변수 변화를 콜백 함수로 반영 가능 (동적 파라미터 반영)
*   **주의사항**: SSR 시 쿠키, 로컬스토리지 접근 불가 (useState나 Pinia 사용 필요)

```vue
<script setup lang="ts">
const { data, refresh } = await useAsyncData<number>("useAsyncDataTest", () => $fetch("/api/temp"));
</script>
```

### 3\. useFetch

*   **용도**: useAsyncData를 간단하게 래핑한 버전
*   **특징**: 초기 값 freezing 발생, 실행 시점 이후 값 변경 반영 불가
*   **자동 반응성**: 리액티브 객체를 넘기면 자동으로 값 변동 감지 및 재호출
*   **주의사항**: 복잡한 동적 값 처리에는 부적합

```vue
<script setup lang="ts">
const { data, refresh } = await useFetch<number>("/api/temp", { key: "useFetchTest" });
</script>
```

### 4\. 정리

*   $fetch는 유저 인터랙션 시 사용 (POST, PUT 등).
*   useAsyncData는 초기 페이지 데이터 로딩에 추천.
*   useFetch는 간단하지만 자동 갱신이 필요 없는 경우 적합.
*   SSR 환경에서는 쿠키, 로컬스토리지 접근 불가 주의 필요.

항목

$fetch

useAsyncData

useFetch

**SSR 지원**

클라이언트 전용

서버/클라이언트 모두 가능

서버/클라이언트 모두 가능

**초기 데이터 패칭**

부적합

적합 (Top-level await 지원)

적합하지만 freezing 문제 있음

**중복 호출 방지**

없음

key 기반 캐싱

key 기반 캐싱

**자동 반응성**

없음

직접 콜백 호출 필요

반응성 객체 변화 감지 후 자동 호출

**적합한 상황**

사용자 인터랙션 기반 요청 (POST 등)

페이지 초기 렌더링 데이터 패칭

간단한 초기 데이터 패칭 (동적 값 변동이 없는 경우)

### 생각해볼 거리

**1\. Nuxt3에서 Axios 대신 ofetch를 선택한 이유는 무엇인가?**

*   Axios는 XMLHttpRequest 기반으로 최신 웹 표준에 부합하지 않으며, Worker 환경에서 부적합하기 때문.

**2\. 왜 useFetch는 동적 데이터 변화를 반영하지 못하는가?**

*   초기 객체를 freezing 하기 때문에 값이 변해도 내부적으로 갱신되지 않음.

**3\. Server Side Rendering(SSR)에서 데이터 패칭 시 주의할 점은?**

*   SSR에서는 브라우저 전용 API(localStorage, cookie) 사용 불가.
*   대신 useState나 pinia로 상태 관리를 해야 함.