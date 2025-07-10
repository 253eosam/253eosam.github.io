---
title: git checkout 커밋 파일명 - 커밋의 파일 가져오기
layout: post
category: git
tags: [git, checkout]
---

## 📘 들어가며

Git에서 원하는 파일 변경을 가져오려면 어떻게 해야할까?

## 해결책

### 원하는 파일 가져오기 (덮어쓰기)

```bash
git checkout <commit id> <file path>
git checkout <branch> <file path>
```

### 원하는 파일 가져오기 (안덮어쓰기)

```bash
git checkout --patch <commit id> <file path>
```
