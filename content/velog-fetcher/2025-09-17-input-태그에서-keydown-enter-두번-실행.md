---
title: "input 태그에서 keyDown 'Enter' 두번 실행"
date: "2025-09-17T07:46:51.734Z"
tags:
  - Event
  - React
  - enter
  - keydown
description: "한글 입력 시 React의 keydown 이벤트가 두 번 호출되는 문제는 주로 한글의 자음과 모음이 합성되는 과정에서 발생합니다. 이 현상은 입력 방식 편집기(IMD)의 특성으로 인해 발생하며, 이를 해결하기 위한 여러 방법이 있습니다.한글 입력 시, 사용자가 자음과 "
url: "https://velog.io/@253eosam/input-%ED%83%9C%EA%B7%B8%EC%97%90%EC%84%9C-keyDown-Enter-%EB%91%90%EB%B2%88-%EC%8B%A4%ED%96%89"
---

한글 입력 시 React의 **`keydown`** 이벤트가 두 번 호출되는 문제는 주로 한글의 자음과 모음이 합성되는 과정에서 발생합니다. 이 현상은 입력 방식 편집기(IMD)의 특성으로 인해 발생하며, 이를 해결하기 위한 여러 방법이 있습니다.

## 문제원인

한글 입력 시, 사용자가 자음과 모음을 입력하면 브라우저는 각 입력에 대해 **`keydown`** 이벤트를 발생시키고, 최종적으로 글자가 완성되면 **`onCompositionEnd`** 이벤트가 호출됩니다. 이 과정에서 **`keydown`** 이벤트가 중복 호출되어 원치 않는 동작을 유발할 수 있습니다

## 해결방법

### 1\. 커스텀 훅 사용

**`useKeyComposing`**이라는 커스텀 훅을 만들어 한글 입력 중에는 **`keydown`** 이벤트를 차단할 수 있습니다. 이 훅은 **`onCompositionStart`**와 **`onCompositionEnd`** 이벤트를 활용하여 현재 한글 입력 상태를 감지합니다.

```jsx
import { useState } from 'react';

const useKeyComposing = () => {
    const [isComposing, setIsComposing] = useState(false);

    const keyComposingEvents = {
        onCompositionStart: () => setIsComposing(true),
        onCompositionEnd: () => setIsComposing(false),
    };

    return { isComposing, keyComposingEvents };
};

export default useKeyComposing;
```

### 2\. 네이티브 이벤트 활용

이벤트 핸들러 내에서 `event.nativeEvent.isComposing`속성을 확인하여 한글 조합 중인지 여부를 판단할 수 있습니다. 조합 중일 경우 해당 이벤트를 무시하도록 조건을 추가합니다.

```jsx
function handleKeyDown(e) {
    if (e.nativeEvent.isComposing) return;
    // 나머지 처리 로직
}
```

### 3\. onKeyPress 사용

**`onKeyDown`** 대신 **`onKeyPress`** 이벤트를 사용하는 방법도 있으나, 이는 더 이상 권장되지 않습니다. **`onKeyPress`**는 문자가 실제로 입력될 때만 반응하기 때문에 중복 호출 문제를 피할 수 있지만, 이 이벤트는 앞으로 지원되지 않을 예정입니다