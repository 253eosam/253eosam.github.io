---
title: "Hydration, Layout Shift, Lazy Load, Chunk 등의 개념 정리"
date: "2025-09-17T07:46:21.480Z"
tags:
  - @loadable/component
  - CSR
  - Layout Shift
  - Lazy loading
  - SSR
  - Skeleton-UI
  - chunk
  - emotion
  - hydration
  - <Skeleton />
  - <Skeleton
  - <Suspense fallback={<Skeleton />}>
  - <Suspense
  - <CSSTransition in={show} timeout={300} classNames="fade" unmountOnExit>
  - <CSSTransition
  - <HeavyComponent />
  - <HeavyComponent
  - </CSSTransition>
  - </CSSTransition
  - </Suspense>
  - </Suspense
  - <div css={style}>
  - <div
  - </div>
  - </div
description: "이 문서는 React 기반 SSR/CSR 렌더링에서 자주 등장하는 개념들인 hydration, layout shift, skeleton UI, chunk, @loadable/component, 그리고 Emotion에 대해 자세히 설명합니다.

Hydration 시 La"
url: "https://velog.io/@253eosam/Hydration-Layout-Shift-Lazy-Load-Chunk-%EB%93%B1-%ED%95%B5%EC%8B%AC-%EA%B0%9C%EB%85%90-%EC%A0%95%EB%A6%AC"
---

> Nuxt 코드를 살펴보는도중 ClinentOnly를 이용하여 svg아이콘을 처리하는 코드를 봤습니다. 실제 화면에서도 켄텐츠가 모두 렌더링되고 아이콘이 뚝하고 나오는 모습을 봤고 당장 개선하고싶은 마음에 clientOnly라는 컴포넌트를 조사하게 되었습니다. 이 글은 'ClientOnly가 최선인지'에서 시작해서 의식의 흐름대로 찾아보고 정리한 글입니다. 가벼운 마음으로 읽어주시면 감사하겠습니다 😄

이 문서는 React 기반 SSR/CSR 렌더링에서 자주 등장하는 개념들인 `hydration`, `layout shift`, `skeleton UI`, `chunk`, `@loadable/component`, 그리고 `Emotion`에 대해 자세히 설명합니다.

* * *

## 1\. Hydration 시 Layout Shift란?

### 정의

*   SSR(Server-Side Rendering)된 HTML을 클라이언트에서 React가 다시 연결하는 과정이 **Hydration**
*   이때 **SSR에서 미리 렌더되지 않은 동적 컴포넌트**가 클라이언트에서 늦게 뜨면, 레이아웃이 순간적으로 **밀리거나 흔들리는 현상**이 발생
*   이걸 **layout shift (레이아웃 이동)** 라고 함

### 원인 예시

*   SSR에선 안 보이던 컴포넌트가 CSR에서 갑자기 렌더됨
*   이미지, 그래프, 리스트 등 높이가 유동적인 컴포넌트가 나중에 뜨는 경우

* * *

## 2\. Vue의 `<ClientOnly>` 컴포넌트

### 역할

*   Vue에서는 `<ClientOnly>`를 사용하면 **SSR 단계에서는 렌더하지 않고**, CSR 시점에만 컴포넌트를 렌더함
*   이로써 **hydration mismatch** 오류를 방지함

### 추가 고려 사항

*   컴포넌트가 차지할 공간이 없으면, CSR 시 렌더되면서 **레이아웃 밀림이 여전히 발생할 수 있음**
*   해결: `<ClientOnly>`의 fallback 슬롯에 **임시 공간 (height 확보)**을 넣어주면 레이아웃 안정 가능

* * *

## 3\. Skeleton UI의 효과

### 정의

*   컴포넌트가 로딩 중일 때 **실제 콘텐츠와 비슷한 모양의 회색 박스나 애니메이션 블럭**을 보여주는 UI
*   흔히 로딩 인디케이터보다 사용자 경험이 좋음

### 장점

*   성능에 큰 영향은 없음 (정적 요소)
*   하지만 UX 측면에서 **“빠르게 느껴짐”** 효과를 줌
*   **레이아웃 쉬프트를 줄이고**, CLS(Largest Contentful Paint) 같은 지표 향상에 도움

* * *

## 4\. React에서 Skeleton + Transition + Suspense 조합

```tsx
import loadable from '@loadable/component';
import { CSSTransition } from 'react-transition-group';
import './fade.css';

const HeavyComponent = loadable(() => import('./HeavyComponent'), {
  fallback: <Skeleton />
});

function App() {
  const [show, setShow] = useState(false);

  return (
    <Suspense fallback={<Skeleton />}>
      <CSSTransition in={show} timeout={300} classNames="fade" unmountOnExit>
        <HeavyComponent />
      </CSSTransition>
    </Suspense>
  );
}
```

### 구성 설명

*   `Suspense`: 비동기 컴포넌트 로딩 시 fallback 처리
*   `Skeleton`: loading 동안 자리 확보
*   `CSSTransition`: 콘텐츠가 부드럽게 fade-in 되는 효과

* * *

## 5\. Emotion 사용법 요약

### 설치

```bash
yarn add @emotion/react @emotion/styled
```

### 사용 예시

```tsx
import styled from '@emotion/styled';

const Button = styled.button`
  background: hotpink;
  padding: 8px 16px;
`;

const style = css`
  color: blue;
`;

<div css={style}>Emotion 스타일</div>
```

### 특징

*   `styled-components`와 문법 유사
*   `css` prop, `Global`, `keyframes` 같은 기능은 Emotion만의 장점

* * *

## 6\. `@loadable/component` 개념과 preload

### 문제

*   `React.lazy`는 **SSR에서 작동하지 않음**
*   서버에서 비동기 컴포넌트를 렌더하려면 **사전에 해당 청크를 preload** 해야 함

### 해결

*   `@loadable/component`는 SSR에서도 사용할 수 있도록 설계됨
*   서버는 `ChunkExtractor`를 통해 필요한 JS chunk를 미리 불러올 수 있음

### preload 동작 방식

1.  Webpack이 `loadable-stats.json` 생성
2.  서버는 요청된 컴포넌트에 필요한 chunk 목록을 추적
3.  렌더링 전에 preload → 클라이언트에 script tag로 포함

* * *

## 7\. JS Chunk vs min.js

항목

설명

**Chunk**

앱을 기능별로 나눈 JS 파일. 페이지/컴포넌트 단위로 분리됨

**.min.js**

JavaScript를 압축한 버전 (줄바꿈 제거, 변수 짧게)

즉,

*   `chunk`는 **파일 역할**
*   `.min.js`는 **파일 형태 (최적화)**

* * *

## 8\. 정크(Junk)와 청크(Chunk)의 차이

단어

뜻

개발에서 의미

**Junk**

쓰레기, 불필요한 것

정크 파일, 스팸 메일

**Chunk**

조각, 덩어리

JS 코드 블록, 메모리 청크 등

둘은 완전히 다른 의미.

* * *

## 결론

*   hydration 시 layout shift를 막으려면 공간 확보 전략과 lazy load 처리가 중요
*   SSR 환경에선 `@loadable/component`로 preload를 적극 활용
*   chunk는 기능 단위의 코드 조각, skeleton UI는 사용자 경험 개선에 핵심
*   Emotion은 `styled-components` 사용자에게 익숙하고 강력한 선택지