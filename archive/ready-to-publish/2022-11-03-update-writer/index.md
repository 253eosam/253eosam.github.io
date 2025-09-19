---
title: "회사 이메일로 개인 프로젝트 커밋했을 때 되돌린 방법"
category: git
layout: post
tags: [Git, GitHub, 개발환경, 협업]
description: "여러 프로젝트를 오가다 작성자 설정을 실수해서 회사 이메일로 개인 프로젝트에 커밋했던 경험과 해결 과정을 정리했습니다."
---

회사 프로젝트와 개인 프로젝트를 동시에 진행하다가 실수로 회사 이메일로 개인 GitHub에 커밋을 올린 적이 있습니다.

## 문제 상황: 잘못된 작성자로 커밋

평소 회사 프로젝트를 주로 작업하다가 집에서 개인 프로젝트를 건드리는 과정에서 이런 실수가 발생했어요:

```bash
# 개인 프로젝트에서 작업 후 커밋
git add .
git commit -m "새로운 기능 추가"
git push origin main

# GitHub에서 확인해보니...
# 커밋 작성자: company-email@company.com
# 실제로 원하는 작성자: personal-email@gmail.com
```

**문제가 된 이유:**
- GitHub 기여 그래프에 반영되지 않음
- 개인 프로젝트인데 회사 이메일로 기록됨
- 나중에 이력 관리할 때 헷갈림

GitHub에서 해당 커밋을 보니 회사 이메일 주소가 그대로 노출되어 있었고, 무엇보다 내 개인 계정의 기여 그래프에도 반영되지 않았습니다.

## 해결 과정: Interactive Rebase로 작성자 수정

### 1단계: 문제 커밋 확인

먼저 어느 커밋부터 작성자가 잘못되었는지 확인했어요:

```bash
# 최근 커밋 이력 확인
git log --oneline --author="company-email@company.com"

# 결과:
# abc1234 새로운 기능 추가
# def5678 버그 수정
# ghi9012 리팩토링 작업
```

총 3개의 커밋이 잘못된 작성자로 되어 있었습니다.

### 2단계: Interactive Rebase 시작

수정하려는 커밋들보다 하나 이전 커밋의 해시값을 찾아서 rebase를 시작했어요:

```bash
# 수정할 커밋 이전의 해시값으로 rebase 시작
git rebase -i xyz9999

# vi 편집기가 열리면서 다음과 같이 표시됨:
# pick ghi9012 리팩토링 작업
# pick def5678 버그 수정
# pick abc1234 새로운 기능 추가
```

### 3단계: 수정할 커밋 표시

3개 커밋 모두 작성자를 바꿔야 해서 `pick`을 `edit`으로 변경했어요:

```bash
edit ghi9012 리팩토링 작업
edit def5678 버그 수정
edit abc1234 새로운 기능 추가
```

저장하고 나오면 첫 번째 커밋에서 멈춰서 수정할 수 있게 됩니다.

### 4단계: 작성자 정보 수정

각 커밋마다 다음 과정을 반복했어요:

```bash
# 현재 커밋의 작성자 정보 수정
git commit --amend --author="개인이름 <personal-email@gmail.com>"

# 다음 커밋으로 넘어가기
git rebase --continue
```

총 3번 반복해서 모든 커밋의 작성자를 개인 이메일로 변경했습니다.

### 5단계: 원격 저장소에 적용

히스토리가 변경되었으므로 force push가 필요했어요:

```bash
# 변경된 커밋 히스토리를 원격에 강제 적용
git push --force-with-lease origin main
```

`--force-with-lease` 옵션을 사용해서 다른 사람의 변경사항을 실수로 덮어쓰는 일을 방지했습니다.

## 작업 결과

수정 후 확인해보니:

```bash
# 수정된 커밋 확인
git log --oneline --author="personal-email@gmail.com"

# abc1234 새로운 기능 추가
# def5678 버그 수정
# ghi9012 리팩토링 작업
```

**개선된 점들:**
- GitHub 기여 그래프에 정상 반영
- 개인 프로젝트 커밋 이력 정리
- 회사 이메일 노출 문제 해결

## 실제로 사용한 명령어 정리

```bash
# 1. 문제 커밋 확인
git log --oneline

# 2. Interactive rebase 시작 (수정할 커밋 이전 해시값 사용)
git rebase -i [이전_커밋_해시]

# 3. 편집기에서 pick → edit 변경 후 저장

# 4. 각 커밋마다 작성자 수정
git commit --amend --author="이름 <이메일>"
git rebase --continue

# 5. 원격 저장소에 강제 적용
git push --force-with-lease origin main
```

개인 프로젝트에서는 히스토리 변경이 비교적 자유롭지만, 팀 프로젝트에서는 다른 사람에게 영향을 줄 수 있으니 주의해서 사용해야 합니다.