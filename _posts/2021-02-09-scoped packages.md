---
layout: post
title: 'scoped packages - npm package 앞에 골뱅이란?'
date: 2021-02-09
categories: NPM
tags: [node.js, NPM]
description: 'NPM Doce | scope'
---

# Scoped packages

## Description

모든 npm package는 이름을 가지고있습니다. 그리고 약간의 패키지들은 scope를 가지고있습니다. <br>
이런 스코프를 가지고있는 패키지들은 이름을 정하는 룰이 있습니다. <br>
바로 `@` symbol과 slash를 사용하는 것이죠.

```bash
@somescope/somepackagename
```

이것을 **scoped packages** 라고 부르며 npm에 새로 추가된 기능입니다.<br>
npm 패키지에 **네임스페이스**를 적용하여 아래와 같은 규칙을 정합니다.
- global modules : 현재 존재하는 컨벤션 네임을 따른 모듈.
- scoped modules : 조직이나 그룹에 "scoped" 된 새로운 모듈.

## Installing scoped packages

일반적인 패키지들은 `node_modules/packagename` 형식으로 설치됩니다. scoped modules은 `node_modules/@myorg/packagename`의 경로로 설치됩니다.

`@` symbol, in `npm install` : 
```bash
npm install @myorg/mypackage
```
Or in `package.json` : 
```json
"dependencies": {
        "@myorg/mypackage" : "^1.3.0"
}
```

> [참고] <br>
> [https://docs.npmjs.com/cli/v6/using-npm/scope](https://docs.npmjs.com/cli/v6/using-npm/scope)