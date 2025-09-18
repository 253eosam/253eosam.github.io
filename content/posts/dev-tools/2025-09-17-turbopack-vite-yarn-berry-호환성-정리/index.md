---
title: "Turbopack, Vite, Yarn Berry 호환성 정리"
date: "2025-09-17T07:46:11.506Z"
tags:
  - Turbopack
  - next.js
  - vite
  - yarn-berry
description: "Turbopack은 Vercel에서 개발한 초고속 웹 번들러입니다. Rust 언어로 제작되어 Webpack 대비 최대 10배 이상 빠른 빌드 속도를 제공합니다. Turbopack은 Next.js를 기반으로 최적화되어 있으며, Cold Start, Hot Module R"
url: "https://velog.io/@253eosam/Turbopack-Vite-Yarn-Berry-%ED%98%B8%ED%99%98%EC%84%B1-%EC%A0%95%EB%A6%AC"
---

## Turbopack이란?

Turbopack은 Vercel에서 개발한 초고속 웹 번들러입니다. Rust 언어로 제작되어 Webpack 대비 최대 10배 이상 빠른 빌드 속도를 제공합니다. Turbopack은 Next.js를 기반으로 최적화되어 있으며, Cold Start, Hot Module Reloading(HMR) 모두 극한의 성능을 목표로 설계되었습니다.

특히, Incremental Bundling 방식을 채택하여 변경된 파일만을 다시 번들링하는 구조를 가지고 있어 대규모 프로젝트에서도 빠른 개발 경험을 제공합니다.

> "Webpack의 후계자"를 목표로, Next.js에 특화된 초고속 빌드 환경을 제공하는 번들러입니다.

## Turbopack vs Vite 비교

항목

Vite

Turbopack

주 개발사

Evan You (Vue 창시자)

Vercel (Next.js 제작사)

작성 언어

Node.js + ESBuild (Go)

Rust

개발 서버 방식

ESM 기반 실시간 서빙

그래프 기반 Incremental Bundling

프로덕션 빌드

Rollup 사용

자체 Turbopack 엔진 (개발 중)

최적 사용처

Vue, React, Svelte 등 범용

Next.js 기반 대규모 앱

플러그인 생태계

매우 풍부

아직 초기 단계

Vite는 다양한 프레임워크(Vue, React, Svelte 등)에서 빠른 개발 서버를 제공하는 범용 툴입니다. 개발 중에는 ESM 방식을 이용해 빌드 없이 빠른 피드백을 제공합니다. 프로덕션 빌드는 Rollup을 통해 번들링을 진행합니다.

반면, Turbopack은 Next.js 기반에 최적화된 환경을 제공하며, 개발 서버 및 프로덕션 빌드 모두를 Turbopack 엔진이 직접 처리합니다. 특히 대규모 프로젝트나 복잡한 앱에서 빌드 성능 차이가 크게 드러납니다.

## Yarn Berry와 Turbopack 호환성

Yarn Berry(Yarn 2, 3, 4)와 Turbopack은 기본적으로 호환됩니다. 그러나 주의해야 할 점은 Yarn Berry의 기본 설정인 PnP(Plug'n'Play) 모드입니다. 현재 Turbopack은 PnP를 완벽하게 지원하지 않기 때문에, 일부 모듈 리졸브 문제가 발생할 수 있습니다.

따라서 안정적인 개발 환경을 위해서는 PnP를 비활성화하고 전통적인 node\_modules 방식을 사용하는 것이 좋습니다.

### 추천 `.yarnrc.yml` 설정

```yaml
nodeLinker: node-modules
enableScripts: true
enableImmutableInstalls: false
```

*   `nodeLinker: node-modules` : PnP 대신 node\_modules 폴더를 생성하여 모듈을 관리합니다.
*   `enableScripts: true` : postinstall 등의 스크립트 실행을 허용합니다.
*   `enableImmutableInstalls: false` : 개발 중 의존성 업데이트를 가능하게 합니다.

이 설정을 적용하면 Yarn 2/3/4 버전에서도 Turbopack을 안정적으로 사용할 수 있습니다.

## 프로젝트 구조 예시

```null
.yarn/
  └ cache/
  └ releases/
    └ yarn-3.7.0.cjs
.yarnrc.yml
package.json
next.config.js
```

Next.js, Yarn Berry, Turbopack 조합으로 프로젝트를 구성할 경우 위와 같은 구조를 갖추는 것을 추천합니다.

## 최종 정리

질문

답변

Turbopack이란?

Webpack 대체를 목표로 한 초고속 번들러 (Rust 기반)입니다.

Vite와 차이점은?

Vite는 다양한 프레임워크를 위한 범용 ESM dev 서버이고, Turbopack은 Next.js에 특화된 초고속 빌더입니다.

Yarn Berry와 호환되나?

호환됩니다. 다만 `node_modules` 모드를 사용하는 것이 권장됩니다.