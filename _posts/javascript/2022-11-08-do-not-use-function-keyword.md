---
title: 'JS function 키워드 지양하는건 어떨까?'
layout: post
category: 'javascript'
tags: ['function', 'arrow', 'generator']
---

> 해당 글은 [[Javascript미세팀] function은 아예 쓰지 마세요](https://www.youtube.com/watch?v=LPEwb5plEoU) 영상을 참고하여 작성하였습니다.

자바스크립트는 `function` 키워드를 이용하여 함수를 만들 수 있습니다. 그리고 function 키워드를 이용하여 생성자함수, 객체메소드를 구현할 수 있습니다.

이렇게 하나의 키워드를 이용해서 다양하게 사용되는 `function`을 **각각의 목적에 맞는 대체 문법**으로 구별해서 사용하는 것은 어떨까요?

## function 키워드

- 생성자 함수
- 일반 함수
- 객체 메소드

위 처럼 범용적으로 상용할 수 있습니다. 하지만 이것은 오히려 협업에서 불리하게 작용할 수 있습니다.

어떤 문제가 있고, 어떤 대체 문법이 있는지 확인해보고 취향에 맞는 스타일을 적용해보는것을 제안드립니다.

## function 키워드의 생성자 함수 문제점

생성자 함수란?

function 키워드를 이용해서 인스턴스를 생성하는 방식을 말합니다. `new` 키워드를 이용해서 생성하며 구현체내의 this를 이용해 프로퍼티를 정의합니다.
또 prototype을 이용해 속성, 기능을 상속 시킬 수 있습니다.

```js
function Foo(...args) {
  if (this !== window) this.args = args
  else return args
}
Foo.prototype.getArgs = function () {
  return this.args
}
const foo = new Foo(1,2)
console.dir(foo)
```

![constructor function](/assets/post-img/2022-11-08-function-keyword/constructor-function.png)

ES6에선 생성자 함수를 대체할 수 있는 `class`가 나왔습니다. 이 클래스를 이용해서 인스턴스를 생성하고 상속을 구현 가능하게 합니다.

```js
class Bar {
  constructor(...args) {
    if (this !== window) this.args = args
    else return args
  }
  getArgs () {
    return this.args
  }
}
const bar = new Bar(3,4)
console.dir(bar)
```

생성자 함수와 class는 사용 용도는 같지만 미세하기 차이가 있습니다. 생성자 함수와 class를 비교해보겠습니다.

### 1. 고유 프로퍼티 체크

![생성자함수와 class 비교](/assets/post-img/2022-11-08-function-keyword/constructor-console-log.png)

위 그림은 foo와 bar를 콘솔에 출력한 화면입니다. 그림에서 `getArgs`를 보시면 생성자 함수에서는 진하게 표시되어있습니다. 이것이 뜻하는 것은 `getArgs`가 순회 대상이 된다는 뜻입니다. 즉 고유 속성이 아니지만 `for in`문법을 통해 접근이 가능하고 이것을 처리하기 위해선 `hasOwnProperty`와 같은 문법을 사용해서 조건처리를 해줘야합니다.

```js
for(let prop in foo) {
  console.log(prop); // args, getArgs
}

for(let prop in foo) {
  if (!foo.hasOwnProperty(prop)) continue
  console.log(prop); // args
}

for(let prop in bar) {
  console.log(prop); // args
}
```

> prototype 으로 직접 할당한 방식은 `enumerable` 값이 `true`로 되어있습니다.
> class 방식에선 함수는 `enumerable` 값이 `false`로 설정되어있습니다.
>
> 이 설정에의해서 순회대상이 되는 것 같습니다.

### 2. arguments 접근 에러 핸들링

이번에는 Foo함수와 Bar클래스 자체를 비교해 보겠습니다.

```js
function Foo(...args) {
  if (this !== window) this.args = args
  else return args
}
Foo.prototype.getArgs = function () {
  return this.args
}
console.dir(Foo)

class Bar {
  constructor(...args) {
    if (this !== window) this.args = args
    else return args
  }
  getArgs () {
    return this.args
  }
}
console.dir(Bar)
```

![함수와 클래스 자체 비교](/assets/post-img/2022-11-08-function-keyword/constructor-obj-compare.png)

위 화면을 보면 Foo함수는 `arguments`와 `caller`가 `null`인 것을 확인할 수 있고, Bar 클래스는 `arguments`와 `caller`가 invoke되어야 결과를 확인 할 수 있으며, 리턴값은 에러를 던지고 있는것을 확인할 수 있습니다.

```js
// 엑세스 할 수 없다는 에러
arguments, caller
// TypeError: 'caller', 'callee', and 'arguments' properties may not be accessed on strict mode functions or the arguments objects for calls to them
```

Foo함수는 arguments와 caller가 그냥 출력이 되었다면, Bar 클래스는 에러를 던지고있습니다.
이 코드로 확인 가능한 것은 기존 코드들은 웬만해선 에러가 발생하지 않게 했다면 최신 문법에선 친절하게 에러를 던져주므로써 빠른 시점에 수정을 할 수 있게끔 유도하고 있습니다.


### 3. new 키워드로 생성

Foo는 함수로도 사용가능하고, 생성자함수로도 사용이 가능하지만 Bar의 경우 **new 키워드 없이 호출될 수 없습니다.**

이것을 통해 알 수 있는 사실은 명확하게 사용할 수 있다는 것입니다. 함수로는 사용하지말고 생성자함수로 사용하라는 것을 나타냅니다.

**따라서 생성자 함수를 사용할땐 class를 쓰는것이 좀 더 명확하고 확실하게 사용가능하다고 생각합니다.**

### 정리 :: class vs 생성자함수

- function 키워드를 이용해서 생성자 함수를 만들었다면 prototype의 프로퍼티가 순회 대상이되기 때문에 class를 사용하여 생성자를 구현하는 것이 효율적이다.
- class의 경우 arguments 접근시 에러가 발생시킨다. 따라서 기존 에러를 발생시키지않고 실행되던 코드를 사전에 수정할 수 있다.
- class는 new 키워드를 통해서만 생성 가능하다. 따라서 목적이 뚜렷하다.

## function 키워드의 일반 함수 문제점

일반 함수를 구현할때 새롭게 등장한 것이 `arrow function`입니다.

arrow function의 경우 '간략한 함수일 경우 작성하고 그렇지않은 경우에는 function을 쓰자'라고 하시는 분들도 있습니다. 하지만 이것을 다시 생각해볼 필요가 있습니다.

**모든 함수는 arrow function을 쓰는것이 어떨까?** 라는 주제 이야기해보겠습니다.

```js
function foo(...args) {
  console.log(args);
}

const bar = (...args) => {
  console.log(args);
}

console.dir(foo);
console.dir(bar);
```

![arrow function vs 일반 함수](/assets/post-img/2022-11-08-function-keyword/arrow-function-compare.png)

위 화면을 보면 arrow function은 arguments, caller 역시 invoke 했을때 에러를 던지는 것을 알수 있습니다.

또 foo의 경우 `prototype`이 있는데 bar의 경우 prototype이 없는것을 알 수 있습니다. 이것으로 생성자 함수로 사용가능 유무를 확인할 수 있습니다. prototype이 없는 arrow function은 생성자 함수로 사용이 불가능합니다.  
=> arrow function은 기존 일반함수보다 **더 가볍게 사용이 가능**하며, **개발 단계에서 생성자를 고려하지 않아도 된다는 장점**이 있습니다. 

마지막으로 고려해야할 부분이 this 바인딩입니다. arrow function의 경우 this binding을 하지 않습니다. 하지만 애초부터 **함수로 사용할 것을 생각했다면 this를 신경쓸 이유가 없습니다. 만약 this를 써야한다면 객체 메소드 선언 방식을 쓰면 해결됩니다.** 

따라서 this를 신경쓰지 않고 함수로써 써야 한다면 arrow function이 더 목적성에 맞는 코드라고 생각합니다.

### 정리 :: arrow function vs 일반함수

- arrow function은 arguments, caller 역시 invoke했을때 에러를 던진다.
- arrow function은 함수구현 부분에서 prototype 속성이 없기 때문에 더 가볍게 사용가능하며 생성자 함수를 고려하지 않아도된다.
- arrow function은 this 바인딩을 하지않기 때문에 this를 신경쓸 필요가 없다. 일반함수에서 this를 신경 쓸 이유가 없으며 만약 써야한다면 객체 메소드로 해결이 가능하다.

## function 키워드의 객체 메소드 문제점

객체 메소드의 경우 '메소드 축약형'으로 대체가 가능합니다.

```js
const obj1 = {
  name: '성준1',
  method: function () {
    console.log(this.name)
  }
}

const obj2 = {
  name: '성준2',
  method() {
    console.log(this.name);
  }
}

obj1.method() // 성준1
obj2.method() // 성준2
console.dir(obj1.method)
console.dir(obj2.method)
```

![객체 메소드와 메소드 축약형](/assets/post-img/2022-11-08-function-keyword/object-method.png)

메소드 축약형의 경우 arrow function과 비슷합니다.. 하지만 차이점이라면 메소드 축약형은 메소드의 목적을 가지고 있기 때문에 this 바인딩이 됩니다.

**'메소드 축약형을 사용하므로서 arrow함수처럼 가벼워졌지만 this 바인딩은 한다'라는 사실을 알 수 있습니다. 또 생성자 함수로써 사용도 불가능합니다.**

## 예외적으로 function을 써야하는 곳 :: generator

함수 형태의 generator에서만 function 키워드가 필요

```js
function* generator () {
  yield 1
  yield 2
}
console.dir(generator)

const gene = generator()
console.log(gene.next().value); // 1
console.log(gene.next().value); // 2
console.log(gene.next().value); // undefined
```

하지만 객체안의 generator는 축약형으로 사용가능

```js
const obj = {
  val: [1,2],
  *gene() {
    yield this.val.shift()
    yield this.val.shift()
  }
}

const gene = obj.gene()
console.log(gene.next().value); // 1
console.log(gene.next().value); // 2
console.log(gene.next().value); // undefined
```

## 정리

function 이라는 키워드를 반드시 쓰지마세요라는뜻은 아닙니다. function을 좋아하고 호이스팅 개념이 편리하고 좋다면 사용해도 무방합니다. 이것은 취향의 영역이기 때문입니다.

하지만 기왕이면 좀더 빠르고 목적성에 맞는 코드를 작성하는 것이 협업 코드를 작성할 때 더 좋다고 생각합니다.

---

참고

- [https://www.youtube.com/watch?v=LPEwb5plEoU](https://www.youtube.com/watch?v=LPEwb5plEoU)
- [[es2015+] class문은 특별할까?](https://www.bsidesoft.com/5370)
- [ES6 Class는 단지 prototype 상속의 문법설탕일 뿐인가?](https://roy-jung.github.io/161007_is-class-only-a-syntactic-sugar/)
- [arguments 객체 :: ES6를 사용 중이라면 나머지 매개변수를 사용해야 합니다.](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Functions/arguments)