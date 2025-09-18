---
title: "JavaScript에서 숫자를 이진법으로 변환하고 다시 10진법으로 변환하는 방법"
date: "2025-09-17T07:46:38.019Z"
tags:
  - JavaScript
  - algorithm
description: "JavaScript에서는 Number 객체의 toString() 메서드를 이용하면 손쉽게 숫자를 다양한 진법으로 변환할 수 있습니다. 이번 글에서는 10진수를 이진법(2진수)로 변환하고 다시 10진수로 되돌리는 방법을 알아보겠습니다.toString(radix) 메서드를"
url: "https://velog.io/@253eosam/JavaScript%EC%97%90%EC%84%9C-%EC%88%AB%EC%9E%90%EB%A5%BC-%EC%9D%B4%EC%A7%84%EB%B2%95%EC%9C%BC%EB%A1%9C-%EB%B3%80%ED%99%98%ED%95%98%EA%B3%A0-%EB%8B%A4%EC%8B%9C-10%EC%A7%84%EB%B2%95%EC%9C%BC%EB%A1%9C-%EB%B3%80%ED%99%98%ED%95%98%EB%8A%94-%EB%B0%A9%EB%B2%95"
---

JavaScript에서는 `Number` 객체의 `toString()` 메서드를 이용하면 손쉽게 숫자를 다양한 진법으로 변환할 수 있습니다. 이번 글에서는 10진수를 이진법(2진수)로 변환하고 다시 10진수로 되돌리는 방법을 알아보겠습니다.

* * *

## 1\. 10진수를 2진수로 변환하기

`toString(radix)` 메서드를 사용하면 숫자를 원하는 진법으로 변환할 수 있습니다. 이때, `radix` 값으로 `2`를 넣으면 2진수 문자열로 변환됩니다.

### 예제 코드:

```jsx
const decimalNumber = 42;
const binaryString = decimalNumber.toString(2);
console.log(binaryString); // "101010"
```

위 코드에서 `42.toString(2)`를 실행하면 `"101010"`이라는 문자열이 출력됩니다. 즉, 10진수 42는 2진수로 `101010`입니다.

* * *

## 2\. 2진수를 다시 10진수로 변환하기

이진 문자열을 10진수로 변환하려면 `parseInt(string, radix)` 함수를 사용합니다. 여기서 `string`은 변환할 문자열, `radix`는 현재의 진법을 의미합니다.

### 예제 코드:

```jsx
const binaryString = "101010";
const decimalNumber = parseInt(binaryString, 2);
console.log(decimalNumber); // 42
```

위 코드에서 `parseInt("101010", 2)`를 실행하면 10진수 `42`가 반환됩니다.

* * *

## 3\. 활용 예제: 숫자 변환 함수 만들기

다음은 10진수를 2진수로 변환하고 다시 10진수로 변환하는 간단한 함수를 만들어보겠습니다.

```jsx
function decimalToBinary(decimal) {
    return decimal.toString(2);
}

function binaryToDecimal(binary) {
    return parseInt(binary, 2);
}

// 테스트
const decimal = 42;
const binary = decimalToBinary(decimal);
console.log(`10진수 ${decimal} → 2진수 ${binary}`);

const recoveredDecimal = binaryToDecimal(binary);
console.log(`2진수 ${binary} → 10진수 ${recoveredDecimal}`);
```

출력 결과:

```null
10진수 42 → 2진수 101010
2진수 101010 → 10진수 42
```

* * *

## 4\. [Codility의 BinaryGap 문제](https://app.codility.com/programmers/lessons/1-iterations/binary_gap/)

### 🔹 BinaryGap 문제란?

Codility의 BinaryGap 문제는 정수를 이진수로 변환했을 때, `1`과 `1` 사이에 존재하는 가장 긴 `0`의 연속된 개수를 찾는 문제입니다.  
예를 들어, `9 (1001)`의 경우 최대 `0`의 연속 길이는 `2`이고, `529 (1000010001)`의 경우 최대 길이는 `4`입니다.

### 🔹 해결 코드

아래 코드는 주어진 정수 `N`을 2진수 문자열로 변환한 후, `1`과 `1` 사이의 `0`의 개수를 계산하는 방식으로 동작합니다.

```tsx
function solution(N: number): number {
    let answer = 0;
    const binary = N.toString(2);

    for (let i = 0; i < binary.length; i++) {
        if (binary[i] === '0') continue;
        for (let j = i + 1; j < binary.length; j++) {
            console.log(i, j);
            if (binary[j] === '1') {
                answer = Math.max(answer, j - i - 1);
                i = j - 1;
                break;
            }
        }
    }

    return answer;
}
```

### 🔹 코드 설명

1.  `N.toString(2)`를 사용하여 2진수 문자열로 변환합니다.
2.  이진 문자열을 순회하며 `1`과 `1` 사이의 `0`의 개수를 확인합니다.
3.  `Math.max(answer, j - i - 1)`를 사용해 가장 긴 Binary Gap을 찾습니다.
4.  `i = j - 1`로 갱신하여 중복 탐색을 방지합니다.

* * *

## 5\. 주의할 점

1.  **`toString(2)`의 반환값은 문자열**입니다. 숫자로 사용하려면 `parseInt()`를 이용해 변환해야 합니다.
2.  **음수 변환 시 주의**: `toString(2)`는 음수를 변환할 때 부호 비트를 포함하지 않으므로, 음수를 표현하려면 다른 방식(예: `Math.abs()` 사용)을 고려해야 합니다.

```jsx
console.log((-42).toString(2)); // "-101010"
```

* * *

## 6\. 결론

JavaScript에서 `toString(2)`를 사용하면 쉽게 10진수를 2진수로 변환할 수 있으며, `parseInt(string, 2)`를 사용하면 다시 10진수로 변환할 수 있습니다. 또한, Codility의 BinaryGap 문제를 해결할 때도 이러한 변환을 활용할 수 있습니다.