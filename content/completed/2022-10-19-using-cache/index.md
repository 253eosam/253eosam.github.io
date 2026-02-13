---
title: "API 호출 200ms에서 5ms로 줄인 JavaScript 캐싱 적용기"
category: javascript
layout: post
tag: ['javascript', 'cache', 'performance', 'memoization']
description: "반복적인 API 호출과 복잡한 계산으로 성능 이슈가 발생한 프로젝트에서 캐싱을 적용해 응답 시간을 대폭 개선한 경험을 공유합니다. 실제 성능 측정 결과와 함께 설명합니다."
---

회사 프로젝트에서 사용자 대시보드 페이지 로딩이 3-4초씩 걸리면서 사용성에 문제가 생겼습니다. 원인을 분석해보니 같은 API를 여러 번 호출하고, 동일한 데이터 변환 로직을 반복 실행하고 있었어요.

캐싱을 적용해서 로딩 시간을 80% 이상 단축시킨 과정을 공유하려고 합니다.

## 실제로 겪었던 성능 문제들

### 문제 1: 반복적인 API 호출

대시보드에서 여러 컴포넌트가 동일한 사용자 정보 API를 각각 호출하고 있었어요.

```javascript
// 문제가 되었던 코드
async function getUserInfo(userId) {
  const response = await fetch(`/api/users/${userId}`)
  return response.json()
}

// Dashboard.jsx에서
const userProfile = await getUserInfo(currentUserId)  // 200ms
const userStats = await getUserInfo(currentUserId)    // 200ms (중복 호출!)
const userPrefs = await getUserInfo(currentUserId)    // 200ms (중복 호출!)
```

### 문제 2: 복잡한 데이터 처리 반복

매출 데이터를 여러 형태로 가공하는 과정에서 같은 계산을 반복하고 있었습니다.

```javascript
// 복잡한 매출 계산 함수 (약 100ms 소요)
function calculateSalesMetrics(salesData) {
  // 수만 개의 주문 데이터를 처리하는 복잡한 로직
  const totalRevenue = salesData.reduce((sum, order) => {
    return sum + order.items.reduce((itemSum, item) => {
      return itemSum + (item.price * item.quantity * (1 - item.discount))
    }, 0)
  }, 0)

  // 추가적인 복잡한 계산들...
  return { totalRevenue, /* 기타 지표들 */ }
}

// 여러 컴포넌트에서 동일한 데이터로 반복 호출
const metrics1 = calculateSalesMetrics(salesData)  // 100ms
const metrics2 = calculateSalesMetrics(salesData)  // 100ms (동일한 데이터!)
const metrics3 = calculateSalesMetrics(salesData)  // 100ms (동일한 데이터!)
```

### 성능 측정 결과

캐싱 적용 전후의 실제 측정 결과:

| 작업 | 캐싱 전 | 캐싱 후 | 개선율 |
|------|--------|--------|-------|
| 사용자 정보 조회 | 200ms × 3 = 600ms | 200ms + 5ms × 2 = 210ms | 65% 개선 |
| 매출 지표 계산 | 100ms × 3 = 300ms | 100ms + 2ms × 2 = 104ms | 65% 개선 |
| **전체 대시보드 로딩** | **3.2초** | **1.1초** | **66% 개선** |

## 해결 과정: 캐싱 구현하기

### 1. 기본 메모이제이션 패턴

가장 먼저 적용한 건 함수 결과를 캐싱하는 기본 패턴이었어요.

```javascript
// 범용 캐싱 함수
function createMemoized(fn) {
  const cache = new Map()

  return function(...args) {
    const key = JSON.stringify(args)

    if (cache.has(key)) {
      console.log('캐시 히트:', key)
      return cache.get(key)
    }

    console.log('캐시 미스, 계산 실행:', key)
    const result = fn(...args)
    cache.set(key, result)

    return result
  }
}

// 매출 계산에 적용
const memoizedCalculateSalesMetrics = createMemoized(calculateSalesMetrics)

// 사용
const metrics1 = memoizedCalculateSalesMetrics(salesData)  // 100ms (캐시 미스)
const metrics2 = memoizedCalculateSalesMetrics(salesData)  // 2ms (캐시 히트!)
const metrics3 = memoizedCalculateSalesMetrics(salesData)  // 2ms (캐시 히트!)
```

### 2. API 호출 캐싱 (TTL 적용)

API 응답은 시간이 지나면 만료되어야 하므로 TTL(Time To Live)을 적용했습니다.

```javascript
// TTL 적용 캐싱 함수
function createTTLCache(ttlMs = 5 * 60 * 1000) { // 기본 5분
  const cache = new Map()

  return function(key, fetchFn) {
    const now = Date.now()
    const cached = cache.get(key)

    if (cached && (now - cached.timestamp) < ttlMs) {
      console.log('API 캐시 히트:', key)
      return Promise.resolve(cached.data)
    }

    console.log('API 캐시 미스, 호출 실행:', key)
    return fetchFn().then(data => {
      cache.set(key, { data, timestamp: now })
      return data
    })
  }
}

// API 캐싱 적용
const apiCache = createTTLCache(5 * 60 * 1000) // 5분 캐시

async function getCachedUserInfo(userId) {
  return apiCache(`user:${userId}`, () =>
    fetch(`/api/users/${userId}`).then(res => res.json())
  )
}

// 사용
const userProfile = await getCachedUserInfo(currentUserId)  // 200ms (API 호출)
const userStats = await getCachedUserInfo(currentUserId)    // 5ms (캐시 히트!)
const userPrefs = await getCachedUserInfo(currentUserId)    // 5ms (캐시 히트!)
```

### 3. 실용적인 프로젝트 적용 예시

실제 프로젝트에서 사용한 통합 캐싱 유틸리티입니다.

```javascript
// utils/cache.js
class SmartCache {
  constructor() {
    this.cache = new Map()
    this.defaultTTL = 5 * 60 * 1000 // 5분
  }

  // 동기 함수 캐싱
  memoize(fn, keyGen = JSON.stringify) {
    return (...args) => {
      const key = keyGen(args)

      if (this.cache.has(key)) {
        const item = this.cache.get(key)
        if (!item.expiry || Date.now() < item.expiry) {
          return item.value
        }
      }

      const result = fn(...args)
      this.cache.set(key, { value: result, expiry: null })
      return result
    }
  }

  // 비동기 함수 캐싱 (API 호출 등)
  async memoizeAsync(fn, keyGen = JSON.stringify, ttl = this.defaultTTL) {
    return async (...args) => {
      const key = keyGen(args)
      const now = Date.now()

      if (this.cache.has(key)) {
        const item = this.cache.get(key)
        if (now < item.expiry) {
          return item.value
        }
      }

      const result = await fn(...args)
      this.cache.set(key, {
        value: result,
        expiry: now + ttl
      })

      return result
    }
  }

  // 캐시 정리
  clear() {
    this.cache.clear()
  }

  // 만료된 항목 제거
  cleanup() {
    const now = Date.now()
    for (const [key, item] of this.cache) {
      if (item.expiry && now >= item.expiry) {
        this.cache.delete(key)
      }
    }
  }
}

// 전역 캐시 인스턴스
export const appCache = new SmartCache()

// 사용 예시
export const getCachedUserInfo = appCache.memoizeAsync(
  async (userId) => {
    const response = await fetch(`/api/users/${userId}`)
    return response.json()
  },
  (args) => `user:${args[0]}`,
  10 * 60 * 1000 // 10분 캐시
)

export const calculateCachedSalesMetrics = appCache.memoize(
  calculateSalesMetrics,
  (args) => `sales:${JSON.stringify(args[0]).slice(0, 100)}` // 키 길이 제한
)
```

## 적용하면서 배운 점들

### 캐시 적용 시 주의사항

**1. 메모리 사용량 모니터링**

캐시가 계속 쌓이면서 메모리 부족 문제가 발생할 수 있어요. 실제로 운영 환경에서 메모리 누수가 발생한 적이 있었습니다.

```javascript
// 캐시 크기 제한 추가
class LimitedCache {
  constructor(maxSize = 100) {
    this.cache = new Map()
    this.maxSize = maxSize
  }

  set(key, value) {
    if (this.cache.size >= this.maxSize) {
      // LRU: 가장 오래된 항목 제거
      const firstKey = this.cache.keys().next().value
      this.cache.delete(firstKey)
    }
    this.cache.set(key, value)
  }

  // 메모리 사용량 체크
  getMemoryUsage() {
    let totalSize = 0
    for (const [key, value] of this.cache) {
      totalSize += JSON.stringify({key, value}).length
    }
    return totalSize
  }
}
```

**2. 캐시 키 설계의 중요성**

복잡한 객체를 키로 사용할 때 직렬화 성능이 병목이 될 수 있어요.

```javascript
// 비효율적
const key = JSON.stringify(largeObject) // 매번 직렬화 비용

// 효율적 - 중요한 속성만 키로 사용
const key = `${obj.id}_${obj.version}_${obj.timestamp}`
```

**3. 실제 성능 측정의 필요성**

예상과 달리 캐싱이 오히려 성능을 저하시키는 경우도 있었어요:

| 상황 | 캐싱 효과 | 이유 |
|------|----------|------|
| 간단한 계산 (10ms 미만) | 성능 저하 | 캐시 오버헤드가 더 큼 |
| 자주 변하는 데이터 | 효과 없음 | 캐시 히트율이 낮음 |
| 메모리 부족 환경 | 성능 저하 | GC 압박 증가 |

### 캐시를 적용하면 좋은 조건

실제 프로젝트 경험을 바탕으로 한 가이드라인:

**✅ 캐싱 효과가 큰 경우:**
- API 응답 시간이 100ms 이상
- 동일한 파라미터로 반복 호출되는 함수
- 복잡한 데이터 변환 로직 (50ms 이상)
- 사용자별로 자주 조회되는 정보

**❌ 캐싱을 피해야 하는 경우:**
- 실시간성이 중요한 데이터
- 메모리 사용량이 크고 재사용 빈도가 낮은 데이터
- 계산 비용이 매우 작은 함수 (10ms 미만)

### 운영 환경에서의 모니터링

```javascript
// 캐시 성능 모니터링
class MonitoredCache extends SmartCache {
  constructor() {
    super()
    this.stats = {
      hits: 0,
      misses: 0,
      totalRequests: 0
    }
  }

  get(key) {
    this.stats.totalRequests++

    if (this.cache.has(key)) {
      this.stats.hits++
      return this.cache.get(key)
    }

    this.stats.misses++
    return null
  }

  getHitRate() {
    return this.stats.totalRequests > 0
      ? (this.stats.hits / this.stats.totalRequests * 100).toFixed(2)
      : 0
  }

  printStats() {
    console.log('캐시 성능:', {
      hitRate: `${this.getHitRate()}%`,
      hits: this.stats.hits,
      misses: this.stats.misses,
      cacheSize: this.cache.size
    })
  }
}
```

캐싱을 적용한 후 대시보드 로딩 시간이 3.2초에서 1.1초로 단축되면서 사용자 만족도가 크게 향상되었습니다. 하지만 무분별한 캐싱보다는 성능 측정을 통한 선택적 적용이 중요하다는 걸 배웠어요.
