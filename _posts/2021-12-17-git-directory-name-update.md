---
layout: post
title: 'git 대소문자 변경 추적하기'
date: 2021-12-17
categories: 'git'
tags: [git]
description: 'git commit을 올릴때 대소문자를 변경하더라도 변경사항이 추적이 안되는 경우'
---

# 📖 들어가기

git을 사용할때 파일 이름이나 디렉토리 이름을 대소문자만 바꿨을뿐인데 추적이 안되는경우가 있다.

이경우에는 `git`에서 제공하는 `mv`명령어를 이용해서 파일 이름을 변경하면된다.

```bash
$ git mv {원본 파일} {변경할 파일}
```