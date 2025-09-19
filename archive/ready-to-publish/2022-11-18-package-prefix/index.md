---
title: "React 프로젝트에서 @types, @babel 등 '@' 패키지 이름의 정체"
layout: post
category: npm
tags: [NPM, JavaScript, 개발환경, Package]
description: "React 개발하면서 매번 설치하는 @types/react, @babel/core 등의 패키지 이름에 붙은 '@' 기호가 궁금해서 찾아본 스코프 패키지의 정체와 실무에서 활용하는 방법을 정리했습니다."
---

React 프로젝트를 세팅하면서 항상 설치하는 패키지들을 보면 이름이 좀 특이합니다.

```bash
npm install @types/react
npm install @babel/core
npm install @storybook/react
```

계속 보던 `@` 기호가 붙은 패키지 이름이 궁금해서 찾아본 내용을 정리해봤습니다.

## 스코프 패키지(Scoped Packages)란?

`@` 기호가 붙은 패키지는 **스코프 패키지**라고 부르는 npm의 네임스페이스 기능입니다.

### 기본 구조
```bash
@조직명/패키지명
```

실제 예시들을 보면:
- `@types/react` - TypeScript 타입 정의용 패키지들
- `@babel/core` - Babel 관련 패키지들
- `@angular/core` - Angular 관련 패키지들
- `@storybook/react` - Storybook 관련 패키지들

## 왜 스코프 패키지를 사용하나?

### 1. 이름 충돌 방지

일반 패키지는 전역 네임스페이스를 사용해서 이름이 겹칠 수 있어요:

```bash
# 만약 'react'라는 이름의 패키지가 여러 개 있다면?
npm install react  # 어떤 react를 설치하는 걸까?
```

스코프 패키지는 조직별로 구분되어 이런 문제가 없습니다:

```bash
npm install @facebook/react
npm install @my-company/react  # 다른 조직의 react 패키지
```

### 2. 관련 패키지 그룹핑

같은 조직이나 프로젝트의 패키지들을 하나로 묶어서 관리할 수 있어요:

```bash
# TypeScript 타입 정의들
@types/react
@types/node
@types/lodash

# Babel 관련 패키지들
@babel/core
@babel/preset-env
@babel/preset-react
```

## 설치 및 사용 방법

### 설치
일반 패키지와 동일하게 설치합니다:

```bash
# 개발 의존성으로 설치
npm install -D @types/react

# 일반 의존성으로 설치
npm install @babel/core
```

### package.json에서 확인
설치된 스코프 패키지는 package.json에 이렇게 기록됩니다:

```json
{
  "dependencies": {
    "@babel/core": "^7.20.0",
    "react": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.0.0"
  }
}
```

### node_modules 구조
스코프 패키지는 node_modules 안에서도 별도 폴더로 구분됩니다:

```
node_modules/
├── react/                    # 일반 패키지
├── @types/                   # @types 스코프
│   ├── react/
│   └── node/
└── @babel/                   # @babel 스코프
    ├── core/
    └── preset-env/
```

## 실무에서 자주 만나는 스코프 패키지들

### @types - TypeScript 타입 정의
```bash
npm install -D @types/react @types/node @types/lodash
```

### @babel - JavaScript 트랜스파일러
```bash
npm install -D @babel/core @babel/preset-env @babel/preset-react
```

### @angular - Angular 프레임워크
```bash
npm install @angular/core @angular/common @angular/router
```

### @storybook - 컴포넌트 문서화 도구
```bash
npm install -D @storybook/react @storybook/addon-essentials
```

## 회사에서 스코프 패키지 만들기

실제로 우리 팀에서도 공통 컴포넌트를 스코프 패키지로 만들어 사용하고 있어요:

```bash
# 회사 공통 UI 컴포넌트
npm install @our-company/ui-components

# 공통 유틸리티 함수들
npm install @our-company/utils
```

### 스코프 패키지 발행하기

```bash
# 1. npm 조직 계정 생성 (npm 웹사이트에서)
# 2. 패키지 발행
npm publish --access public
```

private 스코프를 사용하려면 npm pro 계정이 필요합니다.

## 사용하면서 알게 된 팁들

### 1. 자동완성 활용
VS Code에서 `@`을 입력하면 설치된 스코프 패키지들이 자동완성으로 뜹니다.

### 2. 버전 관리
같은 조직의 패키지들은 보통 버전을 맞춰서 관리하는 경우가 많아요:

```json
{
  "dependencies": {
    "@babel/core": "^7.20.0",
    "@babel/preset-env": "^7.20.0",
    "@babel/preset-react": "^7.20.0"
  }
}
```

### 3. 검색할 때
npm 웹사이트에서 패키지를 검색할 때는 `@` 기호도 함께 검색하면 관련 스코프 패키지들을 한 번에 볼 수 있습니다.

React 개발하면서 항상 쓰던 패키지들의 이름 규칙을 이해하니 npm 생태계가 어떻게 구성되어 있는지 좀 더 명확해졌습니다.