# 워크플로우 관리 가이드

## 컨텐츠 개선 워크플로우

```
content/posts/ → [개선 작업] → in-progress/ → archive/ready-to-publish/ → archive/published/
```

## 단계별 작업 방법

### 1단계: 개선 작업 (content/posts/)
```bash
# 1. 다음 포스트 선택
find content/posts -name "index.md" | head -5

# 2. 개선 방법론 적용 (CLAUDE.md 참고)
# - 흥미 요소 추가 (제목, 도입부)
# - 글 톤 개선 (경험 공유 톤)
# - 신뢰성 확보 (과장 제거, 현실적 데이터)
# - 실용성 강화 (실제 설정, 문제 해결 과정)
# - 구조 개선 (표 수정, 논리적 흐름)
```

### 2단계: in-progress로 이동
```bash
# 개선 완료된 글을 in-progress로 이동
mv content/posts/category/post-name in-progress/

# 상태 파일 업데이트
# CONTENT-IMPROVEMENT-STATUS.md 수정
```

### 3단계: archive로 이동 (향후)
```bash
# 추가 검토 완료 후 archive로 이동
./tools/move-to-archive.sh "post-name" 8.5
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