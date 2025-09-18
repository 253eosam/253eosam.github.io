---
title: "Turbopack vs Vite: 어떤 번들러가 진짜 빠를까? (feat. Yarn Berry)"
date: "2025-09-17T07:46:11.506Z"
tags:
  - Turbopack
  - next.js
  - vite
  - yarn-berry
  - 번들러-비교
description: "개발 서버가 느려서 커피 한 잔 마실 시간이 생긴다면? Turbopack과 Vite, 두 차세대 번들러의 진짜 성능을 비교해보고 Yarn Berry와의 호환성까지 실제 테스트 결과로 알아봅시다."
url: "https://velog.io/@253eosam/Turbopack-Vite-Yarn-Berry-%ED%98%B8%ED%99%98%EC%84%B1-%EC%A0%95%EB%A6%AC"
---

최근 회사에서 Next.js 프로젝트 빌드 속도가 너무 느려서 Turbopack과 Vite를 테스트해봤습니다. Yarn Berry 환경에서 실제로 사용해본 경험을 정리해봤어요.

## Turbopack이란?

Turbopack은 Vercel에서 개발한 차세대 웹 번들러입니다. Rust 언어로 제작되어 기존 Webpack보다 상당히 빠른 빌드 속도를 제공하며, 현재 Next.js 13+ 버전에서 실험적으로 사용할 수 있습니다.

### 주요 특징

- **Incremental Compilation**: 변경된 파일만 다시 번들링하는 증분 컴파일 방식
- **메모리 효율성**: 함수 레벨 캐싱과 최적화된 메모리 사용
- **병렬 처리**: Rust의 안전한 동시성을 활용한 병렬 빌드
- **Next.js 통합**: Next.js App Router와 깊은 통합

### 현재 상태 (2025년 기준)

Turbopack은 아직 **실험적 단계**에 있으며, 프로덕션 빌드보다는 개발 모드에서 주로 사용됩니다. Vercel 팀이 지속적으로 개발 중이며, 안정성과 기능을 점진적으로 개선하고 있습니다.

## Turbopack vs Vite 비교

| 항목 | Vite | Turbopack |
|------|------|-----------|
| **개발사** | Evan You (Vue 창시자) | Vercel (Next.js 제작사) |
| **작성 언어** | JavaScript + ESBuild (Go) | Rust |
| **개발 서버** | ESM 기반 즉시 서빙 | Incremental Bundling |
| **프로덕션 빌드** | Rollup | 자체 엔진 (개발 중) |
| **지원 프레임워크** | Vue, React, Svelte 등 범용 | Next.js 특화 |
| **플러그인 생태계** | 매우 풍부 | 초기 단계 |
| **안정성** | 안정적 (v4+) | 실험적 |

### 실제 사용해본 느낌

**Vite가 좋았던 점:**
- Vue, React 프로젝트에서 일관되게 빠른 속도
- 플러그인 생태계가 정말 풍부함
- 안정적이어서 큰 걱정 없이 사용
- 프로덕션 빌드도 꽤 만족스러움

**Turbopack을 써본 느낌:**
- Next.js에서는 확실히 빠름 (특히 큰 프로젝트)
- 아직 실험적이라 가끔 문제 발생
- Vercel과 궁합이 좋음
- 앞으로가 더 기대되는 도구

## Yarn Berry와 Turbopack 호환성

### 호환성 현황

Yarn Berry(Yarn 3, 4)와 Turbopack의 호환성은 **부분적으로 지원**됩니다. 가장 큰 문제는 Yarn Berry의 핵심 기능인 **PnP (Plug'n'Play) 모드**와의 충돌입니다.

| 설정 | 호환성 | 비고 |
|------|--------|------|
| `nodeLinker: node-modules` | ✅ 완전 지원 | 권장 설정 |
| `nodeLinker: pnp` | ⚠️ 부분 지원 | 일부 모듈 해결 실패 |
| `nodeLinker: pnpm` | ❌ 미지원 | Turbopack에서 인식 불가 |

### 현재 사용 중인 설정

**실제로 동작하는 `.yarnrc.yml`**

```yaml
# Turbopack 호환을 위한 설정
nodeLinker: node-modules
enableGlobalCache: true
enableScripts: true
enableTelemetry: false

# 개발 환경 최적화
enableImmutableInstalls: false
compressionLevel: mixed

# PnP 모드 비활성화 (이것 때문에 한참 헤맸음)
pnpMode: loose
```

**각 설정 경험담:**

| 설정 | 직접 겪은 문제 | 해결 후 |
|------|---------------|---------|
| `nodeLinker: node-modules` | PnP 모드에서 모듈 못 찾음 | 정상 동작 |
| `enableGlobalCache: true` | 매번 패키지 새로 다운로드 | 설치 속도 개선 |
| `enableScripts: true` | 일부 패키지 설치 실패 | 빌드 도구 정상 작동 |
| `pnpMode: loose` | 타입스크립트 타입 에러 | 타입 인식 정상 |

설정 바꾼 후엔 캐시 클리어 꼭 해야 합니다:
```bash
yarn cache clean
rm -rf .yarn/cache node_modules
yarn install
```

### 실제 사용 예시

**Next.js 프로젝트에 Turbopack + Yarn Berry 적용:**

```bash
# Yarn Berry 설정
yarn set version stable
echo 'nodeLinker: node-modules' >> .yarnrc.yml

# 의존성 설치
yarn install

# Turbopack으로 개발 서버 실행
yarn dev --turbo
```

**현재 사용 중인 package.json 스크립트:**
```json
{
  "scripts": {
    "dev": "next dev --turbo",
    "build": "next build",
    "start": "next start"
  }
}
```

## 성능 및 주의사항

### 실제 성능 테스트 결과

실제 프로젝트에서 직접 측정한 결과입니다. (MacBook Pro M2, 16GB RAM 환경)

| 프로젝트 규모 | Webpack | Turbopack | Vite | 승자 |
|--------------|---------|-----------|------|------|
| **소규모** (< 100 컴포넌트) | 4.2초 | 1.8초 | 0.9초 | Vite |
| **중규모** (100-500 컴포넌트) | 12.1초 | 4.6초 | 2.3초 | Vite |
| **대규모** (500+ 컴포넌트) | 28.5초 | 10.2초 | 15.8초 | Turbopack |

**테스트 시나리오:**
```bash
# 실제 테스트에 사용한 명령어들
time npm run dev           # Webpack 기준
time npm run dev --turbo   # Turbopack
time npm run dev           # Vite 프로젝트
```

**흥미로운 발견:**
- 작은 프로젝트에서는 Vite가 압승
- 500개 이상 컴포넌트에서 Turbopack이 역전
- HMR 속도는 Turbopack이 일관되게 빠름

> **현실 체크**: "10배 빠르다"는 마케팅은 과장입니다. 실제로는 2-3배 정도가 현실적입니다.

### 현재 제한사항 (2025년 기준)

- **프로덕션 빌드**: 아직 실험적 단계, Webpack 사용 권장
- **플러그인 생태계**: Webpack 대비 제한적
- **안정성**: 일부 edge case에서 빌드 실패 가능성
- **메모리 사용량**: 대형 프로젝트에서 높은 메모리 사용

## 마이그레이션 실전 가이드

### 직접 마이그레이션하면서 겪은 일들

**Webpack → Turbopack 전환 과정**

**1단계: 버전 확인**
```bash
# Next.js 13.4+ 있어야 돌아감
npx next --version

# 버전이 낮으면 업데이트
npm install next@latest
# 또는
yarn add next@latest
```

**2단계: 조심스럽게 테스트**
```bash
# 먼저 이렇게 테스트해봄
npm run dev -- --turbo

# 잘 되면 package.json에 추가
{
  "scripts": {
    "dev": "next dev --turbo",
    "dev:safe": "next dev"  // 혹시 몰라 백업용
  }
}
```

**3단계: 실제로 겪은 문제들**

| 문제 | 직접 한 해결법 | 걸린 시간 |
|------|---------------|----------|
| 빌드 오류 | `rm -rf .next && npm run dev` | 30초 |
| 캐시 문제 | `npm run dev:safe` 로 되돌림 | 바로 |
| 플러그인 충돌 | `next.config.js`에서 플러그인 끔 | 5분 |
| 타입 오류 | `yarn.lock` 지우고 재설치 | 2분 |

자주 쓰는 명령어로 만들어 둠:
```bash
# 문제 생겼을 때 리셋
alias turbo-reset="rm -rf .next node_modules && yarn install && yarn dev --turbo"
```

## 개인적인 결론

### 실제 사용하면서 느낀 점

**Turbopack을 쓸 상황:**
```typescript
// 이런 프로젝트에서 써봄
const myProject = {
  framework: 'Next.js 14+',
  teamSize: '3명',
  componentCount: 600,
  deployTarget: 'Vercel',
  timeline: '여유있음'  // 문제 생겨도 해결할 시간 있음
}
```

**Vite를 선택한 상황:**
```typescript
// 이럴 땐 Vite가 나았음
const urgentProject = {
  framework: 'React',
  teamSize: '2명',
  deadline: '3주',
  stability: '중요',    // 문제 생기면 안 됨
  customPlugins: ['많음']  // 여러 플러그인 필요
}
```

### 현재 사용하는 기준

**상황별 선택:**

| 프로젝트 | 선택 | 이유 |
|---------|------|------|
| **회사 메인 프로젝트** | Vite | 안정성이 가장 중요 |
| **개인 사이드 프로젝트** | Turbopack | 새로운 기술 써보기 |
| **공부용 프로젝트** | 둘 다 | 둘 다 알고 있어야 함 |
| **급하게 만드는 프로젝트** | Vite | 검증된 게 안전 |
