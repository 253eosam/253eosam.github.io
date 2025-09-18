---
title: "웹 저장소 선택하기: 쿠키 vs localStorage vs sessionStorage 실무 경험"
category: frontend
layout: post
tags: [웹저장소, localStorage, sessionStorage, Cookie, 브라우저저장소]
description: "프로젝트에서 사용자 데이터를 저장해야 할 때마다 고민되는 쿠키, localStorage, sessionStorage의 차이점과 실제 사용 사례를 경험을 바탕으로 정리했습니다."
---

웹 개발하면서 사용자 데이터를 브라우저에 저장해야 하는 상황이 자주 생깁니다. 쿠키, localStorage, sessionStorage 중 어떤 걸 써야 할지 항상 고민이었는데, 실제 프로젝트에서 사용해본 경험을 정리해봤어요.

## 실제 프로젝트에서 마주친 상황들

### 상황 1: 사용자 로그인 정보 저장

**요구사항**: 로그인한 사용자가 브라우저를 닫았다 열어도 로그인 상태 유지

```javascript
// 처음 시도: localStorage 사용
localStorage.setItem('accessToken', token);

// 문제 발생: XSS 공격에 취약
// 해결: httpOnly 쿠키 사용
// 서버에서 Set-Cookie: accessToken=abc123; HttpOnly; Secure; SameSite=Strict
```

**선택한 방법**: **httpOnly 쿠키**
- 이유: JavaScript로 접근 불가능해서 XSS 공격 방지
- 서버에서 자동으로 요청에 포함됨

### 상황 2: 사용자 설정 저장

**요구사항**: 다크모드, 언어 설정 등 사용자 개인화 설정

```javascript
// 사용자 설정 저장
const userSettings = {
  theme: 'dark',
  language: 'ko',
  fontSize: 'medium'
};

localStorage.setItem('userSettings', JSON.stringify(userSettings));

// 페이지 로드시 설정 복원
const savedSettings = JSON.parse(localStorage.getItem('userSettings') || '{}');
```

**선택한 방법**: **localStorage**
- 이유: 브라우저 재시작 후에도 설정 유지 필요
- 보안에 민감하지 않은 데이터

### 상황 3: 폼 임시 저장

**요구사항**: 사용자가 긴 폼을 작성하다가 실수로 페이지를 닫아도 내용 보존

```javascript
// 폼 입력시마다 저장
const formData = {
  title: document.getElementById('title').value,
  content: document.getElementById('content').value,
  category: document.getElementById('category').value
};

sessionStorage.setItem('draftPost', JSON.stringify(formData));

// 페이지 로드시 복원
window.addEventListener('load', () => {
  const draft = sessionStorage.getItem('draftPost');
  if (draft) {
    const data = JSON.parse(draft);
    document.getElementById('title').value = data.title || '';
    document.getElementById('content').value = data.content || '';
    document.getElementById('category').value = data.category || '';
  }
});
```

**선택한 방법**: **sessionStorage**
- 이유: 탭 단위로 독립적 저장, 브라우저 종료시 자동 삭제
- 임시 데이터에 적합

## 각 저장소의 실제 특성 비교

### 용량 제한 테스트

실제로 각 저장소의 용량을 테스트해본 결과:

```javascript
// 저장소 용량 테스트 함수
function testStorageLimit(storage, name) {
  let data = 'a';
  let totalSize = 0;

  try {
    while (true) {
      storage.setItem('test', data);
      totalSize = data.length;
      data += data; // 데이터를 두 배로 늘림
    }
  } catch (e) {
    console.log(`${name} 최대 용량: 약 ${Math.round(totalSize / 1024 / 1024)}MB`);
    storage.removeItem('test');
  }
}

// 결과 (Chrome 기준)
// localStorage: 약 10MB
// sessionStorage: 약 10MB
// 쿠키: 4KB per domain
```

### 성능 테스트

```javascript
// 성능 비교 테스트
function performanceTest() {
  const testData = JSON.stringify({data: 'test'.repeat(1000)});
  const iterations = 1000;

  // localStorage 테스트
  console.time('localStorage');
  for (let i = 0; i < iterations; i++) {
    localStorage.setItem(`test${i}`, testData);
    localStorage.getItem(`test${i}`);
  }
  console.timeEnd('localStorage'); // 약 20ms

  // sessionStorage 테스트
  console.time('sessionStorage');
  for (let i = 0; i < iterations; i++) {
    sessionStorage.setItem(`test${i}`, testData);
    sessionStorage.getItem(`test${i}`);
  }
  console.timeEnd('sessionStorage'); // 약 25ms
}
```

## 실무에서 자주 사용하는 패턴

### 1. 안전한 localStorage 래퍼

```javascript
class SafeStorage {
  static set(key, value) {
    try {
      const serialized = JSON.stringify(value);
      localStorage.setItem(key, serialized);
      return true;
    } catch (error) {
      console.error('Storage set failed:', error);
      return false;
    }
  }

  static get(key, defaultValue = null) {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : defaultValue;
    } catch (error) {
      console.error('Storage get failed:', error);
      return defaultValue;
    }
  }

  static remove(key) {
    try {
      localStorage.removeItem(key);
      return true;
    } catch (error) {
      console.error('Storage remove failed:', error);
      return false;
    }
  }
}

// 사용 예시
SafeStorage.set('userSettings', {theme: 'dark'});
const settings = SafeStorage.get('userSettings', {theme: 'light'});
```

### 2. 만료 시간이 있는 localStorage

```javascript
class ExpiringStorage {
  static set(key, value, expirationMinutes) {
    const expirationTime = new Date().getTime() + (expirationMinutes * 60 * 1000);
    const item = {
      value: value,
      expiration: expirationTime
    };
    localStorage.setItem(key, JSON.stringify(item));
  }

  static get(key) {
    const itemStr = localStorage.getItem(key);
    if (!itemStr) return null;

    const item = JSON.parse(itemStr);
    const now = new Date().getTime();

    if (now > item.expiration) {
      localStorage.removeItem(key);
      return null;
    }

    return item.value;
  }
}

// 사용 예시: 30분 후 만료되는 캐시
ExpiringStorage.set('apiCache', responseData, 30);
```

### 3. 스토리지 이벤트 활용

```javascript
// 다른 탭과 동기화
window.addEventListener('storage', (e) => {
  if (e.key === 'userSettings') {
    // 다른 탭에서 설정이 변경됨
    const newSettings = JSON.parse(e.newValue);
    updateUI(newSettings);
  }
});

// 로그아웃 시 다른 탭도 함께 로그아웃
function logout() {
  localStorage.removeItem('accessToken');
  // storage 이벤트가 발생하여 다른 탭들도 반응
}
```

## 보안 고려사항

### 민감한 데이터 저장 금지

```javascript
// ❌ 절대 하지 말 것
localStorage.setItem('password', userPassword);
localStorage.setItem('creditCard', cardNumber);
localStorage.setItem('ssn', socialSecurityNumber);

// ✅ 안전한 데이터만 저장
localStorage.setItem('theme', 'dark');
localStorage.setItem('language', 'ko');
localStorage.setItem('lastViewedPage', '/dashboard');
```

### XSS 공격 대비

```javascript
// ❌ 사용자 입력을 그대로 저장
const userInput = document.getElementById('search').value;
localStorage.setItem('lastSearch', userInput);

// ✅ 입력값 검증 후 저장
function sanitizeInput(input) {
  return input.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
}

const sanitizedInput = sanitizeInput(userInput);
localStorage.setItem('lastSearch', sanitizedInput);
```

## 상황별 선택 가이드

### 언제 쿠키를 사용할까?

```javascript
// 1. 서버에서 자동으로 처리해야 하는 데이터
// 2. 보안이 중요한 데이터 (httpOnly)
// 3. 만료 시간이 필요한 데이터

// 예시: 인증 토큰
// Set-Cookie: token=abc123; HttpOnly; Secure; SameSite=Strict; Max-Age=3600
```

### 언제 localStorage를 사용할까?

```javascript
// 1. 브라우저 재시작 후에도 유지되어야 하는 데이터
// 2. 보안에 민감하지 않은 사용자 설정
// 3. 오프라인에서도 접근해야 하는 데이터

const userPreferences = {
  theme: 'dark',
  language: 'ko',
  notifications: true
};
localStorage.setItem('preferences', JSON.stringify(userPreferences));
```

### 언제 sessionStorage를 사용할까?

```javascript
// 1. 탭별로 독립적이어야 하는 데이터
// 2. 브라우저 종료시 삭제되어야 하는 임시 데이터
// 3. 폼 작성 중 임시 저장

// 예시: 쇼핑몰 임시 장바구니
const tempCart = {
  items: [
    {id: 1, name: '상품1', quantity: 2},
    {id: 2, name: '상품2', quantity: 1}
  ]
};
sessionStorage.setItem('tempCart', JSON.stringify(tempCart));
```

웹 저장소 선택은 데이터의 성격과 보안 요구사항을 고려해서 결정하는 게 가장 중요합니다. 특히 사용자 인증과 관련된 민감한 데이터는 반드시 적절한 보안 조치가 필요해요.