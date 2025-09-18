---
layout: post
title: '구닥다리 공룡을 위한 오늘날의 JavaScript'
categories: Develop
tags: [JavaScript, NPM, webpack, babel]
---

## Modern JavaScript Explained For Dinosaurs

![1](https://steemitimages.com/DQmTjgFdSuYBi4qqSxKmivun54Y7aLAkz6jChi7DU2Qxrdq/modern_dino_1.png)

오늘날 자바스크립트를 공부하는 것은 힘들다. 특히나 초창기부터 자바스크립트를 접하지 않은 사람이라면 더욱이..!
그정도로 자바스크립트의 생태계는 엄청 빠르게 성장하고 변하기 때문에 다양한 도구로 해결하는 문제 자체가 이해하기 어려워 졌다.

[Browserify](http://browserify.org/)라는 태그라인을 알고있는가?

> "Browserify는 브라우저에서 require('modules')를 사용하여 모든 의존성을 통합할 수 있다." <br>
> 라는 설명 문장으로 설명되어 있지만 이해하기 어렵다 😅

이 글에서는 website(단순한 HTML, JavaScript 외에 어떤 도구도 사용되지 않는)를 만들어 보고, 차차 구식 frontend 개발 생태계의 문제점들을 해결하는 도구들을 하나씩 소개할 예정이다.

## 구식 자바스크립트

일단, 수동으로 파일들을 다운받고 연결하는 구식 웹사이트로 시작해 본다.

이 웹사이트는 HTML과 자바스크립트를 사용한다. 여기 하나의 자바스크립트 파일이 연결된 간단한 index.html이 있다.

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="ko">
  <head>
    <meta charset="UTF-8" />
    <title>자바스크립트 Example</title>
    <script src="index.js"></script>
  </head>
  <body>
    <h1>Hello from HTML!</h1>
  </body>
</html>
```

이 행은 index.html과 같은 디렉토리에 있는 별도의 자바스크립트 파일인 index.js를 참조한다. index.js의 내용은 아래와 같다.

```javascript
console.log('Hello from 자바스크립트!')
```

이게 웹사이트를 만드는데 필요한 전부이다. 이제 여기에 외부 라이브러리를 추가할 예정이다. [moment.js](https://momentjs.com/)는 날짜 형식을 사람이 읽기 쉬운 형식으로 바꿀때 유용한 라이브러리이다. 예를 들어 아래와 같이 moment함수를 사용할 수 있다.

```js
moment().startOf('day').fromNow() // 20 hours ago
```

그치만 이건 어디까지나 moment.js를 현재 웹사이트에 포함시켰단 가정하에 이야기이다. [moment.js의 홈페이지](https://momentjs.com/)를 방문해 보면 아래와 같은 지시사항을 볼 수 있다.

![monent.js install](./images/placeholder.png)

오른쪽 인스톨 섹션은 일단 무시하자. index.html이 들어있는 디렉토리에 `moment.min.js`를 다운로드 한다. 그러면 아래의 코드처럼 index.html에 `moment.min.js`를 추가 시킬 수 있다.

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Example</title>
    <link rel="stylesheet" href="index.css" />
    <script src="`moment.min.js`"></script>
    <script src="index.js"></script>
  </head>
  <body>
    <h1>Hello from HTML!</h1>
  </body>
</html>
```

`moment.min.js`가 index.js보다 앞서 로드 되고 있다는걸 주의해야한다. 이말은 index.js안에서 moment함수를 사용할 수 있게 되었다는것을 의미한다.

```js
// index.js
console.log('Hello from 자바스크립트!')
console.log(moment().startOf('day').fromNow())
```

그리고 이게 바로 웹사이트에 자바스크립트 라이브러리를 사용하는 방식이다(완전 구식😜 ). 이해하기 쉽다는게 이 방식의 장점이고, 단점은 라이브러리 제작자가 업데이트를 할 때마다 그것의 새 버전을 매번 찾아야 하고 다운로드하기 번거롭다는 것이다.

## 자바스크립트 패키지 매니저(npm) 사용하기

2010년 즈음, 중앙 레포지토리로부터 라이브러리 다운로드와 업그레이드를 자동화 해주는, 여러 경쟁적인 자바스크립트 패키지 매니저가 등장했다.
2013년 [Bower](https://bower.io/)는 거의 이껸 없이 최고의 인기 제품이었다 하지만, 2015년 즈음하여 [npm](https://www.npmjs.com/)이 그 인기를 따라잡았다. 2016년 말부부터는 [yarn](https://yarnpkg.com/en/)이 npm 인터페이스의 대안으로 나타났지만 yarn 역시 npm 패키지를 내부적으로 사용하고 있다.

npm은 원래 [node.js](https://nodejs.org/)를 위해 특별히 만들어진 패키지 매니저라는 점을 염두해야 한다. node.js는 프론트엔드가 아닌 서버 위에서 구동되도록 설계된 자바스크립트 실행 환경으로써 브라우저에서 실행되는 JS 라이브러리들을 위한 프론트엔드 자바스크립트 패키지 매니저로 선택했다는 건 꽤 괴팍하다고 할 수 있다. 서버 환경에서 쓰던걸 프론트엔드 환경에서 쓰려는 것이기 때문이다

> 🎈 Tip: 패키지 매니저를 쓴다는 것은 보통 커맨드라인 사용과 연관있다. 이전 프론트엔드 개발 방식(완전 구식)에서는 전혀 필요 없던 부분이다.
> 하지만 지금은 커맨드라인은 땔 수 없는 존재가 되었다. 커맨드라인을 사용함으로써 다른 개발 영역으로의 다양한 문을 열 수 있을 것이다.

완전 구식 방식의 단점으로 번거롭게 매번 수동으로 다운받는 것을 대신하여 npm을 사용하여 moment.js 패키지를 자동으로 설치하는지 확인 해보자.
npm을 사용하기 위해서는 [node.js](https://nodejs.org/)가 설치되어 있어야한다. LTS 버전을 이용하도록하자.

> 🔨 버전 설치: 버전을 고를때는 신중해야한다. 너무 최신 버전을 고르는것 보다 두 버전을 낮춰서 설치하는 것을 추천한다. <br>
> node.js 같은 경우 LTS 버전이 있는데 여기서는 이것을 선택한다. LTS(Long Term Support)로 오랫동안 이 버전에 대해 서포팅을 한다는 뜻인듯...

커맨드라인으로 index.html이 있는 디렉토리로 이동한 후 다음 명령어를 입력해봐야한다.

```sh
npm init
```

이 명령어를 입력하면 몇 가지 질의응답 과정이 이어지고, 응답은 기본 값으로 충분하다(모두 엔터키). 그러면 `package.json`이라는 새로운 파일 하나가 생성된다. 이 파일을 configuration(설정, 구성) 파일로 npm이 이 프로젝트에 대한 모든 정보를 저장하는데 사용된다. 기본적인 `package.json`의 내용은 아래와 같다.

```json
{
  "name": "my-project-name",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}
```

이제 moment.js 자바스크립트 패키지를 설치하기 위해서 moment.js의 홈페이지에 안내되어 있는 명렁어를 커맨드라인에 입력해야한다.

```sh
npm install moment
```

이 명령어를 통해 두가지 일이 수행된다. 첫번째 moment.js 패키지의 모든 코드를 내려받아 `node_modules`라는 폴더에 저장한다. 둘째로 `package.json` 파일이 아래로 수정된다. 이것으로 프로젝트가 의존성을 갖는 moment.js를 지속적으로 추적하도록 한다.

```json
{
  "name": "modern-자바스크립트-example",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "moment": "^2.19.1"
  }
}
```

이는 나중에 다른 개발자와 프로젝트를 공유할때 유용하게 사용된다. 보통 용량이 큰 `node_modules` 폴더를 직접 공유하는 대신 `package.json` 파일을 공유함으로써 다른 개발자들이 필요한 패키지들을 자동으로 설치할 수 있도록 한다. ➡️ `npm install` 명령어를 통해서

이제 더이상 프로젝트에 수동으로 moment.js를 내려받을 필요가 없어졌다. npm을 이용하여 자동으로 다운로드 받고 업데이트 받을 수 있다. `node_modules` 폴더 안을 살펴보면 `moment.min.js` 파일이 `node_modules/moment/min` 디렉토리 안에 있을것이다. ➡️ npm으로 다운로드 한 `moment.min.js`를 index.html에 연결 할 수 있다는 의미이다!!

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="ko">
  <head>
    <meta charset="UTF-8" />
    <title>JavaScript Example</title>
    <script src="node_modules/moment/min/moment.min.js"></script>
    <script src="index.js"></script>
  </head>
  <body>
    <h1>Hello from HTML!</h1>
  </body>
</html>
```

커맨드라인으로 npm을 사용해 우리의 패키지들을 다운로드하고 업데이트 할 수 있다는 장점이 있다.
이 상황에서 나쁜 점은 패키지가 실제로 담겨있는 `node_modules` 폴더의 깊은 곳까지 파고들어야지만 수동으로 HTML에 불러올 수 있다는 것(꽤 나 불편).
그래서 이제는 자동으로 처리해 주는 방법을 살펴볼 예정이다.

![3](https://steemitimages.com/DQmfM1oybkxdG8PoLPn1tn1i4huV3Gs3TJ5y4YmFh9RQu6b/modern_dino_2.png)

## 자바스크립트 모듈 번들러(webpack) 사용하기

대부분의 프로그래밍 언어들이 하나의 코드에서 다른 코드를 불러들이는 방법을 제공한다. 하지만 자바스크립트는 이런 기능이 없었다. 그 이유는 자바스크립트는 오직 브라우저 환경에서만 구동되도록 만들어졌고 보안상의 이유로 컴퓨터의 파일 시스템에 접근 할 수 없기 때문이다. 그래서 오랜 시간동안 다수의 파일로 자바스크립트 코드를 구성하는 일은 각 파일을 전역 변수로 할당하여 공유해야만 했다.

이전의 구식적으로 사용한 행위 역시 위 메커니즘을 이용하여 사용하였따. 예를 들어 전체 `moment.min.js` 파일은 HTML로 로드 된다. 그 안에 정의 되어있는 변수 moment는 전역 변수가 된다. 그 후에 로드 되는 모든 파일에서는 이 전역변수를 사용 할 수 있게된다.

2009년, CommonJS라는 이름의 프로젝트가 시작된다. 이것을 목표는 브라우저 외의 자바스크립트 생태계를 만드는 것이다. CommmonJS의 대부분은 모듈에 대한 명세이다. 이 명세로 마침내 자바스크립트가다른 대부분의 프로그래밍 언어들 처럼 파일을 통해 코드를 들여오고(import) 내보낼(export) 수 있게 된다. 전역 변수에 할당하는 방법 대신에... 이 CommonJS 모듈의 구현체 중 가장 유명한 것이 바로 node.js이다.

![4](https://miro.medium.com/max/424/1*xeF1flp1zDLLJ4j7rDQ6-Q.png)

## node.js는 서버에서 구동되도록 설계된 자바스크립트 실행 환경이다

초기 node.js 모듈 사용 예시를 살펴보자. `moment.min.js`를 HTML script tag로 불러오는 것 대신 자바스크립트 파일을 직접 자바스크립트 안에 불러올 수 있다.

```js
// index.js
var moment = require('moment')
console.log('Hello from 자바스크립트!')
console.log(moment().startOf('day').fromNow())
```

이것이 node.js에서 작동하는 모듈 로딩 방식이다. <br>
node.js가 컴퓨터의 파일 시스템에 접근 가능한 서버 사이드 언어이기에 가능한 것. node.js는 또 각 npm 모듈이 어느 경로에 위치하는지 알고 있다.<br>
이 덕분에 `require('./node_modules/moment/min/moment.min.js')`라고 쓰는 대신 `require('moment')`라고 쓸 수 잇다. 👍

node.js가 이렇게 좋지만, 위 코드를 부라우저 상에서 실행 하려고 하면 `require`가 정의되지 않았다는 에러가 뜬다. 😅 브라우저는 파일 시스템에 접근 권한이 없어서인데 이를 해결하기위한 방법은 매우 까다롭다.. <br>
파일들을 불러오는 것이 (실행속도를 느리게 하는)동기적인 것이든 (타이밍 문제가 있는)비동기적인 것이든 동적으로 수행되어야만 한다.

> `require`와 같은 모듈 로딩 구문은 실행시에 그 구문이 로드한 다른 파일의 코드로 대친된다.

**이러한 부분이 바로 모듈 번들러가 필요해 지는 지점이다.** 자바스크립트 모듈번들러는 파일 시스템에 접근 할 수 있는 빌드 단계에서 위와 같은 문제를 해결하여 브라우저와 호환되는 (파일 시스템에 엑세스 할 필요가 없는) 최종 결과물을 만들어내는 도구이다. 여기서 우리는 모든 `require` 구문을 찾아내어 이를 (실제 요구된 파일)실제 내용으로 대치시켜주는 모듈 번들러가 필요해진다. 이때 최종적인 결과물은 하나로 묶인(bundled) (require 구문이 없는) 단일 자바스크립트 파일인 되느 것이다.!!

가장 인기있었던 모듈 번들러는 [Browserify](http://browserify.org/)로, node.js 방식의 `require`구문을 프론트엔드에 사용하는데 있어 선구자적 역할을 했다. 근본적으로 npm이 프론트엔드 패키지 매니저가 될 수 있게 만들어준셈이다. 그 후 [webpack](https://webpack.github.io/)이 등장하면서 더 보편적으로 사용되는 모듈 번들러로 자리매김한다.

> webpack의 이점을 몽땅 활용 가능한 프론트엔드 ~~프레임워크~~인 React의 인기가 높아짐 <br>

- React는 프레임워크가 아닌 라이브러리.

### webpack 살펴보기

webpack을 써야 `require('moment')` 예제를 브라우저에서 돌릴 수 있다. 젤 처음으로 webpack을 프로젝트에 추가해야된다. webpack 자체는 그저 npm 패키지이고, 따라서 아래 커맨드로 설치 할 수 있다.

```sh
npm install webpack webpack-cli --save-dev
```

> 🎈 tip : `--save-dev` 인수로 설치하면 패키지가 개발용 의존으로 저장된다. <br>

- 패키지가 개발 환경에서만 쓰이고 서버에 올라간 제품 상태에선 사용하지 않을 것이란 의미.
- `package.json`에도 자동으로 반영됨. <br>

```json
{
  "name": "modern-자바스크립트-example",
  "버전": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"에러: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "moment": "^2.19.1"
  },
  "devDependencies": {
    "webpack": "^5.21.2",
    "webpack-cli": "^3.3.12"
  }
}
```

webpack이 패키지 중 하나로써 `node_modules` 폴더에 설치가 된다. 커맨드라인에 아래처럼 입력함으로써 webpack을 사용할 수 있다.

```sh
./node_modules/.bin/webpack index.js --mode=development
```

이 명령은 `node_modules`에 설치되어 있는 webpack 도구를 실행시킨다. 실행되는 도구는 `index.js` 파일을 읽기 시작하여 `require` 구문을 찾고 이를 다른 파일의 코드로 대치시킨 최종 결과물로써 `dist/main.js`를 출력한다. 이제 HTML에서 더 이상 (`require` 구문이 있는)`index.js`를 쓸 수 없게 된다. 하지만 `dist/main.js`를 쓰면된다.

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="ko">
  <head>
    <meta charset="UTF-8" />
    <title>자바스크립트 Example</title>
    <script src="dist/main.js"></script>
  </head>
  <body>
    <h1>Hello from HTML!</h1>
  </body>
</html>
```

브라우저를 새로고침 해보면 이전과 마찬가지로 모든 것이 정상 작동하는 것을 볼 수 있다.

`index.js`가 수정 될 때마다 webpack 명열을 실행해야 하는데 이것은 상당히 귀찮다. 여기에 webpack의 고급 기능을 사용하면 더 귀찮아진다.<br>
이 점을 해결하기위해서 webpack은 config(설정) 파일로부터 옵션들을 설정할 수 있다. 이 config 파일은 프로젝트의 root 폴더에 위치하며 `webpack.config.js`로 만들면 된다.

```js
// webpack.config.js
module.exports = {
  mode: 'development',
  entry: './index.js',
  output: {
    filename: 'main.js',
    publicPath: 'dist',
  },
}
```

위와 같이 설정을 해두면 이제 `index.js`가 변경될 때 마다 아래 명령어를 통해 사용할 수 있다.

```sh
./node_modules/.bin/webpack
```

`webpack.config.js`에 설정한 옵션들을 webpack이 알아서 읽기 때문에 좀 더 편한 방법이다. 그러나 명령어를 매번 입력하는 것도 역시 귀찮다. 이걸 좀더 편하게 만들어 보자.

지금까지 워크 플로우엔 상당한 이점이 있는데 더이상 전역변수로 외부 스크립트를 불러들일 필요가 없는 점이다. 어느 자바스크립트 라이브러리도 HTML 태그 대신 자바스크립트의 `require` 구문을 통해 추가될 것이다. 단일 자바스크립트 묶음 파일을 갖는 것은 성능면에서도 더 좋다. 그리고 이제 또 다른 강력한 기능들을 개발 workflow에 추가 할 수 있는 빌드 단계가 추가된다.

![4](https://steemitimages.com/DQmeBBfUCYJn6NFQCzyBXyeQTNh6CycLpnfTaUuKa4NyU3H/modern_dino_3.png)

## 언어의 새로운 기능을 사용하기 위한 transpiling (bable)

코드를 트랜스파일(transpile) 한다는 것은 어떤 한 언어로 작성 된 코드를 비슷하지만 다른 언어롤 변환 시켜준다는 것이다. 이것은 프론트엔드 개발에 있어 중요한 부분이다. 브라우저는 언어의 새로운 기능을 추가 지원 해주는 데에 늘 지원이 늦은 부분이 있기때문에 새언어의 실험적인 기능은 브라우저에 호환되는 언어로 트랜스파일 해야한다.

CSS로 따지면 [Sass](http://sass-lang.com/), [Less](http://lesscss.org/) 그리고 [Stylus](http://stylus-lang.com/) 등이 있다. 자바스크립트는 가장 인기있었던 트랜스파일러는 [CoffeeScript](http://coffeescript.org/) 이었고, 현재는 대부분의 사람들이 [babel](https://babeljs.io/) 또는 [TypeScript](http://www.typescriptlang.org/)를 사용한다. CoffeeScript는 임의의 괄호, 의미있는 공백들을 적용함으로써 자바스크립트를 발전시키는데 초점을 맞추고 있다. Babel은 새로운 언어는 아니지만 아직 모든 브라우저에서 사용활 수 없는 다른 버전의 자바스크립트(ES2015 이후)의 기능을 오래되고 호환 가능한 자바스크립트(ES5)로 트랜스파일 해주는 트랜스파일러이다. TypeScript는 기본적으로 다음 세대 자바스크립트와 같지만 임의의 정적 형지정(typeing)을 추가하는 언어이다. 지금은 많은 사람들이 babel을 선택해서 사용하고 있다. 이것이 바닐라스크립트와 가장 가깝기 때문이다.

babel을 어떻게 사용하는지 이미 만들어 둔 webpack 빌드 과정과 함께 그 예시를 확인해보자. 먼저 babel을 우리 프로젝트에 커맨드라인으로 설치 해야한다. babel은 npm package이기 때문에 아래 명령어로 설치 가능하다.

```sh
npm install @babel/core @babel/preset-env babel-loader --save-dev
```

개발 의존성으로 3가지 별도의 패키지를 설치하고 있는 것을 확인해야한다.
`babel-core`는 babel의 핵심부이다. `babel-preset-env`는 어떠한 자바스크립트 새 기능을 트랜스파일할지에 대한 사전정의(preset)이다. `babel-loader`는 babel이 webpack과 함께 일 할수있게 해주는 패키지이다. 이것으로 `webpack.config.js`를 아래와 같이 수정하여 `babel-loader`를 사용할 수 있다.

```js
// webpack.config.js
module.exports = {
  mode: 'development',
  entry: './index.js',
  output: {
    filename: 'main.js',
    publicPath: 'dist',
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'],
          },
        },
      },
    ],
  },
}
```

기본적으로 이 설정을 통해 webpack에게 모든 .js파일을 지켜보도록 시키고 있다(`node_modules`의 항목은 제외). 그리고 `babel-preset-env`로 사전정의 된 babel-loader를 사용하여 babel의 트랜스파일을 적용한다.

위와같이 설정한다면 ES5의 기능을 사용할 수 있다는 말이다.

```js
// index.js
var moment = require('moment')
console.log('Hello from 자바스크립트!')
console.log(moment().startOf('day').fromNow())
var name = 'Bob',
  time = 'today'
console.log(`Hello ${name}, how are you ${time}?`)
```

`require` 대신 **ES5 import 구문**을 모듈 로딩에 사용할 수 있다. <br>
`import` 문법은 `require` 문법과 많이 다르지 않다. 그러나 더욱 진복한 상황에서 전자가 추가적인 유연성을 갖고 있다.

```js
// index.js
import moment from 'moment'
console.log('Hello from 자바스클비트!')
console.log(moment().startOf('day').fromNow())
var name = 'Bob',
  time = 'today'
console.log(`Hello ${name}, how are you ${time}?`)
```

위와같이 `index.js`를 수정한 뒤 아래 명령어를 통해 webpack을 다시 수동해줘야한다.

```sh
./node_modules/.bin/ webpack
```

이제 브라우저에서 `index.html`을 새로고침하면 정상적으로 동작하는 것을 볼 수 있다. 대부분의 브라우저들이 모든 ES5 기능을 지원하고 있을것이다. babel이 작업된 내용을 확이하고 싶다면 `dist/main.js`을 열어서 트랜스파일된 코드를 확인해보면된다.

```js
// dist/main.js
// ...
console.log(\"Hello \".concat(name, \", how are you \").concat(time, \"?\"));
// ...
```

브라우저 호환성을 맞춰주기 위해 ES2015 템플릿 문자열이 일반적인 자바스크립트 문자열 연쇄로 트랜스파일 된 모습을 볼 수 있다. 트랜스파일 코드의 능력은 아주 강력한 것이기 때문에 중요한 내용이다. 오늘 당장 사용하여 더 좋은 코드를 작성활 수 잇게 해줄 [async/await]() 같은 언어의 재미난 기능이 나올것이다, 그리고 트랜스파일을 통해 더욱 확장된 기능을 사용할 수 있게된것이다.

마지막 워크플로우로는 성능에대한 이슈이다. 안약 성능을 고려한다면, 번들 파일을 [축소](https://en.wikipedia.org/wiki/Minification_%28programming%29)시킬 필요가 있다. 우리가 이미 빌드과정을 결합시켜 놨으니 이 과정을 무척 쉬울것이다. 또 지금은 자바스크립트가 변경될때마다 webpack 커맨드를 재실행 시켜줘야 한다. 그래서 다음 단계에서는 이를 해결하기 위한 편리한 도구들을 찾아본다.

## 태스크러너 사용하기 (npm scripts)

지금까지 빌드 단계를 사용하여 자바스크립트 모듈로 일하고 있으므로 태스크러너를 사용하여 **각기 다른 부분의 빌드 프로세스를 자동화 해주는 도구**를 사용할 것이다. 프론트엔드 개발에 있어 태스크란 코드 압축(minify), 이미지 최적화, 테스트 실행 등을 말한ㄷ.

2013년, Grunt가 가장 인기 있는 프론트엔드 태스크러너였고, Gulp가 뒤를 이었다. 둘 모두 다른 커맨드라인 도구를 두르고있는 플러그인에 기대고있다. 요즘은 가장 인기 있는 npm 패키지 매니저 자체의 스크립팅 가용성을 이용하고 있다. 따라서 따로 plugin을 사용하지 않고 다른 커맨드라인 도구와 직접 작업한다.

npm 스크립트를 작성해서 webpack 사용을 좀 더 쉽게 만들어 보자. <br>
`package.json`을 조금 수정한다.

```json
{
  "name": "modern-javascript-example",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "build": "webpack --progress --mode=production",
    "watch": "webpack --progress --watch"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "moment": "^2.22.2"
  },
  "devDependencies": {
    "@babel/core": "^7.0.0",
    "@babel/preset-env": "^7.0.0",
    "babel-loader": "^8.0.2",
    "webpack": "^4.17.1",
    "webpack-cli": "^3.1.0"
  }
}
```

`build`와 `watch`라는 두 새로운 스크립트가 추가되었다. `build` 스크립트를 구동하려면 커맨드라인을 아래와 같이 입력하면된다.

```sh
npm run build
```

이를 통해 webpack(이전에 만들어 둔 `webpack.config.js`를 설정으로 사용)이 구동되는데 `--progress` 옵션을 주면 진행 정도를 백분율로 보여주며 `--mode=production` 옵션을 주면 제품용 코드를 압축하게 된다. `watch` 스크립트를 구동하려면 아래와 같다.

```sh
npm run watch
```

이것은 `--watch` 옵션을 사용하고 있기 때문에 자바스크립트가 수정될 때마다 자동으로 webpack을 재실행 해준다.

`package.json`의 스크립트에 webpack의 완전한 전체경로 `./node_modules/.bin/webpack`이 없어도 구동할 수 있는 점을 주목해야한다..!! node.js가 각각의 npm모듈 경로를 알고 있기 때문이다. 심지어 webpack-devserver를 설치하면 더 좋은 기능을 사용할 수 있다. 실시간 다시 불러오기(live reloading) 기능과 함께 단순한 웹 서버를 제공하는 별도의 도구이다. 개발 의존성으로 설치하려면 다음과 같다.

```sh
npm install webpack-dev-server --save-dev
```

그리고나서 `package.json`에 다음과 같이 npm 스크립트가 추가한다.

```json
{
  "name": "modern-javascript-example",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "build": "webpack --progress --mode=production",
    "watch": "webpack --progress --watch",
    "server": "webpack-dev-server --open"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "moment": "^2.19.1"
  },
  "devDependencies": {
    "@babel/core": "^7.0.0",
    "@babel/preset-env": "^7.0.0",
    "babel-loader": "^8.0.2",
    "webpack": "^3.7.1",
    "webpack-dev-server": "^3.1.6"
  }
}
```

이제 개발용 서버를 아래의 커맨드로 실행 시킬 수 있다.

```sh
npm run server
```

이걸로 `index.html` 웹사이트가 브라우저에 `localhost:8080`(기본값)으로써 자동으로 열린다. 이제 언제든지 `index.js`의 자바스크립트를 수정하면, webpack-dev-server는 번들 된 자바스크립트를 다시 빌드하고 브라우저를 자동으로 새로고침 할 것이다.

> 🔨 webpack-dev-server가 실행이 안된다면!! webpack-cli 버전을 낮춰서 다시 시작해보세요(의존성 문제). <br>

```sh
npm install --save-dev webpack webpack-cli webpack-dev-server
```

>   <details>

        <summary>필자의 당시 버전😄 </summary>
        <pre>
        // package.json
        // ...
        "devDependencies": {
            // ...
            "webpack": "^5.21.2",
            "webpack-cli": "^3.3.12",
            "webpack-dev-server": "^3.11.2"
        }
        </pre>
    </details>

이보다 훨씬 많은 옵션들이 webpack과 webpack-dev-server에 존재한다. 당연히 다른 태스크를 위해 npm 스크립트를 작성할 수 있다. Sass를 CSS로 변환하는 일, 이미지를 압축 하는 일, 테스트를 실행하는 일 등 커맨드라인 tool만 있으면된다. 또한 엄청 고급 옵션과 트릭들이 npm 스크립트 자체에 있다.

**[참고영상]**

<iframe width="640" height="360" src="https://www.youtube.com/embed/0RYETb9YVrk" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## 결론

단순 HTML과 JS를 시작으로 패키지 매니저를 써서 3rd 패키지들을 자동으로 다운로드하고, 모듈 번들러를 사용해서 단일 스크립트 파일을 만들어내고, 트랜스파일러를 이용해서 미래의 자바스크립트 기능들을 사용했으며, 그리고 태스크러너로 다른 부분의 빌드 과정을 자동화 했다.

프론트엔드와 함께 작업할 실행가능한 방법으로써 node 생태계를 적용하면 상황은 꽤 안정화된다. npm을 패키지 매니저로 사용하는 것, node `require`나 `import` 구문을 모듈을 위해 사용하는 것, 그리고 npm 스크립트로 태스크를 수행하는 것 등...

요즘은 프레임워크가 위 과정을 더 쉽게 시작할 수 있도록 해주는 도구를 제공한다는 것이다. Ember는 Angular의 [angular-cli](https://cli.angular.io/)로 부터 영향을 받은 [ember-cli](https://ember-cli.com/)를 갖고 있고, React는 [create-react-app](https://github.com/facebookincubator/create-react-app), Vue는 [vue-cli](https://github.com/vuejs/vue-cli)등을 갖고 있다. <br>
이 모든 도구들은 프로젝트를 구성해준다. 프로젝트에 필요한 모든것과 함께. 우리가 해야할 일은 그저 코드를 작성하기 시작하는 것 밖에 없다. 그렇다고해서 무시하거나 방관해서는 안된다. 이 도구들은 일관되고 잘 동작하는 방식으로 모든 것을 구성할 뿐 종종 별도의 webpack, babel, 기타등등의 설정이 필요한 부분을 마주치게 되기 때문이다.

지금도 자바스크립트의 생태계는 급격하게 진화하고있다. hot-reloading, 실시간 문법 검사, time-travel debugging과 같은 혁신에 도움을 주고 있다. 자바스크립트 화이팅 ~! 😘

![](https://steemitimages.com/640x0/https://steemitimages.com/DQmXzUJqgkgtPD4xQKtKEQmm5SzB4chkU53GBtAWq4qwLor/modern_dino_4.png)

---

참고

- <https://medium.com/the-node-js-collection/modern-javascript-explained-for-dinosaurs-f695e9747b70>
- <https://steemit.com/javascript/@march23hare/javascript>
