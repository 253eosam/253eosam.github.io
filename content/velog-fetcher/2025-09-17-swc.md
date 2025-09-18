---
title: "SWC"
date: "2025-09-17T07:46:44.506Z"
tags:
  - React
  - swc
  - typescript
  - vite
description: "SWC(Speedy Web Compiler) 는 매우 빠른 웹 컴파일러 입니다. Rust 언어로 개발되어 높은 성능을 제공합니다.JS, TS 코드를 트랜스파일하고 컴파일합니다.기존 Babel과 TSC 보다 성능이 좋으며 대체 가능합니다.컴파일과 번들링 모두를 처리할 수"
url: "https://velog.io/@253eosam/SWC"
---

![](https://velog.velcdn.com/images/253eosam/post/cb1df840-91c9-4e5a-b05f-770e5c0fc4e6/image.png)  
[SWC](https://swc.rs/)(Speedy Web Compiler) 는 매우 빠른 웹 컴파일러 입니다.

1.  Rust 언어로 개발되어 높은 성능을 제공합니다.
2.  JS, TS 코드를 트랜스파일하고 컴파일합니다.
3.  기존 Babel과 TSC 보다 성능이 좋으며 대체 가능합니다.
4.  컴파일과 번들링 모두를 처리할 수 있습니다.
5.  병렬 처리를 통해 기존 도구보다 훨씬 빠른 속도를 제공합니다.

> 💡 다만, Babel의 모든 플러그인과 호환되지 않으므로 적용 시 주의가 필요합니다. SWC는 현대적인 웹 개발에서 빌드 성능을 크게 향상시키는 도구로, 특히 대규모 프로젝트에서 유용합니다.

# SWC가 tsc를 완전히 대체 가능한가요?

tsc와 SWC는 비슷한 역할을 하지만 몇 가지 중요한 차이점이 있습니다.

1.  컴파일 속도 : swc는 rust로 작성되어 tsc보다 훨씬 빠른 성능을 제공합니다. (대략 70배 빠른 성능차)

> SWC is 20x faster than Babel on a single thread and 70x faster on four cores.  
> SWC는 단일 스레드에서는 Babel보다 20배 빠르고 4개 코어에서는 70배 빠릅니다.

1.  기능 범위 :
    *   TSC : ts → js 로 변환하고 타입 검사를 수행합니다. 완전한 ts 지원을 제공
    *   SWC : 주로 코드 변환에 초점을 맞추며, 타입 검사는 수행하지 않습니다.
2.  사용 목적
    *   tsc : ts 공식 컴파일러로, 타입 검사와 코드 변환을 모두 수행합니다.
    *   SWC : 주로 빠른 빌드 시간을 위해 사용되며, Babel의 대안으로 설계되었습니다.
3.  병렬 처리 : SWC는 Rust의 병렬 처리 기능을 활용하여 여러 파일을 동시에 변환활 수 있어 대규모 프로젝트에서 특히 유용합니다.

⇒ 결론적으로, tsc와 SWC는 TypeScript 코드를 JavaScript로 변환하는 역할을 하지만, SWC는 빠른 속도에 중점을 두고 있으며 타입 검사는 수행하지 않습니다. 프로젝트의 요구사항에 따라 적절한 도구를 선택해야 합니다

# 일반적으로 TSC + SWC 를 함께 사용하는 방식

1.  타입 검사 : tsc를 사용하여 타입 검사를 수행합니다. 이는 코드의 타입 안정성을 확보하는 데 중요합니다.
    
2.  코드 변환 : SWC를 사용하여 TS 코드를 JS 로 변환합니다.
    
3.  빌드 프로세스 설정 :
    
    *   `tsconfig.json` 파일에서 `"noemit" : true` 옵션을 설정하여 tsc가 JS 파일을 생성하지 않도록 합니다.
    *   SWC 설정을 위해 `.swcrc` 파일을 프로젝트 루트에 생성합니다.
4.  스크립트 설정 : `package.json` 에 다음과 같은 스크립를 추가합니다
    
    ```json
    {
      "scripts": {
        "type-check": "tsc --noEmit",
        "build": "swc src -d dist"
      }
    }
    ```
    
5.  개발 과정 :
    
    *   `npm run type-check` 로 타입 검사를 실행합니다.
    *   `npm run build` 로 SWC를 사용해 코드를 변환합니다.

이 방식을 통해 tsc의 강력한 타입 검사 기능과 swc의 빠른 컴파일 속도를 모두 활용할 수 있습니다.

# Vite React 에서의 tsc + swc 설정

vite에서 swc를 사용하기 위해 `@vitejs/plugin-react-swc` 플러그인을 설치해야 합니다. `package.json`에 다음과 같이 설정합니다.

```jsx
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react-swc';

export default defineConfig({
  plugins: [react()],
});
```

이 설정을 통해 SWC가 React 코드를 변환하도록 Vite에 지시합니다.