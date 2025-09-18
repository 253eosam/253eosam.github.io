---
title: "SWC로 TypeScript 빌드 속도를 70배 빨리 만든 방법"
date: "2025-09-17T07:46:44.506Z"
tags:
  - React
  - swc
  - typescript
  - vite
  - 빌드-최적화
description: "회사 프로젝트의 TypeScript 빌드가 너무 느려서 SWC를 도입해봤습니다. tsc와 함께 사용하는 방법과 실제 성능 개선 결과를 공유합니다."
url: "https://velog.io/@253eosam/SWC"
---

최근 회사에서 TypeScript 프로젝트 빌드 시간이 너무 오래 걸려서 개발 생산성이 떨어지는 문제가 있었습니다. SWC를 도입해서 실제로 얼마나 빨라지는지 테스트해봤어요.

## SWC란?

[SWC](https://swc.rs/)(Speedy Web Compiler)는 Rust로 작성된 빠른 웹 컴파일러입니다.

### 주요 특징

- **Rust 기반**: 메모리 안전성과 높은 성능 제공
- **TypeScript/JavaScript 변환**: TSC, Babel 대체 가능
- **병렬 처리**: 멀티코어 활용으로 대규모 프로젝트에서 효과적
- **플러그인 시스템**: 다양한 변환 작업 지원

### 성능 비교

공식 벤치마크에 따르면:
- 단일 스레드: Babel 대비 **20배** 빠름
- 멀티코어(4코어): Babel 대비 **70배** 빠름

다만 Babel의 모든 플러그인과 호환되지 않으므로 도입 전 확인이 필요합니다.

## SWC vs tsc 비교

실제 사용해보니 둘은 역할이 다르더군요.

| 구분 | tsc | SWC |
|------|-----|-----|
| **주요 기능** | 타입 검사 + 코드 변환 | 코드 변환만 |
| **속도** | 느림 | 매우 빠름 |
| **타입 검사** | ✅ 지원 | ❌ 미지원 |
| **언어** | TypeScript | Rust |
| **병렬 처리** | 제한적 | 멀티코어 활용 |

### 핵심 차이점

**tsc (TypeScript Compiler)**
- TypeScript 공식 컴파일러
- 타입 검사와 코드 변환을 모두 수행
- 완벽한 TypeScript 지원

**SWC (Speedy Web Compiler)**
- 빠른 코드 변환에 특화
- 타입 검사는 수행하지 않음
- Babel의 빠른 대안으로 설계

**결론**: SWC는 tsc를 완전히 대체할 수 없습니다. 타입 검사가 필요하다면 둘을 함께 사용해야 해요.

## tsc + SWC 함께 사용하기

직접 사용해본 최적의 조합 방법입니다.

### 설정 방법

**1. tsconfig.json 설정**
```json
{
  "compilerOptions": {
    "noEmit": true,  // tsc는 타입 검사만 수행
    "strict": true,
    "target": "ES2020",
    "module": "ESNext"
  }
}
```

**2. .swcrc 설정**
```json
{
  "jsc": {
    "parser": {
      "syntax": "typescript",
      "tsx": true
    },
    "target": "es2020"
  },
  "module": {
    "type": "es6"
  }
}
```

**3. package.json 스크립트**
```json
{
  "scripts": {
    "type-check": "tsc --noEmit",
    "build": "swc src -d dist",
    "dev": "swc src -d dist --watch"
  }
}
```

### 실제 사용 과정

```bash
# 1. 타입 검사 (개발 중 수시로)
npm run type-check

# 2. 빌드 (배포 전)
npm run build

# 3. 개발 모드 (파일 변경 감지)
npm run dev
```

이렇게 하면 tsc의 타입 안정성과 SWC의 빠른 속도를 동시에 얻을 수 있습니다.

## Vite + React에서 SWC 사용하기

현재 Vite 프로젝트에서 사용 중인 설정입니다.

### 설치

```bash
npm install @vitejs/plugin-react-swc
```

### vite.config.ts 설정

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react-swc';

export default defineConfig({
  plugins: [react()],
  build: {
    target: 'es2020'
  }
});
```

### 성능 개선 결과

실제 프로젝트에서 측정한 결과:

| 작업 | 기존 (@vitejs/plugin-react) | SWC 플러그인 | 개선률 |
|------|---------------------------|-------------|--------|
| **개발 서버 시작** | 3.2초 | 1.8초 | 44% 단축 |
| **HMR 속도** | 200ms | 80ms | 60% 단축 |
| **프로덕션 빌드** | 45초 | 28초 | 38% 단축 |

특히 큰 프로젝트일수록 성능 차이가 더 크게 나타납니다.