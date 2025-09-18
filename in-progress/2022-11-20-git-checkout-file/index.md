---
title: "실수로 파일 수정했을 때 특정 커밋에서 파일만 복구하기"
layout: post
category: git
tags: [git, checkout, file-recovery]
description: "프로젝트 진행 중 특정 파일만 이전 버전으로 되돌려야 하는 상황에서 git checkout을 활용한 파일 복구 방법을 정리했습니다. 실제 개발에서 자주 마주치는 시나리오와 함께 설명합니다."
---

코드 리뷰 중에 "이 파일만 이전 버전으로 되돌리고 싶은데"라는 말을 자주 듣게 됩니다. 전체 커밋을 되돌리기에는 다른 변경사항들이 필요한 상황에서 특정 파일만 복구하는 방법을 정리해봤습니다.

## 실제로 겪었던 상황들

### 상황 1: 설정 파일을 잘못 수정한 경우

프로덕션 배포 직전에 `package.json`의 스크립트를 수정했다가 빌드가 깨진 적이 있었어요. 다른 기능 개발은 그대로 두고 설정 파일만 이전 버전으로 되돌려야 했습니다.

```bash
# 현재 작업 브랜치에서 package.json만 main 브랜치 버전으로 복구
git checkout main package.json
```

### 상황 2: 잘못된 코드 리팩토링

여러 파일을 동시에 리팩토링하다가 한 파일에서만 문제가 발생했을 때, 해당 파일만 특정 커밋으로 되돌렸어요.

```bash
# 특정 커밋의 UserService.js 파일만 가져오기
git checkout a1b2c3d src/services/UserService.js
```

### 상황 3: 머지 충돌 해결 중 실수

머지 충돌을 해결하다가 실수로 필요한 코드를 지워버린 경우, 원본 브랜치에서 해당 파일만 다시 가져왔습니다.

```bash
# feature 브랜치의 특정 파일만 가져오기
git checkout feature/user-auth src/components/LoginForm.jsx
```

## 상황별 해결 방법

### 1. 특정 파일 완전히 교체하기

```bash
# 특정 커밋에서 파일 가져오기
git checkout <commit-id> <file-path>

# 다른 브랜치에서 파일 가져오기
git checkout <branch-name> <file-path>

# 여러 파일 동시에 가져오기
git checkout main src/config.js src/utils/helpers.js
```

**실사용 예시:**

```bash
# 최신 main 브랜치의 설정 파일들 복구
git checkout main config/database.js config/redis.js

# 3개 커밋 전의 API 파일 복구
git checkout HEAD~3 src/api/userApi.js
```

### 2. 부분적으로 선택해서 가져오기

전체 파일을 교체하는 것보다 필요한 부분만 선택하고 싶을 때 사용합니다.

```bash
# 대화형 모드로 변경사항 선택
git checkout --patch <commit-id> <file-path>
```

**실제 사용 과정:**

```bash
git checkout --patch HEAD~2 src/components/UserProfile.jsx

# Git이 각 변경사항에 대해 물어봄:
# y - 이 변경사항 적용
# n - 건너뛰기
# q - 종료
# a - 이 파일의 나머지 모든 변경사항 적용
# s - 더 작은 단위로 분할해서 선택
```

### 3. 실수했을 때 되돌리기

파일 복구 후 실수를 발견했을 때 원래 상태로 되돌리는 방법:

```bash
# Unstaged 상태라면
git checkout HEAD <file-path>

# Staged 상태라면
git reset HEAD <file-path>
git checkout HEAD <file-path>
```

## 주의사항과 팁

### 작업하기 전 확인사항

```bash
# 1. 현재 상태 확인
git status

# 2. 목표 파일의 변경 이력 확인
git log --oneline -- <file-path>

# 3. 특정 커밋에서 파일 내용 미리보기
git show <commit-id>:<file-path>
```

### 실제 개발에서 유용했던 활용법

**1. 실험적 코드 작성 후 되돌리기:**

```bash
# 새로운 기능을 시도해보다가 원래대로 되돌리고 싶을 때
git checkout HEAD~1 src/features/experimental.js
```

**2. 핫픽스 적용 시:**

```bash
# 프로덕션 브랜치의 중요한 수정사항만 현재 브랜치에 가져오기
git checkout production src/security/auth.js
```

**3. 설정 파일 동기화:**

```bash
# 팀의 최신 설정 파일들을 내 브랜치에 적용
git checkout main .env.example .gitignore package.json
```

### 실수 방지를 위한 습관

- 파일 복구 전에 `git stash`로 현재 작업 백업
- `git show`로 가져올 내용 미리 확인
- 중요한 파일은 `--patch` 옵션으로 신중하게 선택

이런 방식으로 특정 파일만 선택적으로 복구하면서 다른 작업은 그대로 유지할 수 있어서, 복잡한 프로젝트에서 매우 유용합니다.

