---
title: 코어 자바스크립트
category: scrapbook
layout: post
tags: [JavaScript]
---

> 코어 자바스크립트 책을 읽고 간단한 정리와 생각

## 데이터 타입

- 식별자 영역 & 데이터 영역
  - 메모리 할당과 중복된 값처리가 용이함
  - 데이터 영역의 참조 카운트를 통대 GC의 대상이됨

JS의 데이터 관리 방법에대해 디테일하게 알게되었다.

## 실행 컨텍스트

- Variable Environment : LE 스냅샷
- Lexical Environment
  - Environment Record : arguments, function, params 등의 정보를 저장 (변경내용 파악)
  - Outer Environment Reference : 스코프체인, 선언될 당시 상위 LE를 참조하고있음
- ThisBinding : this를 지정

실행 컨텍스트에서는 호출과 선언 시점을 잘 파악해야한다. 함수가 호출되는 순간에 정보수집을 선언된 코드에서한다는 점이다.

```js
let state = 'global'

function gfn() {
  console.log(state)
}

function fn() {
  let state = "fn's state"
  gfn()
}
fn() // global
```

또 렉시컬이란 단어의 사용이 프로토타입의 철학과 잘 맞아 떨어진다는 사실을 알게되었다.
비트겐슈타인은 '표현은 삶의 흐름 속에서만 의미를 갖는다'라고 주장했고 이러한 의미가 Lexical의 사전적 뜻인 '어휘적인' 즉 의미사용이론(the use theory of meaning)과 맞아떨어지는 것으로 느꼈다.

> ##### 의미사용이론이란? 
>
> '사용에 의해 의미가 결정된다는 이론'이다. 조금 더 풀어서 이야기 하자면 단어의 쓰임새가 곧 의미가 된다는 것이다.  
> 즉, 단어의 '진정한 본래의 의미'란 존재하지 않고 '상황과 맥락에 의해서 결정된다'라는 주장이다.
>
> ex) 벽돌!!  
> (벽돌이 필요할 때): 벽돌을 주셈  
> (벽돌로 보수해야 할 때): 벽돌을 채워  
> (벽돌이 떨어질 때): 벽돌을 피해라
{: .block-tip}

함께 읽어보기 좋은 자료로 [비트겐슈티인의 프로토타입](https://medium.com/@limsungmook/%EC%9E%90%EB%B0%94%EC%8A%A4%ED%81%AC%EB%A6%BD%ED%8A%B8%EB%8A%94-%EC%99%9C-%ED%94%84%EB%A1%9C%ED%86%A0%ED%83%80%EC%9E%85%EC%9D%84-%EC%84%A0%ED%83%9D%ED%96%88%EC%9D%84%EA%B9%8C-997f985adb42)
를 읽어보면 실행 컨텍스트와 prototype, this에대해 저 자세하게 알수 있다.

## this

- 발화(invoke)의 주체가 중요하며 이것을 통해 함수와 메소드를 구별할 수 있다

JS에서는 function이라는 키워드를통해 다양한 기능을 수행 가능하다. 이것을 조금더 세분화하여 사용하는것이 필요하다고 생각이든다.
나와 같은 생각이라면 '[JS의 function 기능들](http://localhost:4000/javascript/2022-11-08-do-not-use-function-keyword.html)' 글을 읽어보는 것을 추천한다.

## callBack

- 고차함수의 조건이해당되는 언어에서 함수 or 메소드를 인자로 넘겨줌으로써 제어권 위임
  - 'A의 제어권을 다른 함수(또는 메소드) B에게 넘겨주는 행위'
- 콜백 역시 함수이기 때문에 this가 전역을 가르키지만 제어권을 받은 함수에서 cb으로 this를 지정하는 경우도 있다.

## closure

- 실행 컨텍스트 내부 LE > `Outer Envirnoment Reference`를 이용하여 접근하는 방법
- 외부에서의 접근을 막고 private한 상태의 값을 가지고 있을수 있음. (정보의 은닉화)

클로저의 사용시에는 메모리를 항상 고려하고 사용해야한다.
사실 클로저 자체가 메모리를 소모하여 사용하는 방법이다. 그리고 사용한 메모리는 반납(데이터를 바라보는 참조 카운트를 0으로 만들어주는 행위)만 잘해준다면 특별히 어려울 것도없다.

많은 곳에서 클로저를 사용하고 있으면 대표적으로 커링함수가있다.

---

> 여기서 부터는 **코어 자바스크립트 책에 대한 내용 정리**입니다.

## 1. 데이터 타입

### 데이터 타입의 종류

기본형 : Number, String, Null, undefined, boolean, Symbol (6개)

참조형 : **Object**, Array, Function, Date, RegExp, Map, Set, WeakMap, WeakSet

기본형은 불변갑이고, 참조형은 가변값이다.

### 메모리와 데이터

컴퓨터는 모든 데이터를 0, 1로 바꿔서 기억한다. 0,1 로만 표현할 수 있는 하나의 메모리 조각을 bit라 한다.

묶어 하나의 단위로 표현할 수 있는데 이것을 바이트라고 한다. 바이트로 표현하면 비트보다 더 많은 위치를 표현할 수 있고 그만큼 검색 시간을 줄일 수 있다.

하지만 그만큼 낭비되는 비트가 존재하게 된고, 자주 사용하지 않을 데이터를 표현하기 위해 빈 공간을 남겨놓기보다는 표현 가능한 개수에 어느 정도 제약이 따르더라고 크게 문제 되지 않을 적정한 공간을 묶는 편이 좋다.

이 부분을 바이트는 8bit를 구성하여 256개의 값을 표현할 수 있게 만들었다.

정적 타입 언어의 경우 메모리 낭비를 최소화하기 위해 데이터 타입별로 메모리를 할당하여 사용하였고 이러한 방식은 사용자 입장에선 번거로운 일이지만 구시대의 메모리 용량이 부족했을 때에는 어쩔수없는 선택이였다.

현재는 메모리가 커져 자바스크립트가 등장했을 당시 메모리 관리에 대한 압박이 자유로웠다. 그래서 메모리 공간을 넉넉하게 할당하여 사용하였다. 숫자의 경우 정수형인지 부동소수형인지 구분하지않고 8바이트를 확보하였고, 덕분에 형변환에 유연하게 사용되었다.

바이트 역시 식별자를 통해 위치를 파악할 수 있고, 모든 데이터는 바이트 단위의 식별자로 **메모리 주소값**을 통해 서로 구분하고 연결할 수 있다.

### 식별자와 변수

변수 (Variable) : 변할 수 있는 수, 변할 수 있는 무언가(데이터)

식별자(Identify) : 어떤 데이터를 식별하는데 사용하는 이름, **변수명**

### 데이터 할당

데이터의 성질에 따라 **변수 영역 / 데이터 영역** 으로 구성되어있다.

변수 영역에 선언된 식별자와 데이터가 보관된 주소를 저장한다. 데이터 영역에선 실제 값이 보관되어있다.

> 어떤 데이터에 대해 자신의 주소를 참조하는 변수의 개수를 참조 카운트라고 한다.
>
> 이때, 참조 카운트가 0인 메모리 주소는 가비지 컬렉터의 수거 대상이된다.

#### 기본타입

```js
var a // 변할 수 있는 데이터를 만든다. 이 데이터의 식별자는 a로 한다.
a = 'abc'
```

![변수 영역과 데이터 영역](./images/data_layer.png)

#### 참조타입

```js
var obj1 = {
  a: 1,
  b: 'bbb',
}
```

![참조형 타입의 변수 영영과 데이터 영역](./images/ref-type-data-layer.png)

#### 이렇게 변수 영여과 데이터 영역을 나눠서 관리하는 이유는 무엇일까?

데이터 변환을 자유롭게 할 수 있게 함과 동시에 메모리를 더육 효율적으로 관리하기 위함이다.

예를 들어 문자열을 사용할 때 영어의 경우 1바이트, 한글의 경우 2바이트 등의 각각 필요한 메모리가 다르고 전체 글자 수 역시 가변적이다.
만약 미리 확보한 공간 내에서만 데이터 변환을 할 수 있다면 변환한 데이터를 다시 저장하기 위해서는 '확보된 공간을 변환된 데이터 크기에 맞게 늘리는 작업'이 선행되어야 한다.

이때 메모리 상의 마지막 공간을 늘리는 것은 쉽지만 중간의 데이터를 늘리는 것은 저장된 데이터를 전부 뒤로 옮기고 이동시킨 주소를 각 식별자에 매핑해줘야하는 작업이 이뤄지기 때문에 굉장한 리소스를 차지한다.
결국 효율적인 문자열 데이터의 반환을 처리하려면 변수와 데이터를 별도의 공간에 나눠 저장하는것이 최적이다.

정리하자면,

- 중복된 데이터에 대한 처리 효율이 높아진다.
- 데이터가 가변적으로 변화는 상황에서 메모리 관리가 효율적이다.

### 배열에서의 empty

```js
avr arr1 = []
arr1.length = 3;
console.log(arr1) // [empty x 3]

var arr2 = new Array(3)
console.log(arr2) // [empty x 3]

var arr3 = [undefined, undefined, undefined]
console.log(arr3) // [undefined, undefined, undefined]
```

배열의 크기를 3으로 설정하면 [empty x3]이 출력된다. 이는 배열의 3개의 빈 요소를 확보했지만 확보된 각 요소에 어떠한 값도, 심지어 undefined조차도 할당돼 있지 않음을 의미한다.

이는 '비어있는 요소'와 'undefined를 할당하는 요소'는 출력 결과부터 다르다. **'비어있는 요소'는 순회와 관련된 많은 배열 메소드들의 순회 대상에서 제외**되는데 이러한 현상이 발생하는 이유는
JS에서 배열은 객체이기 때문이다.

객체라는 사실을 인지하고 생각해본다면 자연스러운 현상이다.

배열은 무조건 length 프로퍼티의 개수만큼 빈 공간을 확보하고 각 공간에 인덱스를 이름으로 지정할 것이라고 생각하기 쉽지만,
실제로는 객체와 마찬가지로 특정 인덱스에 값을 지정할 때 비로소 빈 공간을 확하고 인덱스를 이름으로 지정하고 데이터의 주솟값을 저장하는 등의 동작을한다.

즉, 값이 지정되지않은 인덱스는 '아직은 존재하지 않는 프로퍼티'에 지나지 않는 것이다.

## 2. 실행 컨텍스트

![실행 컨텍스트 콜 스택](./images/execution-context-call-stack.png)

`실행 컨텍스트(execution context)`는 실행할 코드에 제공할 환경 정보들을 모아놓은 객체로, 자바스크립트의 동적 언어로서의 성격을 가장 잘 파악할 수 있는 개념이다.

**자바스크립트는 어떤 실행 컨텍스트가 활성화되는 시점에 선언된 변수를 위로 끌어올리는(호이스팅), 외부 환경 정보를 구성하고, this 값을 설정하는 등의 동작을 수행한다.**

### 실행컨텍스트란?

실행할 코드에 제공할 환경 정보들을 모아놓은 객체

> LexicalEnvironment : 어휘적인 환경 or 사전적인 환경

|      | VariableEnvironment (V.E)                                                                                          | LexicalEnvironment (L.E)                                                                                                   | ThisBinding                         |
| ---- | ------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| 설명 | 현재 컨텍스트 내의 식별자들에 대한 정보 + 외부 환경 정보. 선언 시점의 LE 의 스냅샷으로, 변경 사항은 반영되지 않음. | 처음에는 VariableEnvironment와 같지만 변경 사항이 실시간으로 반영됨.                                                       | this 식별자가 바라봐야할 대상 객체. |
| 구성 | environmentRecord (snapshot), outerEnvironmentReference (snapshot)                                                 | environmentRecord (argument, function, params), outerEnvironmentReference (scope chain : Linked List type [LE, parent LE]) | ThisBinding                         |

**스코프란 식별자에 대한 유효범위이다.**  
식별자의 유효범위를 안에서부터 바깥으로 차례로 검색해나가는 것을 `스코프 체인(scope chain)`이라 한다. 그리고 이것을 가능케 하는 것이 LE의 `outerEnvironmentReference`이다.  
outer는 오직 자신이 선언된 시점의 LE만 참조하고, 이런 구조적 특성 덕분에 여러 스코프에서 동일한 식별자를 선언한 경우에는 무조건 스코프 체인 상에서 가장 먼저 발견된 식별자에만 접근 가능하다.

#### 변수 은닉화(variable shadowing)

```js
var a = 1
var outer = function () {
  var a = 2
  var inner = function () {
    console.dir(a)
  }
  inner()
}
outer()
```

inner 함수 내부에서 a 변수를 선언했기 때문에 전역 공간에서 선언한 동일한 이름의 a변수에 접근할 수 없다. 이것을 변수 은닉화라고 한다.

## 3. this

전역공간에서의 this는 각 환경별로 가르키는 것이 다르다.

- 브라우저 환경

```js
console.log(this === window) // true
```

- Node.js 환경

```js
console.log(this === global) // true
```

### 전역변수와 전역객체

```js
var a = 1
console.log(a) // 1
console.log(window.a) // 1
console.log(this.a) // 1
```

전역공간에서 선언한 변수 a에 1을 할다했을때 window.a와 this.a 모두 같은 것이 출력되는 것을 확인 할 수 있다. 그 이유는 자바스크립트 모든 변수는 실은 특정 객체의 프로퍼티로서 동작하기 때문이다.

정확하게 표현하면 **'전역변수를 선언하면 자바스크립트 엔진은 이를 전역객체의 프로퍼티로 할당'** 이라 할 수 있다.

하지만 여기서 예외가 발생하는데, `property`를 삭제하는 경우이다.

```js
var a = 1
delete window.a // false
console.log(a, window.a, this.a) // 1 1 1
```

```js
var b = 2
delete window.b // false
console.log(b, window.b, this.b) // 2 2 2
```

```js
var c = 3
delete window.c // true
console.log(c, window.c, this.c) // Uncaught ReferenceError: c is not defined
```

```js
var d = 4
delete window.d // true
console.log(d, window.d, this.d) // Uncaught ReferenceError: c is not defined
```

위 코드를 보면 전역변수로 선언한 경우에는 삭제 되지않는 것을 확인가능하다.

이것은 **나름의 방버 전략**인데 전역변수를 선언하면 자바스크립트 엔진이 이를 자동으로 전역객체의 프로퍼티로 할당하면서 추가적으로 **해당 프로퍼티의 configurable 속성(변경 및 삭제 가능성)을 false로 정의**하기 때문이다.

### 함수와 메소드

- 함수 : 동릭적인 호출
- 메소드 : 발화(invoke)가 있는 호출, 점 표기법의 마지막으로 명시된 객차게 this이다.

### 함수 내부에서의 this

실행 컨텍스트를 활성화할 당시에 this가 지정되지 않은 경우 this는 전역 객체를 바라본다. 따라서 함수에서의 this는 전역 객체를 가리킨다.

### 내부함수에서의 this를 우회하는 방법

```js
var obj = {
  outer: function () {
    console.log(this) // (1) { outer: f }
    var innerFunc1 = function () {
      console.log(this) // (2) Window { ... }
    }
    innerFunc1()

    var self = this
    var innerFunc2 = function () {
      console.log(self) // (3) { outer : f}
    }
    innerFunc2()
  },
}
obj.outer()
```

사람마다 _this, that, _ 등을 변수명으로 사용하지만 self가 가장 많이 쓰이는 것 같다.

### this바인딩하지 않는 함수

ES6에서 this를 바인딩하지 않는 화살표 함수(arrow function)를 새로 도입했다. 화살표 하뭇는 실행 컨텍스트를 생성할 때 this 바인딩 과정 자체가 빠지게 되어, 상위 스코프의 this를 그대로 활용할 수 있다.

### 콜백 함수 호출 시 그 함수 내부에서의 this

> A의 제어권을 다른 함수(또는 메소드) B에게 넘겨주는 행위

콜백 함수도 함수이기 때문에 기본적으로 this가 전역객체를 참조하지만, 제어권을 받은 함수에서 콜백 함수에 별도로 this가 될 대상을 지정하는 경웨는 그 대상을 참조한다.

```js
setTimeout(function () {
  console.log(this)
}, 300)[1] // 전역
  .forEach(function (x) {
    console.log(this, x)
  }) // 전역

document.body.innerHTML += '<button id="a">클릭</button>'
document.body.querySelector('#a').addEventListener('click', function (e) {
  console.log(this, e)
}) // button 객체
```

### 생성자 함수 내부에서의 this

생성자 함수는 어떤 공통된 성질을 지니는 객체들을 생성하는 데 사용하는 함수이다.

여기서 `생성자`는 구체적인 인스턴스를 만들기 위한 틀이고, new 명령어와 함께 함수를 호출하면 해당 함수가 생성자로서 동작하게 된다.

**어떤 함수가 생성자 함수로서 호출된 경우 내부에서의 this는 곧 새로 만들 구체적인 인스턴스 자신(생성자의 this)이다.**

생성자 함수를 호출(new 명령어와 함께 함수를 호출)하면 우선 생성자의 prototype 프로퍼티를 참조하는 **proto** 라는 프로퍼티가 있는 객체(인스턴스)를 만들고, 미리 준비된 공통 속성 및 개성을 해당 객체(this)에 부여한다.

### call / apply 메소드의 활용

```js
var obj = {
  0: 'a',
  length: 1,
}

Array.prototype.push.call(obj, 'b')
console.log(obj) // { 0: 'a', 1: 'b' }

var arr = Array.prototype.slice.call(obj)
console.log(arr) // [ 'a', 'b' ]
```

유사배열객체(array-like object)에 배열 메서드를 활용가능하다. 유서배열객체는 함수 내부에서 접근할 수 있는 `arguments` 객체도있고, querySelectorAll, getElementByClassName 등의 Node 선택자로 선택한 결과인 NodeList도있다.

call, apply는 메소드는 명식적으로 별도의 this를 바인딩하면서 함수 또는 메소드를 실행하는 훌륭한 방법이지만 오히려 이로 인해 this를 예측하기 어렵게 만들어 코드 해석을 방해한다는 단점도있다.

이에 ES6에서는 유사배열객체 또는 순회 가능한 모든 종류의 데이터 타입을 배열로 전환하는 Array.from 메소드를 도입했다.

### name 프로퍼티

bind 메소드를 적용해서 새로 마든 함수는 한가지 독특한 성질이있다. 바로 name프로퍼티에 동사 bind의 수동태인 'bound'라는 접두어가 붙는다.

```js
var func = function (a, b, c, d) {
  console.log(this, a, b, c, d)
}
var bindFunc = func.bind({ x: 1 }, 4, 5)
console.log(func.name) // func
console.log(bindFunc.name) // bound func
```

### 화살표 함수의 예외상항

함수 내부에는 this가 아예 없으며(화살표함수가 아닌 함수는 전역을 가리킴), 접근하고자 하면 스코프체인상 가장 가까운 this에 접근한다.

--- 

참고

- [https://medium.com/@limsungmook/%EC%9E%90%EB%B0%94%EC%8A%A4%ED%81%AC%EB%A6%BD%ED%8A%B8%EB%8A%94-%EC%99%9C-%ED%94%84%EB%A1%9C%ED%86%A0%ED%83%80%EC%9E%85%EC%9D%84-%EC%84%A0%ED%83%9D%ED%96%88%EC%9D%84%EA%B9%8C-997f985adb42](https://medium.com/@limsungmook/%EC%9E%90%EB%B0%94%EC%8A%A4%ED%81%AC%EB%A6%BD%ED%8A%B8%EB%8A%94-%EC%99%9C-%ED%94%84%EB%A1%9C%ED%86%A0%ED%83%80%EC%9E%85%EC%9D%84-%EC%84%A0%ED%83%9D%ED%96%88%EC%9D%84%EA%B9%8C-997f985adb42)