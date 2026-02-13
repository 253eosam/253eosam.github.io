---
title: "브라우저 인쇄 시 배경 이미지가 출력되지 않는 문제 해결법"
date: "2025-09-17T07:46:08.124Z"
tags:
  - CSS
  - 프린트
description: "브라우저의 프린트 기능을 사용시 배경 그래픽이 빠지는 경우가 발생합니다. 이런경우 프린트의 옵션에 “배경 그래픽” 체크를 체크하여 진행하면 배경색이 채워진채 프린트됩니다. 하지만 매번 사용자에게 옵션 체크를 확인 시키고 요구하는 행위는 비효율적이므로 이것을 개발단에서 "
url: "https://velog.io/@253eosam/%EB%B8%8C%EB%9D%BC%EC%9A%B0%EC%A0%80-%EC%9D%B8%EC%87%84-%EC%8B%9C-%EB%B0%B0%EA%B2%BD-%EC%9D%B4%EB%AF%B8%EC%A7%80%EA%B0%80-%EC%B6%9C%EB%A0%A5%EB%90%98%EC%A7%80-%EC%95%8A%EB%8A%94-%EB%AC%B8%EC%A0%9C-%ED%95%B4%EA%B2%B0%EB%B2%95"
---

> 브라우저의 프린트 기능을 사용시 배경 그래픽이 빠지는 경우가 발생합니다. 이런경우 프린트의 옵션에 “배경 그래픽” 체크를 체크하여 진행하면 배경색이 채워진채 프린트됩니다. 하지만 매번 사용자에게 옵션 체크를 확인 시키고 요구하는 행위는 비효율적이므로 이것을 개발단에서 직접 해결하는 방법을 정리합니다.

웹 페이지를 프린트할 때, CSS로 지정한 `background-color`나 `background-image`가 출력되지 않는 경우가 많습니다. 이는 브라우저의 **프린트 설정에서 '배경 그래픽 인쇄'가 비활성화되어 있기 때문**입니다. 특히 배경을 시각적으로 강조하거나 레이아웃 요소로 활용하는 경우, 이 문제는 인쇄물의 품질을 크게 떨어뜨릴 수 있습니다.

이 글에서는 해당 문제의 원인과 해결 방법, 그리고 **Chrome, Edge, Firefox, Safari** 브라우저별 대응 전략을 정리합니다.

## 🔧 원인

대부분의 브라우저는 인쇄 시 **배경 그래픽(색상 및 이미지)**을 기본적으로 출력하지 않도록 설정되어 있습니다. 이는 잉크 절약 등의 이유 때문입니다.

CSS 속성 중 `background-color`와 `background-image`는 **사용자의 프린트 설정에 따라 출력 여부가 달라지며**, CSS로 완전히 강제할 수는 없습니다.

## ✅ 공통 대응 전략

### 1\. CSS 속성 활용

```scss
@media print {
  * {
    -webkit-print-color-adjust: exact; /* Chrome, Safari */
    print-color-adjust: exact;         /* Firefox 등 */
  }
}
```

이 속성은 브라우저에게 **정확히 색상을 출력해달라**고 요청합니다. 다만, **브라우저 및 버전에 따라 무시될 수 있습니다.**

### 2\. 배경 요소를 `<div>`나 `<img>`로 처리

```html
<div class="print-bg"></div>
```

```scss
@media print {
  .print-bg {
    position: fixed;
    top: 0; left: 0;
    width: 100vw;
    height: 100vh;
    background-image: url('/bg.png');
    background-size: cover;
    z-index: -1;
    -webkit-print-color-adjust: exact;
  }
}
```

배경 이미지를 실제 DOM 요소로 만들면 **브라우저가 이를 인쇄 콘텐츠로 인식**하기 때문에 배경 인사 가능성을 높일 수 있습니다.

## 브라우저별 대응 정리

브라우저

CSS 지원

사용자 설정 필요

설명

**Chrome**

`-webkit-print-color-adjust` 지원

☑️ 필요

`추가 설정 > 배경 그래핀` 체크

**Edge**

`-webkit-print-color-adjust` 지원

☑️ 필요

Chrome과 동일 (Chromium 기반)

**Firefox**

`print-color-adjust` 일부 지원

☑️ 필요

`설정 > 배경 색상과 이미지 인사` 체크

**Safari**

`-webkit-print-color-adjust` 지원

☑️ 필요

macOS 인사 설정에서 수동 체크