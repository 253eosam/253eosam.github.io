---
layout: post
title: 'ESLint 디테일하게 탐구하기'
categories: Develop
tags: [JavaScript, ESLint]
---

## 알수있는 내용

> ESLint 설정과 옵션을 건드리면서 알게된 사실을 기록합니다.

- 프로젝트에 ESLint를 설정하는 방법
- eslintrc 파일의 설정문서를 이해하며 사용

### 글 쓰게된 이유..

회사 내에서 담당하던 프로젝트에 Lint 설정이 아주 독특하게 되어있었다. 팀에서 사용하는 모든 린트 플러그인들을 모아서 packing하여 따로 패키지로 빼서 사용중이였다. (이렇게 사용하는 의도는 팀에서 새로운 프로젝트를 진행할때 빠르게 린트 설정을 할 수 있고, 모든 프로젝트의 린트 옵션의 설정을 동기화 할 수 있는 장점이 있었지만...;;) 이 패키지를 관리하시던 분이 회사에서 나가게 되면서 관리가 소홀하게 된것이다. 그리고 패킹해둔 패키지의 특정 버전을 사용해야하는 프로젝트의 입장이였는데 내부 코드에 최신버전을 유지하는 코드가 있어서 업데이트를 하기 싫어도 할 수 없이 해야하는 상황이 지속적으로 발생하고 이는 업무의 효율을 떨어뜨리고, 새로운 개발자가 프로젝트를 사용하는데 어려움을 유발시켜 이 문제를 해결하기로 하였다.

처음에는 ESLint 설정에 대한 디테일하게 만지고싶지않아 shell script를 이용해서 특정 버전을 계속 유지하도록 하였지만 이는 편법이였기에 그리 좋은 방법은 아니였다. 😅

불편한 상황이 지속되자 결국 이 부분을 뜯어고치기로 했다.

## 프로젝트에 [ESLint](https://eslint.org/)를 설정해보자

### ESLint vs Prettier

먼저 ESLint란? ES와 Lint를 합친말로 Ecma Script Lint입니다. [\[참고\]](https://253eosam.github.io/develop/2021/01/26/eslint-prettier/)  
린트를 설정하는 이유는 코드의 품질을 올리기 위해서인데 잠재적으로 발생할 수 있는 버그나 오류를 찾는 역할을 합니다. 이와 헷갈리는 부분이 prettier 입니다. prettier는 코드 포맷팅 설정으로 코드의 컨벤션 지정하는 역할을 합니다. 그러므로 둘의 사용 목적은 다르다고 할 수 있습니다.

- 코드 품질 : 잠재적인 오류나 버그를 찾는 역할
- 코드 포맷팅 : 코드 컨벤션을 설정하기 위함.

### 설치

먼저 eslint를 프로젝트에서 사용하기 위해서는 eslint 패키지를 설치해야합니다.  
eslint가 설치되어 있어야 _node_modules_ 폴더에서 가져와 사용할 수 있기때문입니다.

```bash
npm i -D eslint
```

eslint의 경우 개발 환경에서만 사용하는 라이브러리입니다. 따라서 devDependency에 설치해줍니다.

### 테스트

설치가 끝나면 이제 eslint가 정상적으로 작동하는데 이를 확인해보기위해서 간단한 테스트를 해보겠습니다.
확인을 위해 간단하게 ESLint 룰을 설정해 보겠습니다. `.eslintrc.json` 파일을 만들어줍니다. 이때 꼭 json 파일이 아니여도 됩니다.

아래 파일 형식을 지원하며 오름차순으로 우선순위를 가집니다.

1. `.eslintrc.js`
2. `.eslintrc.cjs`
3. `.eslintrc.yaml`
4. `.eslintrc.yml`
5. `.eslintrc.json`
6. `package.json`

파일을 생성했다면 아래의 형식으로 코드를 작성해줍니다. (옵션에 대한 자세한 설명은 아래에서 하겠습니다.)

```json
// .eslintrc.json
{
  "env": {
    "browser": true,
    "es2021": true
  },
  "extends": "eslint:recommended",
  "parserOptions": {
    "ecmaVersion": 12,
    "sourceType": "module"
  },
  "rules": {
    "semi": "error"
  }
}
```

이제 eslint가 실행될때 참고할 수 있는 파일이 생겼습니다. 이 설정 파일을 통해 eslint를 제어할 수 있습니다.  
간단한 코드를 작성했습니다. 이 코드는 세미콜론이 없는 자바스크립트 코드입니다.

```js
// sum.js <- root path
let a = 1
let b = 2

const sum = (a, b) => a + b

console.log(sum(a, b))
```

위해서 _semi: error_ 룰을 통해 세미콜론이 없을때 에러를 발생하도록 하였습니다. *node_modules/eslint/bin/eslint.js sum.js*을 command line에 실행합니다.

> eslint는 `node_modules/eslint` 경로에 설치되어 있습니다. eslint를 글로벌로 설치하셨다면 command line에서 _eslint {path}_ 를 사용하시면되고 그렇지 않다면 *node_modules/eslint/bin/eslint.js {path}*를 입력하시면됩니다.

아래와 같이 동작한다면 eslint가 정상 작동하는 걸 확인할 수 있습니다.

```bash
➜  myWorkspace node_modules/eslint/bin/eslint.js sum.js

/Users/we/Documents/myRepo/myWorkspace/sum.js
  1:10  error  Missing semicolon  semi
  2:10  error  Missing semicolon  semi
  4:25  error  Missing semicolon  semi
  8:2   error  Missing semicolon  semi

✖ 4 problems (4 errors, 0 warnings)
  4 errors and 0 warnings potentially fixable with the `--fix` option.
```

_--fix_ 옵션을 추가하면 코드를 직접 수정해줍니다.

### 프로젝트에 맞게 설정

이제 프로젝트에 맞게 설정하는것을 해보도록하겠습니다.

_Vue.js를 예시로 설명하겠습니다._

eslint는 각 프레임워크에 맞는 plugin을 제공해줍니다. _eslint-plugin-<plugin-name>_ 방식으로 제공하고있는데, 이 플러그인은 해당 환경에서 eslint 편하게 사용할 수 있도록 도와주는 역할을 합니다.

예를들어, 저는 Vue.js 프레임워크를 이용해여 개발하고 있으니 *eslint-plugin-vue*를 설치하면 이제 해당 플러그인에서 제공하는 몇가지의 룰을 사용할 수 있습니다. 그리고 *parser*를 잠시 후에 설명할껀데 *eslint-plugin-vue*는 *vue-eslint-parser*를 필수로 사용하기때문에 파서를 따로 넣어주지 않아도됩니다. 이제 _.vue_ (싱글 파일 컴포넌트)에서 eslint가 정상적으로 동작하는것을 확인할 수 있습니다.

```bash
npm i -D eslint-plugin-vue
```

설치 후 plugin을 _.eslintrc.json_ 에 설정해줘야합니다. 설치만했다고해서 적용되지 않습니다. 먼저 _plugin 옵션에 설치한 플러그인을 넣어줘야합니다. 그리고 반드시 extends에 어떤 옵션을 사용할지 명시해줘야 합니다._

_eslintrc 파일의 경우 약간의 문법 오류가 있으면 정상적으로 동작하기 않기 때문에 (,)까지 신경써서 작성하여야합니다._

```json
// .eslintrc.json
{
  "env": {
    "browser": true,
    "es6": true
  },
  "plugins": ["vue"],
  "extends": ["eslint:recommended", "plugin:vue/base"],
  "parserOptions": {
    "sourceType": "module"
  },
  "rules": {
    "semi": "error"
  }
}
```

`plugin:vue/base`를 설명하자면 *plugin:*은 `eslint-plugin-`의 약자입니다. *vue/base*는 플러그인에서 제공하는 룰인데 [eslint-plugin-vue](https://eslint.vuejs.org/rules/) doc을 참고하면서 자신한테 맞는 것을 선택하면됩니다.

### TypeScript 추가하기

프로젝트에 타입스크립트를 사용하는 경우 타입 스크립트 플러그인을 설치해야합니다.

```sh
npm i -D @typescript-eslint/eslint-plugin @typescript-eslint/parser
```

타입스크립트 역시 플러그인을 제공하고 있으며 패키지를 설치해서 위에서 사용한 방식대로 넣어서 사용하시면됩니다.  
타입스크립트 경우 parser를 제공하고 있는데 parser란? 구문을 분석하기 위한 패키지입니다.  
다양한 플러그인을 사용하다보면 해당 어떤 parser를 사용해야할지 정해줘야할때가 있습니다. 또 파싱을 세분화하여야 하는 경우도 발생합니다. 이 경우에 사용합니다.

typescript를 적용해 보겠습니다.

```json
{
  "root": true,
  "env": {
    "browser": true,
    "es6": true
  },
  "plugins": ["vue", "@typescript-eslint"],
  "extends": ["eslint:recommended", "plugin:vue/base"],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "sourceType": "module"
  },
  "rules": {
    "@typescript-eslint/semi": ["error", "always"],
    "@typescript-eslint/no-console": "warn"
  }
}
```

타입스크립트 eslint 플러그인을 추가해줬습니다. *@typescript-eslint*는 extends에 따로 추가해주지 않아도 됩니다.

잠시 타입스크립트 문법검사를 하기 위해서 `@typescript-eslint/parser`를 설정해 줍니다. 룰을 설정할때에는 타입스크립트 플러그인에서 제공하는 룰을 설정해야하는데 이때 룰 앞에 어떤 플러그인의 룰인지 명시해줘야하며 오타가 날 경우 eslint가 정상작동하지 않습니다.

이제 위와같이 설정했다면 _.ts_ 파일에서 eslint가 정상적으로 작동하는것을 확인할 수 있습니다.

### 다양한 파일 검사할 수 있도록 확장

프로젝트를 진행하다보면 해당 프레임워크에 맞는 확장자를 작성하게 됩니다. 예를들어 Vue.js에서는 _.vue, .js, .ts_ 가 있습니다. 이렇게 다양한 확장자를 가진 파일에 대한 검사를 하기 위해서는 각 파일마다 구문을 분석할 수 있도록 설정해줘야합니다.

한가지 예시를 들어보겠습니다. Vue.js를 사용하는데 _.vue_ 싱글 파일 컴포넌트에서 JS와 TS 모두를 사용하고 있습니다. 또 _.ts_, *.js*를 도 사용하고 있습니다. 이 경우 각 파일에 맞게 파서를 지정해줘야합니다.

```json
{
  "root": true,
  "env": {
    "browser": true,
    "es6": true
  },
  "extends": ["eslint:recommended"],
  "parserOptions": {
    "sourceType": "module"
  },
  "rules": {
    "semi": ["error", "always"],
    "no-console": "warn"
  },
  "overrides": [
    {
      "files": ["*.ts"],
      "parser": "@typescript-eslint/parser"
    },
    {
      "files": ["*.vue"],
      "plugins": ["vue"],
      "extends": "plugin:vue/base",
      "parserOptions": {
        "parser": {
          "ts": "@typescript-eslint/parser"
        }
      }
    }
  ]
}
```

## `.eslintrc.*` 설정

설정하는 방법을 코드와 함께 설명하였습니다. 이번에는 `eslintrc` 파일의 옵션에 대해 자세히 살펴보겠습니다.

| 옵션           | 설명                                                                                                                                                               | 값                                                           |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------ |
| root           | 최상위 파일을 정의합니다.                                                                                                                                          | 기본설정 `true`                                              |
| env            | 전역변수를 설정합니다. 사용할 전역변수를 가진 환경을 설정하면됩니다.                                                                                               | browser, node, es6, es2021                                   |
| globals        | 위에서 설정하지 못한 전역 변수를 정적으로 설정합니다.                                                                                                              | "myProcess": true                                            |
| parser         | eslint가 분석할 구문에대해 명시하는 공간입니다. 기본적으로 Javascript를 지원합니다.                                                                                | @typescript-eslint/parser, @babel/eslint-parser              |
| parserOptions  | parser에 대한 옵션이고 더 디테일한 설정을 할 수 있습니다. es버전을 작성할 수 있고, 소스코드를 불러오는 방식, es 추가 기능을 설정할 수 있습니다. (ex: strict mode ) | ecmaVersion, sourceType, ecmaFeatures                        |
| plugins        | eslint에서 지원해주는 플러그인으로 선호하는 추천 룰을 설정할 수 있습니다                                                                                           | eslint-plugin-\*                                             |
| extends        | 플러그인을 설정했다면 어떤 옵션을 사용할 것인지 명시하는 공간입니다. 플러그인을 사용할려면 필수로 입력해야하는 공간입니다.                                         | plugin:vue/recommend                                         |
| rules          | 사용하고자 하는 규칙을 지정할 수 있습니다.                                                                                                                         | "semi": ["error", "always"]                                  |
| ignorePatterns | lint 검사를 하지 않을 파일의 경로를 설정할 수 있습니다.                                                                                                            | /node_modules                                                |
| overrides      | 특정 파일에서 설정들을 재정의 할 수 있습니다.                                                                                                                      | { "files": ["*.ts"], "parser": "@typescript-eslint/parser" } |
