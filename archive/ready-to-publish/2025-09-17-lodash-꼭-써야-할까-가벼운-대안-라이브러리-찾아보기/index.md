---
title: "번들 크기 3MB에서 300KB로 줄인 lodash 최적화 경험"
date: "2025-09-17T07:46:31.356Z"
tags:
  - lodash
  - package
  - bundle-optimization
description: "프로젝트 번들 크기가 3MB를 넘어가면서 lodash를 대체하거나 최적화해야 했던 경험을 공유합니다. 실제 측정한 성능 차이와 대안 라이브러리들을 비교해봤습니다."
url: "https://velog.io/@253eosam/lodash-%EA%BC%AD-%EC%8D%A8%EC%95%BC-%ED%95%A0%EA%B9%8C-%EA%B0%80%EB%B2%BC%EC%9A%B4-%EB%8C%80%EC%95%88-%EB%9D%BC%EC%9D%B4%EB%B8%8C%EB%9F%AC%EB%A6%AC-%EC%B0%BE%EC%95%84%EB%B3%B4%EA%B8%B0"
---

회사 프로젝트에서 번들 크기가 3MB를 넘어가면서 로딩 속도 문제가 심각해졌습니다. 원인을 분석해보니 lodash 전체를 import하는 곳이 여러 군데 있었고, 실제로는 5-6개 함수만 사용하고 있었어요.

이 경험을 통해 lodash 최적화와 대안 라이브러리들을 직접 테스트해본 결과를 공유하려고 합니다.

## 프로젝트에서 발생했던 실제 문제들

### 번들 크기 분석 결과

웹팩 번들 분석기로 확인해보니 lodash가 전체 번들의 약 40%를 차지하고 있었어요.

```bash
# 실제 번들 분석 결과
Total bundle size: 3.2MB
- lodash: 1.3MB (40.6%)
- react + dependencies: 800KB (25%)
- other libraries: 1.1MB (34.4%)
```

문제는 프로젝트 전체에서 실제로 사용하는 lodash 함수가 이것들뿐이었다는 점:

```javascript
// 실제 사용 중인 lodash 함수들
import _ from 'lodash'  // 💀 전체 import

const usedFunctions = [
  '_.debounce',      // 검색 입력 디바운스
  '_.throttle',      // 스크롤 이벤트 스로틀
  '_.isEmpty',       // 객체/배열 비어있음 체크
  '_.cloneDeep',     // 폼 데이터 복사
  '_.get',          // 안전한 객체 속성 접근
  '_.groupBy'       // 데이터 그룹핑
]
```

### 성능 문제가 실제로 발생했던 케이스

**1. 렌더링 성능 이슈:**
```javascript
// 문제가 되었던 코드
function ProductList({ products }) {
  return (
    <div>
      {products.map(product => (
        <ProductItem
          key={product.id}
          product={_.cloneDeep(product)}  // 💀 매번 깊은 복사
        />
      ))}
    </div>
  )
}
```

100개 상품 렌더링할 때마다 `_.cloneDeep`이 100번 호출되면서 화면이 버벅거렸어요.

**2. 메모리 사용량 증가:**
대용량 데이터(10,000개 항목)를 `_.groupBy`로 처리할 때 메모리 사용량이 급격히 증가하는 걸 확인했습니다.

* * *

## 직접 테스트해본 대안들과 결과

### 1. lodash-es로 교체

가장 먼저 시도한 방법입니다. 기존 코드 변경을 최소화하면서 tree-shaking 효과를 볼 수 있어요.

```javascript
// Before
import _ from 'lodash'
_.debounce(handleSearch, 300)

// After
import { debounce } from 'lodash-es'
debounce(handleSearch, 300)
```

**결과:**
- 번들 크기: 3.2MB → 1.8MB (43% 감소)
- 코드 변경: 최소한 (import 구문만 수정)
- 성능: 기존과 동일

### 2. 네이티브 API + 직접 구현

자주 사용하는 함수들을 직접 구현해봤습니다.

```javascript
// debounce 직접 구현 (15줄)
function debounce(func, wait) {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout)
      func(...args)
    }
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}

// isEmpty 직접 구현 (5줄)
function isEmpty(value) {
  return value == null ||
         (Array.isArray(value) && value.length === 0) ||
         (typeof value === 'object' && Object.keys(value).length === 0)
}

// get 직접 구현 (8줄)
function get(obj, path, defaultValue) {
  const keys = path.split('.')
  let result = obj
  for (const key of keys) {
    result = result?.[key]
    if (result === undefined) return defaultValue
  }
  return result
}
```

**결과:**
- 번들 크기: 3.2MB → 1.9MB (40% 감소)
- 코드 변경: 중간 (함수 구현 + import 변경)
- 성능: 약간 향상 (특화된 구현)

### 3. just-* 라이브러리들

함수별로 개별 패키지를 사용하는 방식을 테스트해봤어요.

```bash
npm install just-debounce-it just-clone just-is-empty
```

```javascript
import debounce from 'just-debounce-it'
import clone from 'just-clone'
import isEmpty from 'just-is-empty'
```

**결과:**
- 번들 크기: 3.2MB → 1.9MB (40% 감소)
- 코드 변경: 중간 (import만 변경)
- 의존성 관리: 복잡 (여러 패키지)

### 4. Ramda 테스트

함수형 프로그래밍 스타일을 적용해봤습니다.

```javascript
import { debounce, groupBy, isEmpty, clone } from 'ramda'

// 함수 조합 예시
const processData = pipe(
  filter(item => !isEmpty(item)),
  groupBy(prop('category')),
  map(sortBy(prop('name')))
)
```

**결과:**
- 번들 크기: 3.2MB → 2.1MB (34% 감소)
- 코드 변경: 큰 변화 (함수형 스타일 적용)
- 학습 비용: 높음

### 최종 선택과 이유

결국 **lodash-es + 일부 직접 구현**을 조합해서 사용하기로 했습니다.

```javascript
// 자주 사용하는 간단한 함수는 직접 구현
import { debounce, isEmpty, get } from '../utils/helpers'

// 복잡한 함수는 lodash-es 사용
import { cloneDeep, groupBy, merge } from 'lodash-es'
```

이렇게 했을 때:
- 번들 크기: 3.2MB → 1.7MB (47% 감소)
- 개발 효율성 유지
- 팀원들 적응 비용 최소화

* * *

## 실제 적용하면서 배운 점들

### 팀 개발에서 고려해야 할 요소들

**1. 마이그레이션 비용**

전체 프로젝트에서 lodash를 한 번에 교체하는 건 현실적으로 어려웠어요. 점진적으로 접근했습니다:

```javascript
// 1단계: 새로운 기능에서만 대안 사용
// 2단계: 핫픽스나 리팩토링할 때 기존 코드도 변경
// 3단계: 사용하지 않는 lodash 함수들 정리
```

**2. 팀원들의 학습 곡선**

Ramda 같은 함수형 라이브러리는 확실히 학습 비용이 있더라고요. lodash-es가 가장 무난했습니다.

**3. 성능 측정의 중요성**

실제로 성능 테스트를 해보니 예상과 다른 결과가 많았어요:

| 작업 | lodash | 직접 구현 | lodash-es | 비고 |
|------|--------|----------|-----------|------|
| 10K 배열 debounce | 12ms | 8ms | 12ms | 직접 구현이 빠름 |
| 객체 deep clone | 45ms | 78ms | 45ms | lodash가 최적화됨 |
| 대용량 groupBy | 156ms | 298ms | 156ms | 복잡한 로직은 lodash 승 |

**4. 번들 분석의 지속적 필요성**

한 번 최적화하고 끝이 아니라, 새로운 의존성이 추가될 때마다 번들 크기를 체크하는 습관이 필요해요.

```bash
# 정기적으로 실행하는 번들 분석
npm run build
npx webpack-bundle-analyzer dist/static/js/*.js
```

### 상황별 실제 추천

| 상황 | 추천 방법 | 이유 |
|------|-----------|------|
| **기존 프로젝트 최적화** | lodash-es | 코드 변경 최소화, 빠른 적용 |
| **새 프로젝트 시작** | 직접 구현 + lodash-es 조합 | 번들 크기 최적화 |
| **함수형 프로그래밍 도입** | Ramda | 일관된 함수형 스타일 |
| **마이크로 서비스/모바일** | 직접 구현 | 최대한 가벼운 크기 |

실제로 적용해보니 "무조건 lodash를 쓰지 말자"가 아니라 "상황에 맞게 선택하자"가 정답인 것 같습니다.
