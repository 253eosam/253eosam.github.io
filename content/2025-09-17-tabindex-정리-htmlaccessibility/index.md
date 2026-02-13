---
title: "TabIndex 정리 (HTML/Accessibility)"
date: "2025-09-17T07:46:04.895Z"
tags:
  - html
description: "tabindex는 HTML 요소의 키보드 포커스 순서를 지정하는 속성입니다. 웹 접근성을 향상시키는 데 중요한 역할을 합니다.기본적으로 대부분의 form 요소(&lt;input>, &lt;button>, &lt;a href> 등)는 자동으로 포커스를 받을 수 있음그 외"
url: "https://velog.io/@253eosam/TabIndex-%EC%A0%95%EB%A6%AC-HTMLAccessibility"
---

## 1\. tabindex란?

tabindex는 HTML 요소의 키보드 포커스 순서를 지정하는 속성입니다. 웹 접근성을 향상시키는 데 중요한 역할을 합니다.

## 2\. 기본 규칙

기본적으로 대부분의 form 요소(`<input>`, `<button>`, `<a href>` 등)는 자동으로 포커스를 받을 수 있음

그 외 요소들은 tabindex가 있어야 포커스 가능

## 3\. tabindex 값의 의미

값

설명

0

문서의 자연스러운 순서에 따라 포커스 가능하게 함

\-1

포커스를 받을 수 있지만, Tab 키로는 이동하지 않음 (스크립트로만 포커스 가능)

양의 정수

Tab 순서를 명시적으로 지정. 숫자가 낮을수록 먼저 포커스를 받음

## 4\. 사용 예시

```html
<!-- 자연스러운 순서 -->
<button>Button A</button>
<button tabindex="0">Button B</button>

<!-- 스크립트로만 포커스 가능 -->
<div tabindex="-1" id="modal">Modal</div>

<!-- 명시적 순서 지정 -->
<div tabindex="1">First</div>
<div tabindex="2">Second</div>
```

## 5\. 주의 사항

양의 정수는 권장되지 않음 (접근성 문제 및 유지보수 어려움)

tabindex="-1"은 모달/팝업 등의 포커스 트랩 구현 시 유용함

tabindex와 함께 aria-\* 속성을 활용하면 접근성이 향상됨

## 6\. 실무 팁

인터랙션 요소 외에는 되도록 tabindex를 사용하지 말 것

접근성 도구(예: Lighthouse, axe DevTools)를 통해 Tab 이동 흐름을 점검할 것

JavaScript로 포커스 이동 시 .focus() 메서드와 함께 tabindex="-1"을 적절히 활용