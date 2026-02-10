---
title: "레거시 ESLint 설정을 뜯어고치면서 배운 실무 설정법"
category: javascript
layout: post
tags: [JavaScript, ESLint, Vue.js, TypeScript, 개발환경]
description: "팀의 복잡한 ESLint 패키지 의존성 문제를 해결하면서 배운 실무 ESLint 설정 방법을 정리했습니다. Vue + TypeScript 멀티 프로젝트 환경에서의 실제 경험담입니다."
---

회사에서 담당한 프로젝트의 ESLint 설정이 완전히 망가져서 3주간 삽질한 경험을 공유하려고 합니다.

## 문제 상황: 관리 불가능한 ESLint 패키지

입사하자마자 맡게 된 Vue.js 프로젝트에서 이상한 현상이 발생했어요:

- 코드 저장할 때마다 ESLint 에러가 계속 바뀜
- 팀원마다 다른 린트 에러 발생
- 새로운 개발자는 개발 환경 세팅에 하루 종일 걸림

원인을 파악해보니 전임자가 만든 **커스텀 ESLint 패키지**가 문제였습니다:

```json
// package.json
{
  "devDependencies": {
    "@company/eslint-config": "^2.1.4", // 팀 전용 패키지
    "eslint": "^7.32.0"
  }
}
```

**이 패키지의 문제점들:**
1. 내부적으로 20개 이상의 ESLint 플러그인을 의존성으로 가짐
2. 자동 업데이트 로직이 있어서 원하지 않는 버전 업데이트 발생
3. 관리자가 퇴사해서 문서화가 전혀 안 됨
4. 각 프로젝트별 커스터마이징 불가능

### 실제로 겪었던 문제들

**개발 환경별 동작 차이:**
```bash
# 개발자 A (macOS)
npm install  # @company/eslint-config@2.1.4 설치

# 개발자 B (Windows)
npm install  # @company/eslint-config@2.2.1 설치 (자동 업데이트)
```

**CI/CD 파이프라인 실패:**
- 로컬에서는 통과하는 코드가 빌드 서버에서 ESLint 에러 발생
- 매번 패키지 버전 고정을 위한 shell script 실행 필요

**새 팀원 온보딩 지옥:**
- ESLint 설정 이해하는데 3일
- 개발 환경 맞추는데 1일
- 실제 개발 시작까지 평균 4-5일

## 해결 과정: 처음부터 다시 설정하기

결국 커스텀 패키지를 완전히 제거하고 처음부터 ESLint를 설정하기로 했습니다.

### 1단계: 기존 설정 분석

먼저 현재 프로젝트에서 실제로 필요한 ESLint 규칙들을 파악했어요:

```bash
# 현재 사용 중인 패키지 분석
npm ls --depth=0 | grep eslint

# 실제 ESLint 에러 발생 패턴 확인
npm run lint 2>&1 | grep -E "error|warning" | sort | uniq -c
```

**분석 결과:**
- Vue SFC 관련 규칙이 80% 차지
- TypeScript 관련 규칙이 15%
- 나머지 5%는 기본 JavaScript 규칙

### 2단계: 점진적 마이그레이션 전략

팀 개발을 중단할 수 없어서 점진적으로 적용했습니다:

**주차별 계획:**
- 1주차: 기본 ESLint + Vue 플러그인만 적용
- 2주차: TypeScript 지원 추가
- 3주차: 팀 스타일 가이드 적용 및 CI/CD 연동

### 3단계: 실제 구현 - 기본 ESLint 설정

**1. 깔끔하게 시작하기**

```bash
# 기존 ESLint 관련 패키지 모두 제거
npm uninstall @company/eslint-config
npm uninstall $(npm ls | grep eslint | cut -d' ' -f1 | xargs)

# 기본 ESLint 설치
npm install -D eslint@^8.0.0
```

**2. 초기 설정 파일 생성**

ESLint 공식 설정 도구를 사용했어요:

```bash
npx eslint --init

# 선택한 옵션들:
# ✔ How would you like to use ESLint? · problems
# ✔ What type of modules does your project use? · esm
# ✔ Which framework does your project use? · vue
# ✔ Does your project use TypeScript? · Yes
# ✔ Where does your code run? · browser
```

생성된 기본 `.eslintrc.js`:

```javascript
module.exports = {
  env: {
    browser: true,
    es2021: true
  },
  extends: [
    'eslint:recommended',
    '@vue/typescript/recommended'
  ],
  parserOptions: {
    ecmaVersion: 12,
    parser: '@typescript-eslint/parser',
    sourceType: 'module'
  },
  plugins: [
    'vue',
    '@typescript-eslint'
  ],
  rules: {
    // 우선 기본 설정 사용
  }
}
```

**3. 팀 규칙 추가**

실제 코드베이스를 분석해서 꼭 필요한 규칙들만 추가했어요:

```javascript
// 1주차: 기본 규칙만
rules: {
  'no-console': 'warn',
  'no-debugger': 'error',
  'no-unused-vars': 'off', // TypeScript가 처리
  '@typescript-eslint/no-unused-vars': 'error'
}
```

### 4단계: Vue + TypeScript 복합 환경 설정

실제 프로젝트는 `.vue`, `.ts`, `.js` 파일이 혼재되어 있었어요. 각 파일 타입별로 적절한 파서를 설정하는게 핵심이었습니다.

**최종 설정 파일 (`.eslintrc.js`):**

```javascript
module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
    es2021: true
  },
  extends: [
    'eslint:recommended'
  ],
  parserOptions: {
    ecmaVersion: 2021,
    sourceType: 'module'
  },
  rules: {
    'no-console': 'warn',
    'no-debugger': 'error'
  },
  overrides: [
    // TypeScript 파일
    {
      files: ['*.ts'],
      parser: '@typescript-eslint/parser',
      plugins: ['@typescript-eslint'],
      extends: ['@typescript-eslint/recommended'],
      rules: {
        '@typescript-eslint/no-unused-vars': 'error',
        '@typescript-eslint/explicit-function-return-type': 'off'
      }
    },
    // Vue SFC 파일
    {
      files: ['*.vue'],
      parser: 'vue-eslint-parser',
      plugins: ['vue'],
      extends: ['plugin:vue/vue3-recommended'],
      parserOptions: {
        parser: {
          ts: '@typescript-eslint/parser',
          js: 'espree'
        }
      },
      rules: {
        'vue/multi-word-component-names': 'off',
        'vue/no-v-html': 'warn'
      }
    }
  ]
}
```

**package.json 스크립트:**

```json
{
  "scripts": {
    "lint": "eslint . --ext .vue,.js,.ts",
    "lint:fix": "eslint . --ext .vue,.js,.ts --fix"
  }
}
```

### 5단계: 팀 규칙 정착 및 자동화

**VS Code 설정 (.vscode/settings.json):**

```json
{
  "eslint.validate": ["javascript", "typescript", "vue"],
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  }
}
```

**GitHub Actions CI 연동:**

```yaml
# .github/workflows/lint.yml
- name: Run ESLint
  run: |
    npm run lint
    if [ $? -ne 0 ]; then
      echo "::error::ESLint failed. Run 'npm run lint:fix' locally."
      exit 1
    fi
```

## 적용 결과 및 배운 점들

### 개선된 지표들

**개발자 온보딩 시간:**
- 이전: 평균 4-5일
- 현재: 1일 (환경 설정 30분 + ESLint 이해 2시간)

**CI/CD 파이프라인 안정성:**
- 이전: 주 2-3회 ESLint 관련 실패
- 현재: 월 1회 미만

**팀 생산성:**
- ESLint 관련 문제 해결 시간 80% 감소
- 코드 리뷰에서 스타일 관련 논의 90% 감소

### 실무에서 배운 ESLint 설정 팁들

**1. overrides 활용이 핵심**

복잡한 프로젝트에서는 파일별로 다른 설정이 필요해요:

```javascript
// 실제 운영 중인 설정
overrides: [
  // API 스크립트는 console 허용
  {
    files: ['scripts/**/*.js'],
    rules: {
      'no-console': 'off'
    }
  },
  // 테스트 파일은 더 유연하게
  {
    files: ['**/*.test.{js,ts,vue}'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'off'
    }
  }
]
```

**2. 점진적 적용의 중요성**

한 번에 모든 규칙을 적용하면 팀원들이 부담스러워해요. 월별로 새 규칙을 1-2개씩 추가하는 게 효과적이었습니다.

**3. 팀 합의가 가장 중요**

기술적으로 완벽한 설정보다 팀 전체가 납득하고 따를 수 있는 설정이 더 가치 있습니다.

### 추천하는 ESLint 설정 전략

| 프로젝트 규모 | 추천 방식 | 이유 |
|-------------|----------|------|
| **개인/소규모** | `eslint --init` 기본 설정 | 빠른 시작, 오버엔지니어링 방지 |
| **팀 프로젝트** | 기본 + 팀 규칙 점진적 추가 | 팀 합의 기반 안정적 도입 |
| **대규모/멀티 프로젝트** | Shared config 패키지 | 일관성 유지, 중앙 관리 |

이 경험을 통해 "완벽한 설정"보다는 "팀이 지속 가능한 설정"이 더 중요하다는 걸 깨달았습니다.

