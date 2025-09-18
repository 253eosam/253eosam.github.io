# 워크플로우 관리 가이드

## 컨텐츠 워크플로우

### 기존 컨텐츠 개선
```
content/posts/ → [rewrite] → in-progress/ → [approve] → archive/ready-to-publish/ → archive/published/
```

### 신규 컨텐츠 생성
```
drafts/ → [make] → archive/ready-to-publish/ → [필요시 개선] → in-progress/ → [approve] → archive/ready-to-publish/
```

## 단계별 작업 방법

## 디렉토리별 역할

### `/drafts/` - 토픽 정보 제공 레이어
- 사용자가 작성할 토픽과 방향성 정의
- AI에게 컨텐츠 생성 정보 제공
- **make** 명령으로 초안 생성

### `/in-progress/` - 협업 작업 공간
- AI와 사용자가 함께 컨텐츠 개선
- **rewrite** 대상 파일들
- 반복적 개선 작업 진행

### `/archive/ready-to-publish/` - 완성된 컨텐츠
- **approve** 된 고품질 컨텐츠
- **make**로 생성된 초안 보관
- 발행 준비 완료 상태

### `/archive/published/` - 발행 완료
- 실제 블로그에 발행된 글들

## 명령어별 동작

### **rewrite** 명령
```bash
# content/posts/ 또는 기타 위치 → in-progress/
mv content/posts/category/post-name in-progress/
```

### **approve** 명령
```bash
# in-progress/ → archive/ready-to-publish/
mv in-progress/post-name archive/ready-to-publish/
```

### **make** 명령 (drafts 기반)
```bash
# drafts/topic-name → archive/ready-to-publish/로 초안 생성
# 필요시 추가 개선은 in-progress/에서 진행
```

## 현재 작업 상황

### ✅ 완료된 작업 (2025-09-18)
- **개선 방법론 완성**: CLAUDE.md에 5가지 핵심 영역 정립
- **샘플 개선 완료**: Turbopack, SWC 글 개선
- **워크플로우 구축**: in-progress 디렉토리 생성 및 이동

### 📋 현재 in-progress 상태
1. `2025-09-17-turbopack-vite-yarn-berry-호환성-정리` (개선 완료)
2. `2025-09-17-swc` (개선 완료)
3. `2025-09-17-vite-typescript-프로젝트-모듈-경로-aliasing` (개선 완료)
4. `2025-09-17-lodash-꼭-써야-할까-가벼운-대안-라이브러리-찾아보기` (개선 완료)
5. `2022-11-20-git-checkout-file` (개선 완료)
6. `2022-10-19-using-cache` (개선 완료)
7. `2022-10-20-detail-setting` (개선 완료)
8. `2022-11-20-git-reflog` (개선 완료)
9. `2022-11-03-update-writer` (개선 완료)
10. `2022-11-18-package-prefix` (개선 완료)

### ✅ Dev-tools 카테고리 완료
**총 6개 포스트 처리 완료**
- 5개 포스트 개선 및 in-progress 이동
- 1개 포스트 삭제 (사용자 요청)

### 🔄 다음 작업 대상
**Frontend 카테고리 (38개)**
- 다음 세션에서 frontend 카테고리 시작

## 작업 재개 방법

```bash
# 1. 현재 상태 확인
cat CONTENT-IMPROVEMENT-STATUS.md

# 2. 다음 포스트 확인
find content/posts/dev-tools -name "index.md" | head -3

# 3. 개선 방법론 참고
cat CLAUDE.md | grep -A 20 "블로그 글 개선 방법론"

# 4. 개선 완료 후 이동
mv content/posts/dev-tools/post-name in-progress/

# 5. 상태 파일 업데이트
# CONTENT-IMPROVEMENT-STATUS.md 수정
```

## 진행률 추적

- **전체**: 59개 포스트
- **완료**: 10개 (16.9%)
- **in-progress**: 10개
- **남은 작업**: 49개
  - dev-tools: 0개 (완료)
  - frontend: 38개
  - infrastructure: 6개
  - patterns: 7개

---

**마지막 업데이트**: 2025-09-18
**다음 세션 작업**: frontend 카테고리 시작