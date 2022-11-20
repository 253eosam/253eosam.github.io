---
title: git reflog - 지워진 커밋, 파일 회복하기 
layout: post
category: git
tags: [git, reflog]
---

## 📘 들어가며

git을 사용도중 rebase, reset을 통해 커밋이 삭제되는 일이 생길 수 있습니다.
이럴경우 git log에 확인하고 복구하는 벙법이있다.

## git reflog

```bash
git reflog
```

`git reflog` 명령어를 통해 log를 확인하고 원하는 commit id를 확인 후 `git reset --hard <commit id>` 를 실행하여 복구한다.

### branch 복구

`git checkout -b <삭제한 브랜치명> <커밋id>`
