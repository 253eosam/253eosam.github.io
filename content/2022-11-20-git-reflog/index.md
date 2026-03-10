---
title: 'git push --force로 팀 작업을 날렸을 때 살린 방법'
layout: post
category: git
tags: [git, reflog, 데이터복구, 실수복구]
description: 'git reflog를 이용하여 force push로 날아간 커밋을 복구하는 방법을 설명한다.'
---

금요일 오후 6시, 퇴근 직전에 일어난 최악의 상황이었습니다. rebase 후 `git push --force`를 잘못 실행해서 3일간의 작업이 순식간에 사라져버렸어요.

다행히 git reflog 덕분에 모든 작업을 복구할 수 있었던 경험을 공유하려고 합니다.

## 재앙의 시작: 무엇이 잘못되었나

### 실수한 상황

팀 프로젝트에서 여러 기능과 버그 수정을 병행하고 있었어요:

```bash
# 현재 브랜치: feature/user-dashboard
# 3일간 작업한 내용: 새로운 기능 구현과 기존 이슈 해결
# 총 35개 파일 수정, 커밋 12개
```

**결과:**

- rebase 후 `git push --force`로 원격 브랜치를 덮어씀
- 팀원이 같은 브랜치에서 작업한 내용까지 함께 사라짐
- 3일간의 모든 작업이 순식간에 사라짐

## 구조 작업: git reflog 활용하기

### 1단계: 현재 상황 파악

패닉 상태에서 먼저 상황을 정확히 파악했어요:

```bash
# 현재 브랜치 상태 확인
git status
# On branch feature/user-dashboard
# nothing to commit, working tree clean

# 현재 로그 확인 (당연히 내 커밋들 없음)
git log --oneline -10
# a1b2c3d (origin/main, HEAD) Latest main commit
# ...
```

### 2단계: git reflog로 잃어버린 커밋 찾기

git reflog는 HEAD의 모든 변경 이력을 추적합니다:

```bash
git reflog

# 결과 (최근 20개 항목):
a1b2c3d (HEAD -> feature/user-dashboard) HEAD@{0}: rebase: Complete user settings feature
f4e5d6c HEAD@{1}: commit: Complete user settings feature
8b9a1c2 HEAD@{2}: commit: Fix API error handling
d3f4e5a HEAD@{3}: commit: Update responsive layout
c2b1a9e HEAD@{4}: commit: Implement dashboard components
... (내가 만든 커밋들!)
```

**핵심 정보 확인:**

- `HEAD@{0}`: rebase가 완료된 현재 상태
- `HEAD@{1}`: force push로 날아가기 직전의 마지막 커밋 (`f4e5d6c`)
- 이 커밋이 3일간 작업의 최종 상태!

### 3단계: 작업 복구하기

**방법 1: 브랜치 통째로 복구**

```bash
# 잃어버린 커밋으로 브랜치를 되돌림
git reset --hard f4e5d6c

# 확인
git log --oneline -5
# f4e5d6c (HEAD -> feature/user-dashboard) Complete user settings feature
# 8b9a1c2 Fix API error handling
# d3f4e5a Update responsive layout
# c2b1a9e Implement dashboard components
# ...

# 성공! 모든 작업이 돌아옴 🎉
```

**방법 2: 새 브랜치로 백업 생성**

```bash
# 안전하게 새 브랜치 생성
git checkout -b feature/user-dashboard-recovered f4e5d6c

# 원본 브랜치 보존하면서 작업 복구
git checkout feature/user-dashboard
git merge feature/user-dashboard-recovered
```

## 다양한 복구 시나리오

### 시나리오 1: 특정 파일만 복구

전체가 아닌 특정 파일만 복구하고 싶은 경우:

```bash
# 특정 커밋에서 파일 하나만 가져오기
git show f4e5d6c:src/components/Dashboard.vue > src/components/Dashboard.vue

# 여러 파일 복구
git checkout f4e5d6c -- src/components/ src/utils/
```

### 시나리오 2: 삭제된 브랜치 복구

브랜치를 실수로 삭제한 경우:

```bash
# reflog에서 삭제된 브랜치의 마지막 커밋 찾기
git reflog --all | grep "deleted-branch"

# 해당 커밋으로 브랜치 재생성
git checkout -b recovered-branch a1b2c3d
```

### 시나리오 3: 리베이스 실패 복구

리베이스 중 충돌로 꼬인 상황:

```bash
# 리베이스 시작 전 상태로 되돌리기
git reflog
# 찾기: "rebase: checkout"이라고 표시된 항목 직전

git reset --hard HEAD@{5}  # 리베이스 시작 전 상태
```

## reflog 고급 활용법

### 유용한 reflog 옵션들

```bash
# 날짜별로 보기
git reflog --since="2 days ago"

# 특정 브랜치의 reflog
git reflog feature/user-dashboard

# 더 상세한 정보 표시
git reflog --stat

# 그래프로 보기
git reflog --graph --oneline
```

### 복구 가능한 기간

git reflog는 기본적으로 90일간 이력을 보관합니다:

```bash
# reflog 보관 기간 확인
git config gc.reflogExpire
# 기본값: 90 days

# 보관 기간 변경 (예: 180일)
git config gc.reflogExpire 180.days.ago
```
