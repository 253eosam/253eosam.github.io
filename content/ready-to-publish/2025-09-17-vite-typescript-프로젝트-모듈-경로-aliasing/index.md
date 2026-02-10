---
title: "Vite + TypeScript에서 import 경로를 깔끔하게 만드는 방법"
date: "2025-09-17T07:46:54.843Z"
tags:
  - alias
  - typescript
  - vite
  - 모듈-경로
description: "상대 경로로 인한 import 지옥에서 벗어나기 위해 Vite와 TypeScript에서 절대 경로 설정을 해봤습니다. 실제 적용 과정과 주의사항을 공유합니다."
url: "https://velog.io/@253eosam/Vite-TypeScript-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EB%AA%A8%EB%93%88-%EA%B2%BD%EB%A1%9C-aliasing"
---

회사 프로젝트에서 Vue 3 + Vite + TypeScript 스택으로 어드민 시스템을 개발하면서 import 경로 때문에 고생했던 경험을 공유하려고 합니다.

개발 3개월 차쯤 되었을 때 폴더 깊이가 5단계까지 내려가면서 import 문이 완전히 망가졌었어요.

## 실제로 겪었던 문제들

**실제 프로젝트에서 마주친 상대 경로들:**
```typescript
// views/admin/user/detail/components/UserProfile.vue 에서
import BaseModal from "../../../../../components/common/BaseModal.vue"
import { useUserStore } from "../../../../stores/modules/user"
import { formatDate } from "../../../../../utils/date"
import { validateEmail } from "../../../../../utils/validation"
```

이걸 보면서 '이게 맞나?' 싶었습니다. 더 심각한 건 폴더 구조를 바꿀 때마다 import 경로를 일일이 찾아서 수정해야 했다는 점이었어요.

**alias 설정 후:**
```typescript
import BaseModal from "@/components/common/BaseModal.vue"
import { useUserStore } from "@/stores/modules/user"
import { formatDate, validateEmail } from "@/utils"
```

코드 리뷰할 때도 어떤 파일을 가져오는지 바로 알 수 있고, 폴더를 옮겨도 import 경로가 안 깨져서 리팩토링이 훨씬 수월해졌습니다.

## 해결 과정

처음에는 단순히 `@` 하나만 설정했는데, 팀원들이 여전히 상대 경로를 쓰는 경우가 많았어요. 그래서 자주 사용하는 폴더별로 세분화해서 alias를 만들었습니다.

### 1. Vite 설정 (vite.config.ts)

```typescript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@stores': path.resolve(__dirname, './src/stores'),
      '@assets': path.resolve(__dirname, './src/assets'),
      '@api': path.resolve(__dirname, './src/api'),
      '@types': path.resolve(__dirname, './src/types')
    }
  }
})
```

### 2. TypeScript 설정 (tsconfig.json)

Vite에서만 설정하면 TypeScript 에러가 계속 나타나더라고요. 두 곳 모두 설정해야 정상 동작합니다.

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"],
      "@utils/*": ["src/utils/*"],
      "@stores/*": ["src/stores/*"],
      "@assets/*": ["src/assets/*"],
      "@api/*": ["src/api/*"],
      "@types/*": ["src/types/*"]
    }
  }
}
```

### 3. 프로젝트 구조와 실제 사용 사례

현재 프로젝트 구조는 이렇게 되어 있어요:

```
src/
├── components/
│   ├── common/          # 공통 컴포넌트
│   ├── layout/          # 레이아웃 컴포넌트
│   └── feature/         # 기능별 컴포넌트
├── stores/
│   └── modules/         # Pinia 스토어들
├── utils/
│   ├── date.ts
│   ├── validation.ts
│   └── format.ts
├── api/
├── types/
├── assets/
└── views/
    └── admin/
        └── user/
            └── detail/
                └── components/
```

**실제 컴포넌트에서의 사용:**
```typescript
// UserProfile.vue - 5단계 깊은 컴포넌트에서
import BaseModal from '@components/common/BaseModal.vue'
import { useUserStore } from '@stores/modules/user'
import { formatDate } from '@utils/date'
import { UserDetail } from '@types/user'
import { getUserDetail } from '@api/user'
```

이렇게 하니까 어떤 깊이에 있는 컴포넌트든 항상 같은 방식으로 import할 수 있게 되었어요.

## 설정 과정에서 겪은 문제들

### VSCode 자동완성이 안 되는 문제

처음에는 alias를 설정해도 VSCode에서 자동완성이 제대로 안 됐어요. 이걸 해결하려면 VSCode 설정도 따로 해줘야 합니다.

**`.vscode/settings.json`**
```json
{
  "typescript.preferences.includePackageJsonAutoImports": "auto",
  "typescript.suggest.autoImports": true,
  "typescript.preferences.importModuleSpecifier": "non-relative"
}
```

### Node.js 타입 에러

`path.resolve(__dirname, ...)` 부분에서 TypeScript 에러가 계속 나더라고요. 이건 Node.js 타입을 설치하면 해결됩니다.

```bash
npm install -D @types/node
```

### ESM 환경에서 __dirname 문제

최신 Vite 프로젝트에서는 `__dirname`을 사용할 수 없는 경우가 있어요. 이때는 이렇게 해결했습니다:

```typescript
import { fileURLToPath, URL } from 'node:url'

export default defineConfig({
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  }
})
```

### Vitest에서 alias 인식 안 되는 문제

테스트 환경에서는 별도 설정이 필요했어요. `vitest.config.ts`를 따로 만들어서 alias를 다시 정의해줘야 합니다.

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import path from 'path'

export default defineConfig({
  test: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@utils': path.resolve(__dirname, './src/utils')
    }
  }
})
```

### 팀원들의 기존 습관 문제

기술적인 문제보다 더 어려웠던 건 팀원들이 기존 상대 경로 방식에 익숙해져 있다는 점이었어요. 몇 가지 규칙을 정해서 점진적으로 적용했습니다:

- 새로 작성하는 컴포넌트는 무조건 alias 사용
- 기존 파일 수정할 때 import 경로도 함께 정리
- Code Review에서 상대 경로 발견하면 바로 지적

## 적용 후 달라진 점들

### 개발 효율성 변화

**리팩토링할 때:**

- 이전: 폴더 구조 바꿀 때마다 import 경로 깨져서 하나씩 수정
- 현재: 폴더를 어디로 옮겨도 import 경로는 그대로 유지

**코드 리뷰할 때:**

- 이전: `../../../components/Button.vue` 보고 어떤 Button인지 추측해야 함
- 현재: `@components/common/Button.vue` 보고 바로 파악 가능

**자동완성 품질:**

- VSCode에서 `@`만 입력하면 전체 프로젝트 구조가 나와서 원하는 파일 찾기 쉬움
- 특히 깊은 폴더 구조에서 상대 경로로 찾아가는 스트레스가 완전히 사라짐

### 실제 측정한 개발 시간

프로젝트 초기(alias 적용 전)와 중반(alias 적용 후)의 개발 시간을 대략적으로 비교해봤어요:

| 작업 | 적용 전 | 적용 후 | 차이 |
|------|---------|---------|------|
| 새 컴포넌트 작성 시 필요한 import 추가 | 3-5분 | 1-2분 | 60% 단축 |
| 폴더 구조 리팩토링 | 30-60분 | 10-20분 | 70% 단축 |
| 코드 리뷰에서 import 추적 | 2-3분 | 즉시 | 90% 단축 |

### 팀 전체에 미친 영향

**신규 팀원 온보딩:**
6개월차 신규 개발자가 "프로젝트 구조를 파악하기 쉬워서 빨리 적응할 수 있었다"고 피드백 줬습니다.

**코드 품질:**
PR에서 import 관련 토론이 줄어들고, 실제 로직에 더 집중할 수 있게 되었어요.

지금 돌이켜보면 alias 설정은 단순한 편의성 개선이 아니라 팀 전체의 개발 경험을 바꾼 중요한 결정이었던 것 같습니다.
