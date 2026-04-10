---
name: precise-technical-writing
description: Use when writing or reviewing technical notes that describe browser behavior, API behavior, spec-defined mechanisms, or any claim about how software systems work. Triggers on keywords like browser differences, spec behavior, activation, blocking policy, timing, timeout values.
---

# Precise Technical Writing

브라우저 동작, API 동작, 스펙 정의 메커니즘 등 기술적 사실을 서술할 때 적용하는 정확성 원칙.

## 핵심 원칙

**검증되지 않은 주장은 쓰지 않는다. 검증된 주장도 헷지한다.**

## Quick Reference

| 규칙 | Bad | Good |
|------|-----|------|
| 브라우저 동작은 절대적으로 서술하지 않는다 | "허용" / "차단" | "대체로 허용" / "차단될 수 있음" |
| 스펙이 정의하지 않은 구체적 수치를 단정하지 않는다 | "약 5초(4900ms)" | "최대 몇 초 정도 유지될 수 있다고만 설명" |
| 공식 용어를 사용한다 | "클릭 이벤트의 연장선" | "사용자 활성화(User Activation) 안에서" |
| 출처를 근거로 제시한다 | "click, keydown, touchstart 같은 이벤트" | "표준과 WebKit 설명 기준으로는 keydown, mousedown/pointerdown..." |
| 인과를 단정하지 않는다 | "Chrome에서는 허용하지만" | "Chrome 계열에서는 허용되는 경우가 더 많지만" |
| 설정과 런타임 동작을 구분한다 | "팝업 차단이 켜져 있어도 허용된다" | "팝업 허용 설정과 별개로 사용자 활성화 여부가 함께 영향을 준다" |

## 헷지(Hedge) 표현 가이드

브라우저/런타임 동작처럼 버전, 환경, 내부 구현에 따라 달라질 수 있는 사실을 서술할 때 사용한다.

**허용 표현**: "대체로", "비교적", "~하는 경향이 있다", "~하는 경우가 많다", "~될 수 있다", "~로 해석하는 경우가 있어"

**금지 표현**: 스펙에 명시되지 않은 동작을 "항상", "반드시", "무조건"으로 단정

## 출처 기준

참고 섹션에 포함할 출처의 우선순위:

1. **공식 스펙** — HTML Standard, W3C, TC39
2. **벤더 공식 블로그/문서** — WebKit Blog, Chrome for Developers, MDN
3. **벤더 공식 지원 문서** — Apple Support, Google Support
4. **구현체 소스/이슈** — Chromium source, WebKit Bugzilla, GitHub issues

비공식 블로그, Stack Overflow, Medium 글은 참고 섹션 출처로 사용하지 않는다.

## 비교 표 작성 규칙

브라우저 간 동작 비교 표를 작성할 때:

- 셀 값에 "허용"/"차단" 같은 이분법을 쓰지 않는다
- "대체로 허용", "허용될 수 있음", "차단될 수 있음"처럼 가능성을 표현한다
- 스펙에 정의된 동작만 단정형으로 쓸 수 있다

## 수치 인용 규칙

- 스펙이 정확한 값을 명시하면 그대로 인용하고 출처를 밝힌다
- 스펙이 모호하게 기술하면("a few seconds") 그 모호함을 그대로 전달한다
- 구현체의 실제 값은 "구현체 기준 약 N" 형태로 쓰되, 스펙 값처럼 단정하지 않는다

## Common Mistakes

| 실수 | 문제 | 수정 |
|------|------|------|
| 특정 버전에서 확인한 동작을 "Safari는 ~한다"로 일반화 | 다른 버전에서 다를 수 있음 | "~하는 경우가 있다", "~될 수 있다" |
| 블로그 글의 수치를 스펙 값처럼 인용 | 출처 불명확 | 스펙 원문을 확인하고, 스펙에 없으면 구현체 기준임을 명시 |
| 공식 용어 대신 통용 표현 사용 | 부정확한 전달 | 스펙/공식 문서의 용어를 우선 사용하고, 필요시 통용 표현을 병기 |
| 설정 변경과 런타임 정책을 혼동 | 독자 오해 유발 | "설정과 별개로 ~정책에 따라"처럼 두 레이어를 분리하여 서술 |
