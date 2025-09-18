---
title: "React에서 컴포넌트 언마운트 시 최신 상태를 API로 전송하는 방법"
date: "2025-09-17T07:45:55.001Z"
tags:
  - React
  - <input
      value={inputValue}
      onChange={(e) => setInputValue(e.target.value)}
    />
  - <input
description: "React를 사용하다 보면 컴포넌트가 언마운트(unmount) 될 때 특정 상태의 최신 값을 API로 전송해야 하는 상황이 종종 있습니다. 예를 들어, 입력 중인 내용을 저장하거나 페이지 이탈 직전에 데이터를 백엔드에 전송하는 경우입니다.하지만 단순히 useEffect"
url: "https://velog.io/@253eosam/React%EC%97%90%EC%84%9C-%EC%BB%B4%ED%8F%AC%EB%84%8C%ED%8A%B8-%EC%96%B8%EB%A7%88%EC%9A%B4%ED%8A%B8-%EC%8B%9C-%EC%B5%9C%EC%8B%A0-%EC%83%81%ED%83%9C%EB%A5%BC-API%EB%A1%9C-%EC%A0%84%EC%86%A1%ED%95%98%EB%8A%94-%EB%B0%A9%EB%B2%95"
---

React를 사용하다 보면 컴포넌트가 **언마운트(unmount)** 될 때 특정 상태의 **최신 값**을 API로 전송해야 하는 상황이 종종 있습니다. 예를 들어, 입력 중인 내용을 저장하거나 페이지 이탈 직전에 데이터를 백엔드에 전송하는 경우입니다.

하지만 단순히 `useEffect` 안에서 state 값을 참조하면 **stale(오래된)** 값이 전달될 수 있습니다. 이를 해결하기 위한 안전하고 효율적인 방법을 소개합니다.

* * *

## 🎯 목표

*   컴포넌트가 언마운트될 때 특정 상태의 최신 값을 API로 전송한다.

* * *

## 🔧 문제 상황

```tsx
useEffect(() => {
  return () => {
    fetch('/api/save', {
      method: 'POST',
      body: JSON.stringify({ value: inputValue }), // ❌ 오래된 값일 수 있음
    });
  };
}, []);
```

위 코드에서는 `inputValue`가 최신 값이 아닐 수 있습니다. 이는 `useEffect`의 클로저가 초기 값을 기억하기 때문입니다.

* * *

## ✅ 해결 방법: `useRef`를 활용한 최신 값 보존

React의 `useRef`를 사용하면 리렌더링 없이도 값을 유지할 수 있습니다. 이를 활용해 **항상 최신 상태를 참조할 수 있는 구조**를 만들 수 있습니다.

```tsx
import { useEffect, useRef, useState } from 'react';

function MyComponent() {
  const [inputValue, setInputValue] = useState('');
  const latestValueRef = useRef(inputValue);

  // 최신 값을 ref에 저장
  useEffect(() => {
    latestValueRef.current = inputValue;
  }, [inputValue]);

  // 언마운트 시 최신 값 전송
  useEffect(() => {
    return () => {
      const sendValue = latestValueRef.current;
      fetch('/api/save', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ value: sendValue }),
        keepalive: true, // 브라우저 페이지 이탈에도 전송 유지
      });
    };
  }, []);

  return (
    <input
      value={inputValue}
      onChange={(e) => setInputValue(e.target.value)}
    />
  );
}
```

## 💡 추가 팁

*   페이지 이탈 시 API 요청을 확실히 보내고 싶다면 `window.beforeunload` 이벤트나 `visibilitychange`를 활용할 수도 있습니다.
*   Next.js 또는 React Router를 사용하는 경우 라우터 훅(`useRouter`, `useBeforeUnload`)을 함께 조합하면 더 강력한 UX를 만들 수 있습니다.

* * *

## ✅ 정리

React 컴포넌트 언마운트 시점에 최신 상태를 API로 전송하려면:

1.  `useRef`를 사용해 최신 값을 따로 보관하고,
2.  `useEffect` cleanup 함수에서 해당 ref 값을 API로 전송합니다.

이 방식은 데이터 유실을 방지하고 안정적인 사용자 경험을 제공하는 데 큰 도움이 됩니다.