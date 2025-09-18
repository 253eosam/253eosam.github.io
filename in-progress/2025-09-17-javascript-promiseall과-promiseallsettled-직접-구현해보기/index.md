---
title: "API 요청 최적화하다가 Promise.all을 직접 구현해본 경험"
category: javascript
layout: post
tags: [JavaScript, Promise, 비동기, 성능최적화]
description: "여러 API를 동시에 호출해야 하는 상황에서 Promise.all의 동작 원리가 궁금해져서 직접 구현해보면서 비동기 처리의 핵심을 이해하게 된 경험을 정리했습니다."
---

프로젝트에서 사용자 대시보드를 만들면서 여러 API를 동시에 호출해야 하는 상황이 생겼습니다.

## 문제 상황: 느린 대시보드 로딩

사용자 대시보드에 표시할 데이터를 가져오는 코드가 이렇게 되어 있었어요:

```js
// 원래 코드 - 순차 실행으로 너무 느림
const loadDashboard = async () => {
  const userInfo = await fetchUserInfo();      // 500ms
  const notifications = await fetchNotifications(); // 300ms
  const statistics = await fetchStatistics();  // 700ms

  return { userInfo, notifications, statistics };
  // 총 1.5초 소요
};
```

각 API가 독립적임에도 불구하고 순차적으로 실행되어 1.5초나 걸렸습니다.

## Promise.all로 최적화 시도

```js
// Promise.all 사용 - 동시 실행
const loadDashboard = async () => {
  const [userInfo, notifications, statistics] = await Promise.all([
    fetchUserInfo(),
    fetchNotifications(),
    fetchStatistics()
  ]);

  return { userInfo, notifications, statistics };
  // 700ms로 단축 (가장 오래 걸리는 API 시간)
};
```

성능이 크게 개선되었지만, 여기서 문제가 생겼어요.

## 새로운 문제: 하나 실패하면 전체 실패

통계 API가 가끔 실패하면서 전체 대시보드가 로딩되지 않는 문제가 발생했습니다:

```js
// 통계 API 실패 시 전체 실패
try {
  const result = await Promise.all([
    fetchUserInfo(),     // 성공
    fetchNotifications(), // 성공
    fetchStatistics()    // 실패!
  ]);
} catch (error) {
  // 통계만 실패했는데 전체가 실패로 처리됨
  console.error('전체 로딩 실패:', error);
}
```

이때 Promise.allSettled가 필요하다는 걸 알게 됐지만, 정확히 어떤 차이가 있는지 궁금해서 직접 구현해보기로 했습니다.

## Promise.all 직접 구현하기

### 동작 원리 파악

Promise.all의 핵심은 다음과 같아요:
1. 모든 Promise를 동시에 시작
2. 모두 성공하면 결과를 순서대로 반환
3. 하나라도 실패하면 즉시 실패

```js
const myPromiseAll = (promises) => {
  return new Promise((resolve, reject) => {
    // 빈 배열 처리
    if (promises.length === 0) {
      return resolve([]);
    }

    const results = new Array(promises.length);
    let completedCount = 0;

    promises.forEach((promise, index) => {
      // Promise가 아닌 값도 처리 가능
      Promise.resolve(promise)
        .then(value => {
          results[index] = value; // 순서 보장
          completedCount++;

          // 모든 Promise 완료 시 resolve
          if (completedCount === promises.length) {
            resolve(results);
          }
        })
        .catch(reject); // 하나라도 실패하면 즉시 reject
    });
  });
};
```

### 실제 테스트

```js
// 성공 케이스 테스트
const testSuccess = async () => {
  const result = await myPromiseAll([
    Promise.resolve('첫 번째'),
    new Promise(resolve => setTimeout(() => resolve('두 번째'), 100)),
    '세 번째' // Promise가 아닌 값도 처리
  ]);

  console.log(result); // ['첫 번째', '두 번째', '세 번째']
};

// 실패 케이스 테스트
const testFailure = async () => {
  try {
    await myPromiseAll([
      Promise.resolve('성공'),
      Promise.reject('실패!'),
      Promise.resolve('또 성공')
    ]);
  } catch (error) {
    console.log('에러 발생:', error); // '실패!'
  }
};
```

## Promise.allSettled 구현하기

대시보드 문제를 해결하기 위해 Promise.allSettled도 구현해봤어요:

```js
const myPromiseAllSettled = (promises) => {
  return new Promise((resolve) => { // 절대 reject되지 않음
    if (promises.length === 0) {
      return resolve([]);
    }

    const results = new Array(promises.length);
    let completedCount = 0;

    const checkComplete = () => {
      if (completedCount === promises.length) {
        resolve(results);
      }
    };

    promises.forEach((promise, index) => {
      Promise.resolve(promise)
        .then(value => {
          results[index] = { status: 'fulfilled', value };
          completedCount++;
          checkComplete();
        })
        .catch(reason => {
          results[index] = { status: 'rejected', reason };
          completedCount++;
          checkComplete();
        });
    });
  });
};
```

### 대시보드에 적용

```js
const loadDashboard = async () => {
  const results = await myPromiseAllSettled([
    fetchUserInfo(),
    fetchNotifications(),
    fetchStatistics()
  ]);

  const dashboard = {};

  results.forEach((result, index) => {
    const keys = ['userInfo', 'notifications', 'statistics'];

    if (result.status === 'fulfilled') {
      dashboard[keys[index]] = result.value;
    } else {
      // 실패한 부분은 기본값 처리
      dashboard[keys[index]] = null;
      console.warn(`${keys[index]} 로딩 실패:`, result.reason);
    }
  });

  return dashboard;
};
```

이제 통계 API가 실패해도 사용자 정보와 알림은 정상적으로 표시됩니다.

## 실무에서 배운 활용 패턴

### 1. 중요도별 API 분리

```js
// 필수 API와 선택적 API 분리
const loadUserPage = async () => {
  // 필수 데이터는 Promise.all (하나라도 실패하면 에러 페이지)
  const [user, permissions] = await Promise.all([
    fetchUser(),
    fetchPermissions()
  ]);

  // 선택적 데이터는 Promise.allSettled (실패해도 기본값 처리)
  const [recentActivities, recommendations] = await Promise.allSettled([
    fetchRecentActivities(),
    fetchRecommendations()
  ]).then(results =>
    results.map(result =>
      result.status === 'fulfilled' ? result.value : null
    )
  );

  return { user, permissions, recentActivities, recommendations };
};
```

### 2. 타임아웃과 재시도 로직

```js
const withTimeout = (promise, timeout) => {
  return Promise.race([
    promise,
    new Promise((_, reject) =>
      setTimeout(() => reject(new Error('Timeout')), timeout)
    )
  ]);
};

const loadWithRetry = async () => {
  const promises = [
    withTimeout(fetchUserInfo(), 3000),
    withTimeout(fetchNotifications(), 2000),
    withTimeout(fetchStatistics(), 5000)
  ];

  return myPromiseAllSettled(promises);
};
```

### 3. 부분 성공 UI 처리

```js
const DashboardComponent = () => {
  const [dashboardData, setDashboardData] = useState({});
  const [loadingStates, setLoadingStates] = useState({});

  useEffect(() => {
    const loadData = async () => {
      const results = await myPromiseAllSettled([
        fetchUserInfo(),
        fetchNotifications(),
        fetchStatistics()
      ]);

      const data = {};
      const states = {};

      results.forEach((result, index) => {
        const key = ['userInfo', 'notifications', 'statistics'][index];

        if (result.status === 'fulfilled') {
          data[key] = result.value;
          states[key] = 'success';
        } else {
          data[key] = null;
          states[key] = 'error';
        }
      });

      setDashboardData(data);
      setLoadingStates(states);
    };

    loadData();
  }, []);

  return (
    <div>
      {loadingStates.userInfo === 'success' &&
        <UserInfoCard data={dashboardData.userInfo} />
      }
      {loadingStates.notifications === 'error' &&
        <div>알림을 불러올 수 없습니다</div>
      }
    </div>
  );
};
```

## 구현하면서 깨달은 점

### 1. forEach vs for문의 차이

처음에는 for문으로 구현했는데, forEach가 더 적합한 이유를 알게 됐어요:

```js
// for문 - 순차 실행될 수 있음
for (let i = 0; i < promises.length; i++) {
  await Promise.resolve(promises[i])... // 실수로 await 붙이면 순차 실행
}

// forEach - 각각 독립적으로 실행
promises.forEach((promise, index) => {
  Promise.resolve(promise)... // 동시 실행 보장
});
```

### 2. 인덱스 기반 결과 저장의 중요성

완료 순서와 상관없이 입력 순서를 보장하는 게 핵심이었어요:

```js
// 완료 순서: 3번째(100ms) -> 1번째(200ms) -> 2번째(300ms)
// 하지만 결과는 [1번째, 2번째, 3번째] 순서로 반환
results[index] = value; // 인덱스로 순서 보장
```

Promise.all과 Promise.allSettled를 직접 구현해보니 비동기 처리의 핵심 원리를 확실히 이해할 수 있었고, 실무에서 API 최적화할 때 더 자신있게 적용할 수 있게 되었습니다.