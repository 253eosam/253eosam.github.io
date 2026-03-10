---
title: "Zustand vs Jotai 비교 분석."
date: "2025-09-17T07:46:34.732Z"
tags:
  - Jotai
  - zustand
description: "\"어떤 상태 관리 라이브러리가 더 좋을까?\"React에서 상태 관리는 필수적입니다. 오늘은 대표적인 상태 관리 라이브러리인 Jotai와 Zustand를 비교하며 각각의 장단점을 살펴보겠습니다.Jotai는 atomic 패턴을 기반으로 상태를 독립적인 단위(atom)로 관"
external: "https://velog.io/@253eosam/Zustand-vs-Jotai-%EB%B9%84%EA%B5%90-%EB%B6%84%EC%84%9D"
---

> "어떤 상태 관리 라이브러리가 더 좋을까?"

React에서 상태 관리는 필수적입니다. 오늘은 대표적인 상태 관리 라이브러리인 **Jotai**와 **Zustand**를 비교하며 각각의 장단점을 살펴보겠습니다.

* * *

## 🔹 Jotai: Atomic 패턴을 활용한 상태 관리

Jotai는 **atomic 패턴**을 기반으로 상태를 독립적인 단위(atom)로 관리하는 라이브러리입니다.

### 📌 기본 사용법

```jsx
import { atom, useAtom } from 'jotai';

// 상태 정의
const countAtom = atom(0);

function Counter() {
  const [count, setCount] = useAtom(countAtom);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount((c) => c + 1)}>Increment</button>
    </div>
  );
}

function Display() {
  const [count] = useAtom(countAtom);
  return <p>현재 카운트: {count}</p>;
}

// App 컴포넌트
function App() {
  return (
    <>
      <Counter />
      <Display />
    </>
  );
}
```

### ✅ Jotai의 특징

*   **상태 분리**: 각 atom은 독립적으로 관리되며, 필요한 컴포넌트에서만 구독 가능함.
*   **의존성 관리**: atom 간 의존 관계를 설정하여 파생 상태를 쉽게 생성할 수 있음.
*   **React 친화적**: Suspense와 결합하여 비동기 데이터를 쉽게 처리할 수 있음.

* * *

## 🔹 Zustand: 중앙 집중형 상태 관리

Zustand는 **중앙 집중형 스토어**를 기반으로 모든 상태를 한 곳에서 관리하는 라이브러리입니다.

### 📌 기본 사용법

```jsx
import { create } from 'zustand';

// 스토어 생성
const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));

function Counter() {
  const increment = useStore((state) => state.increment);
  const count = useStore((state) => state.count);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>Increment</button>
    </div>
  );
}

function Display() {
  const count = useStore((state) => state.count);
  return <p>현재 카운트: {count}</p>;
}

// App 컴포넌트
function App() {
  return (
    <>
      <Counter />
      <Display />
    </>
  );
}
```

### ✅ Zustand의 특징

*   **중앙 집중형 관리**: 모든 상태가 하나의 스토어에 정의됨.
*   **부분 구독 가능**: 필요한 상태만 선택적으로 구독하여 불필요한 리렌더링 최소화.
*   **React 외부에서도 사용 가능**: React 바깥에서도 상태를 활용할 수 있어 확장성이 뛰어남.

* * *

## 🔥 Jotai vs Zustand: 어떤 경우에 사용할까?

**Jotai**

**Zustand**

**상태 관리 방식**

원자(atom) 단위 상태 관리

중앙 집중형 상태 관리

**리렌더링 최적화**

개별 atom을 구독하여 최소화

선택적 상태 구독 가능

**의존성 관리**

atom 간 의존성 설정 가능

별도의 의존성 설정 필요

**React 외부 사용**

불가능

가능

**Suspense 지원**

기본적으로 지원

별도 설정 필요

### 결론 ✨

*   **Jotai**는 **세밀한 상태 관리**가 필요하거나 **React에 최적화된 상태 관리**를 원할 때 적합합니다.
*   **Zustand**는 **전역 상태를 간편하게 관리**하거나 **React 바깥에서도 활용할 수 있는 상태 관리**가 필요할 때 유용합니다.

> 💡 결국, `setter`가 어디서 관리되는지가 핵심인것 같다.
> 
> 작은 상태를 여러 개 다뤄야 한다면 Jotai, 단순한 전역 상태를 효율적으로 관리하려면 Zustand가 더 적합해 보임.