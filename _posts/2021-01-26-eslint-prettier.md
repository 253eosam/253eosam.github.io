---
layout: post
title: ESLint & Prettier
date: 2021-01-26
categories: JavaScript
tags: [JavaScript, ESLint, Prettier, Node.js, VS Code]
description: 'ESLint를 설명하고 적용하는 방법을 설명합니다. 추가적으로 Prettier를 적용합니다.'
---

> 1. ESLint와 Prettier를 사용하는 이유
> 2. ESLint 적용하기
> 3. Prettier 적용하기
> 4. ESLint + Prettier
> 5. Git hook을 이용한 자동화 방법

<br>

# ESLint와 Prettier를 사용하는 이유

ESLint와 Prettier는 보통 프로젝트 시작 단계(초기 셋팅)에서 코드 포맷팅과 코드 품질을 위해서 사용합니다.

-   코드 포맷팅 : 코드 컨벤션을 설정하기 위함.
-   코드 품질 : 잠재적인 오류나 버그를 찾는 역할

<br>

# ESLint 적용하기

## 목적

코드 검사 및 수정

## 적용 방법

1. node.js 설치가 필수, node package를 이용.

    ```javascript
    // .eslintrc.js
    module.export = {
    	rules: {
    		'no-unexpected-multiline': 'error',
    		'no-extra-semi': 'error',
    	},
    };

    // package.json > script : { "lint" :  "eslint src" }
    // src에 해당하는 모든 코드를 검사

    // npm run lint 명렁어 실행
    ```

2. `package.json` 파일 아래에 script 문에 `{ "lint" : "eslint src" }`를 작성합니다.
   이것으로 `npm run lint` 명령어를 실행하면 `src`에 해당하는 모든 코드를 검사합니다.

    `--fix` 옵션을 이용하여 잘못된 부분은 수정되도록 설정도 가능합니다.

-   [eslint.org/docs/rules](https://eslint.org/docs/rules/) 을 참고하면 스패너 모양은 `--fix` 옵션을 이용하여 수정 가능 하다는 것을 알려줍니다.
-   ✔️ 표시가 되어있는 경우 `"extends" : "eslint:recommended"` 를 적용했을 경우 적용되는 룰입니다.

    ```javascript
    // .eslintrc.js
    module.export = {
    	extends: ['eslint:recommended'],
    };
    ```

<br>

# Prettier 적용하기

## 목적

코드 포맷팅, 코드의 일관성을 유지할 수 있습니다.

## 적용 방법

```bash
$ npm install prettier      // 설치
$ npx prettier src/**/*     // 실행
$ npx prettier src/**/* --write     // 실행 후 적용
```

prettier는 eslint와 달리 규칙이 미리 셋팅되어있습니다. 따라서 추가 설정업시 바로 사용이 가능합니다.

<br>

# ESLint + Prettier

코드 포맷팅을 맞추더라도 코드 품질과 관련된 검사는 ESLint의 몫입니다.

ESLint는 prettier와 통합하는 방법을 제공해줍니다.

-   `eslint-config-prettier`와 `eslint-plugin-prettier`
-   prettier 포맷팅 규칙을 eslint에 추가합니다. 서로 충돌하는 옵션이 있다면 prettier의 규칙을 사용하도록 하는 도구입니다.

    ```bash
    $ npm install eslint-config-prettier eslint-plugin-prettier
    ```

    ```javascript
    // .eslintrc.js
    module.export = {
    	extends: ['eslint:recommended', 'plugin:prettier/recommended'],
    };
    ```

<br>

# Git hook을 이용한 자동화 방법

## Git hook이란?

`husky를 이용`, 커밋 시점에 어떤 일을 작동시킬 수 있습니다. 이것을 이용해서 커밋 시점에 ESLint를 체크할 수 있습니다.

## 설치 방법

1. 허스키를 설치합니다.

    ```bash
    $ npm install husky
    ```

2. 깃 훅 테스트 방법, 아래 페키지를 작성 후 `$ git commit --allow-empty -m "husky test"` 명령어 실행 => 콘솔창 확인

    ```json
    // package.json
    {
    	"husky": {
    		"hooks": {
    			"pre-commit": "echo '커밋전 출력'"
    		}
    	}
    }
    ```

3. 테스트 완료 후 아래로 수정

    ```json
    // package.json
    {
    	"husky": {
    		"hooks": {
    			"pre-commit": "npm run lint"
    		}
    	}
    }
    ```

## 최적화

위 방법은 모든 소스 코드를 검사하는 방법입니다. 만약 코드가 많아져서 모든 코드를 검사하면서 커밋이 느려질 수 있는데
이럴경우 `lint-staged`를 이용하여 **변경(스테이징)된 파일만 린트**를 수행할 수 있는 도구입니다.

```bash
$ npm install lint-staged
```

```json
// package.json
{
	"husky": {
		"hooks": {
			"pre-commit": "lint-staged"
		}
	},
	"lint-staged": {
		"*.{js,ts}": "npm run lint"
	}
}
```

## 에디터의 확장 프로그램을 이용한 방법.

커밋 시점이 아닌 개발 단계에서 ESLint & Prettier 적용이 가능합니다.

`VS Code`의 ESLint와 Prettier 확장 프로그램을 설치해서 사용합니다.

사용법은 아래를 참고해주세요.

```json
// settings.json
{
	"eslint.enable": true,  // eslint 활성화
	"editor.codeActionsOnSave": {   // 저장시 eslint 규칙에 맞게 수정
		"source.fixAll.eslint": true
	}
}
```
