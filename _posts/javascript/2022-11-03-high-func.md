---
title: 고차함수
category: JavaScript
layout: post
---

## 고차함수란?

어떤 프로그래밍 언어의 함수 구현에서 함수를 인자로 넘길 수 있거나 반환할 수 있을 때 함수를 일급 객체(first-class object, 언어 내부에서 값으로 표현되고 전달될 수 있는 자료형[1])로 취급한다고 하고, 함수를 인자로 받거나 결과로 반환하는 함수를 고차함수(高次函數)라 한다. 수학의 범함수와 맥락이 비슷하다.

```js
const applyFixDiscount= (x: number) => x - 20
const applyVipOffer = (x: number) => x / 2


// 아래 방법은 효과가 있지만 더 많은 기능이 함께 구성되면 읽기가 어렵다.
const getDiscountedPrice = (x: number) => applyVipOffer(applyFixDiscount(x))
console.log(getDiscountedPrice(100)) // 40
```

```js
// 함수의 합성 (고차함수) : 매우 표현적인 방식으로 여러 연산을 구성할 수 있다.
const compose = 
    (...fns: any) => 
        (initVal: any) => 
            fns.reduceRight((val: any, fn: any) => fn(val), initVal)

const getDiscountedPrice2 = compose(applyVipOffer, applyFixDiscount)
console.log(getDiscountedPrice2(100))
```

```js
// 다른 대안 pipe
const pipe = 
    (...fns: any) => 
        (initialVal: any) => 
            fns.reduce((val: any, fn: any) => fn(val), initialVal);

const getDiscountedPrice3 = pipe(applyFixDiscount, applyVipOffer);
```

