---
layout: post
title: '[WEB] PRG 패턴'
date: 2021-01-29
categories: Web
tags: [Web]
description: '[WEB] PRG(POST-Redirect-GET) pattern'
---

# PRG (POST-Redirect-GET) 패턴이란?

PRG 패턴은 웹 개발 시에 권장되는 디자인 패턴 중 하나로, **HTTP POST 요청에 대한 응답이 또 다른 URL로의 GET 요청을 위한 리다이렉트(응답 코드가 3xx)여야 한다는 것**을 의마한다. 즉, 일반적인 HTTP GET 요청처럼 HTTP POST 요청에 대한 응답이 어떠한 페이지를 직접 반환하는 것은 권장되지 않는 위험한 방식이라는 것이다.

<br>

# PRG 패턴의 필요성

PRG 패턴을 사용하지 않는다면, 대표적으로 다음과 같은 두가지 문제점이 발생할 수 있다.

## 새로고침으로 인해 동일한 HTTP POST 요청이 중복으로 발생하여 의도치 않은 결과를 낳을 수 있다.

만약 HTTP POST 요청에 대한 응답이 단순히 어떠한 페이지를 직접 반환하는 것이라면, 이후 새로고침을 시도했을 때 방금 전 HTTP POST 요청이 그대로 다시 서버에 전송된다. 이는 의도치 않은 결과를 낳을 수 있다.
예를 들어, 온라인 물품 구매 후 새로고침을 하면 중복 구매가 이뤄질 수 있다.

## HTTP POST 요청의 결과에 해당하는 페이지를 북마크하거나 다른 ƒ사람과 공유하는 것이 어려워진다.

북마크(즐겨찾기)는 특정 HTTP 요청의 URL만을 저장하고, 다른 사람에게 해당 페이지를 공유할 때도 오로지 URL만을 공유한다. 
기본적으로 사용자는 URL만 가지고는 HTTP GET 요청밖에 할 수 없기 때문에, 이는 의도와 다른 페이지로 이동하는 결과를 낳게 된다. 그러나 만약 PRG 패턴을 따른다면 HTTP POST 요청에 대한 응답을 받자 마자 다시 특정 URL로의 HTTP GET 요청을 전송하기 때문에, 해당 URL을 북마크하거나 다른 사람과 공유하는 것이 가능해진다.

**⬇️ PRG 패턴을 사용하지 않을 때**
![prg 패턴 사용 안했을때 구조](https://upload.wikimedia.org/wikipedia/commons/f/f3/PostRedirectGet_DoubleSubmitProblem.png)

**⬇ PRG 패턴을 사용할 때(권장)**
![prg 패턴 사용 했을때 구조](https://upload.wikimedia.org/wikipedia/commons/3/3c/PostRedirectGet_DoubleSubmitSolution.png)

> 참고 
> <ul>
    <li><a href="https://it-eldorado.tistory.com/68">https://it-eldorado.tistory.com/68</a></li>
    <li><a href="https://en.wikipedia.org/wiki/Post/Redirect/Get">https://en.wikipedia.org/wiki/Post/Redirect/Get</a></li>
> </ul>