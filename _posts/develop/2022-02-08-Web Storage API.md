---
layout: post
title: 'Web Storage API'
categories: Develop
tags: ['SessionStorage', 'LocalStorage', 'Cookie']
description: '웹 저장소'
---

Web Storage API는 브라우저에서 키/값 쌍을 쿠키보다 훨씬 직관적으로 저장할 수 있는 방법을 제공한다.

## Web Storage 개념

### SessionStorage

각각의 출처에 대해 독립적인 저장 공간을 페이지 세션이 유지되는 동안(브라우저가 열려있는 동안) 제공한다.

- 세션에 한정해, 즉 브라우저 또는 탭이 닫힐 때까지만 데이터를 저장한다.
- 데이터를 절대 서버로 전송하지 않는다.
- 저장 공간이 쿠키보다 크다. (Max 5MB)

### LocalStorage

브라우저를 닫아도 데이터가 남아있다.

- 유효기간 없이 데이터를 저장하고, JavaScript를 사용하거나 브라우저 캐시 또는 로컬 저장 데이터를 지워야만 사라집니다.
- 저장 공간이 셋 중에서 가장 크다.

위의 방식은 `Window.sessionStorage`와 `Window.localStorage` 속성을 통해 사용할 수 있다. (보다 정확하게 `Window` 객체는 `localStorage` 및 `sessionStorage` 속성을 포함한 `WindowLocalStorage`와 `WindowSessionStorage` 객체를 구현한다.) 두 속성 중 하나에 접근하면 `Storage`객체의 인스턴스를 생성하게 되고,
그걸 사용해 데이터 항목을 추가, 회수, 제거할 수 있다.

`Storage`객체는 각각의 출처별로 다른 것을 사용하며 서로 독립적으로 기능한다.

## cookie

쿠키는 브라우저에 저장되는 작은 크키의 문자열로 HTTP 프로토콜의 일부입니다.

쿠키는 주로 웹 서버에 의해 만들어집니다. 서버가 http 응답 헤더의 `Set-Cookie`에 내용을 넣어 전달하면, 브라우저는 이 내용을 자체적으로 브라우저에 저장합니다. 브라우저는 사용자가 쿠키를 생성하도록 한 동일 서버에 접속할때마다 쿠키의 내용을 `Cookie` 요청 헤더에 넣어서 함께 전달합니다.

쿠키는 클라이언트 식별과 같은 인증에 가장 많이 쓰입니다.

1. 사용자가 로그인하면 서버는 HTTP 응답 헤더의 `Set-Cookie`에 담긴 "세션 식별자(session identifier)" 정보를 사용해 쿠키를 설정합니다.
2. 사용자가 동일한 도메인에 접속하려고하면 브라우저는 HTTP `Cookie` 헤더에 인증정보가 담긴 고유값(세션 식별자)을 함께 서버에 요청합니다.
3. 서버는 브라우저가 보낸 요청 헤더의 식별자를 읽어 사용자를 식별합니다.

`document.cookie` 프로퍼티를 이용하면 브라우저에서도 쿠키에 접근할 수 있습니다.
