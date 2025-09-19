# Claude 기반 컨텐츠 생성 워크플로우

이 프로젝트는 Claude를 활용하여 높은 퀄리티의 블로그 컨텐츠를 생성하는 공간입니다. draft template을 통해 체계적으로 글을 기획하고, AI 대화를 통해 품질을 개선하여 최종적으로 블로그에 발행할 수 있는 완성된 컨텐츠를 생산합니다.

## 목적

- Claude 기반 고품질 컨텐츠 생성
- Draft template을 통한 체계적 글 기획
- 대화형 방식으로 글의 품질 지속 개선
- 완성된 컨텐츠의 체계적 관리 및 아카이브
- 블로그 발행을 위한 최종 컨텐츠 준비

## 빠른 시작

### 자동화 스크립트 사용법

프로젝트에서 실제로 사용하는 3개의 핵심 스크립트입니다:

#### 새 draft 생성
```bash
./tools/create-new-draft.sh "토픽명"
# 예: ./tools/create-new-draft.sh "React 18 새로운 기능들"
```

#### 작업 시작 (draft → in-progress)
```bash
./tools/move-to-progress.sh "폴더명"
# 예: ./tools/move-to-progress.sh "2025-09-19-react-18-새로운-기능들"
```

#### 완성 후 아카이브 (in-progress → archive)
```bash
./tools/move-to-archive.sh "폴더명" [품질점수]
# 예: ./tools/move-to-archive.sh "2025-09-19-react-18-새로운-기능들" 8.5
```

모든 스크립트는 프로젝트 루트에서 실행해야 합니다.

## 워크플로우 및 폴더 구조

### 신규 컨텐츠 생성 플로우

1. **Draft Template 생성 및 작성**
   - `drafts/templates/draft-template.md` 사용하여 새로운 draft 생성
   - `drafts/[topic-name]/` 폴더에 토픽별 draft 작성
   - 토픽, 목차, 글의 컨셉, 타겟 독자, 목적 상세 정의

2. **make content 명령 실행**
   - **make content** 명령으로 Draft 기반 초안 생성
   - 사용된 Draft → `archive/used-draft/`로 자동 이동
   - 생성된 초안 → `in-progress/`에 배치

3. **Claude AI와 대화형 고도화**
   - `in-progress/`에서 Claude AI와 협업
   - 대화를 통한 반복적 품질 개선
   - 구조, 내용, 문체, 실용성 최적화
   - **이미지 시스템 구축**:
     - 글 내용에 전략적 이미지 플레이스홀더 삽입
     - `/images/image-generation-prompts.md` 파일에 상세한 AI 이미지 생성 프롬프트 작성
     - 각 이미지별 용도, 위치, 생성 프롬프트, 대체 텍스트 포함
     - 일관된 스타일 가이드 및 기술적 요구사항 정의

4. **approve로 완성 확정**
   - **approve** 명령으로 `archive/ready-to-publish/`로 이동
   - 메타태그 `status: ready-to-publish` 설정
   - 최종 검토 및 메타데이터 완성

5. **발행 및 상태 관리**
   - 사용자가 실제 블로그에 발행
   - 메타태그 `status: published`로 업데이트
   - `archive/published/`로 이동 (선택사항)

### 폴더 구조

```
/
├── drafts/                    # Draft 작성 영역
│   ├── templates/            # Draft 템플릿
│   │   └── draft-template.md # 기본 draft 템플릿
│   └── [topic-name]/         # 토픽별 draft 폴더
├── in-progress/              # AI ↔ 사용자 협업 작업 공간
├── archive/                  # 완성된 고품질 컨텐츠
│   ├── used-draft/          # 사용된 draft 보관
│   ├── ready-to-publish/     # 발행 준비된 완성 글
│   └── published/            # 발행 완료된 글
├── content/posts/            # 기존 컨텐츠 (개선 대상)
└── tools/                   # 자동화 스크립트
```

### 컨텐츠 워크플로우

#### 기존 컨텐츠 개선
```
content/posts/ → [rewrite] → in-progress/ → [approve] → archive/ready-to-publish/ → archive/published/
```

#### 신규 컨텐츠 생성
```
1. Draft Template 생성 → drafts/
2. Draft 작성 완료
3. [make content] → drafts/ 이동 → archive/used-draft/ + 초안 생성 → in-progress/
4. in-progress/에서 Claude AI와 대화형 고도화 작업
5. [approve] → in-progress/ → archive/ready-to-publish/
6. 메타태그로 publish 상태 체크 → archive/published/
```

## 글 작성 가이드라인

### Draft Template 작성 가이드

1. **토픽 정의**
   - 명확하고 구체적인 주제 설정
   - 타겟 독자 명시
   - 글의 목적과 가치 정의

2. **목차 구성**
   - 논리적 흐름 구성
   - 섹션별 핵심 포인트 명시
   - 예상 분량 및 깊이 설정

3. **컨셉 및 접근법**
   - 글의 톤앤매너 정의
   - 설명 방식 (예제 중심, 이론 중심 등)
   - 독자 참여 요소 계획

### Claude 대화형 개선 가이드

1. **초기 컨텐츠 생성**
   - Draft template 기반 첫 버전 생성
   - 구조와 핵심 내용 우선 작성

2. **반복적 품질 개선**
   - 섹션별 상세화 및 보완
   - 예제 추가 및 설명 강화
   - 문체 및 가독성 개선
   - 이미지 플레이스홀더 및 생성 프롬프트 시스템 구축

3. **최종 검토**
   - 전체 일관성 확인
   - 오타 및 문법 검토
   - 메타데이터 완성

### 블로그 글 개선 방법론

#### 1. 흥미 요소 추가

- **제목**: 호기심 유발하는 질문형 제목 (과도한 이모지 금지)
- **도입부**: 개인 경험으로 시작하되 구체적 상황 명시
- **실제 데이터**: 구체적인 성능 테스트 결과와 환경 정보
- **실용적 예시**: 실제 동작하는 코드 샘플과 사용 사례

#### 2. 글 톤 가이드라인

- **경험 공유 톤**: 가르치려는 느낌 금지, 경험을 나누는 느낌
- **자연스러운 표현**:
  - "제가/저는" → "현재/직접/개인적으로"
  - "해야 합니다" → "해보니 좋았음"
  - "추천합니다" → "직접 써본 느낌"
  - "체크리스트" → "직접 겪은 문제들"
- **과도한 이모지 사용 금지**: 적절한 수준으로 제한
- **겸손한 어조**: 단정적 표현보다 개인 경험 중심
- **마무리 멘트 금지**: "도움이 되었으면", "공유해주세요" 등 불필요한 마무리 멘트 추가하지 않음
- **불필요한 소감 섹션 금지**: "개인적인 생각", "마지막 한 마디", "앞으로 어떻게 될까" 등 추상적인 소감/전망 섹션 추가하지 않음

#### 3. 신뢰성 확보

- **과장 금지**: 마케팅 문구나 과장된 수치 제거
- **현실적 데이터**: 실제 측정 가능한 성능 수치 제시
- **솔직한 공유**: 제한사항과 문제점을 숨기지 않고 공유
- **구체적 사례**: 추상적 설명보다 구체적인 경험담

#### 4. 실용성 강화

- **실제 설정**: 복사해서 바로 쓸 수 있는 설정 파일
- **문제 해결**: 실제 겪은 문제와 해결 과정 상세 기록
- **상황별 가이드**: 다양한 상황에서의 선택 기준 제시
- **개인 경험담**: 삽질 과정과 배운 점 솔직하게 공유

#### 5. 구조 개선

- **깨진 표 수정**: 마크다운 표 형식 정확히 작성
- **명확한 섹션**: 내용에 맞는 적절한 제목 구조
- **읽기 쉬운 형식**: 표, 코드 블록, 인용문 적절히 활용
- **논리적 흐름**: 독자 입장에서 자연스러운 정보 순서

## 파일 명명 규칙

### 포스트 파일명
- 형식: `YYYY-MM-DD-제목.md`
- 예시: `2024-03-15-react-hooks-정리.md`

### Draft Template 메타데이터
```markdown
---
type: 'draft-template'
topic: '글의 주제'
target_audience: '타겟 독자'
purpose: '글의 목적'
estimated_length: '예상 글 길이'
difficulty_level: '난이도 (초급/중급/고급)'
created_date: 'YYYY-MM-DD'
status: 'planning' # planning → drafting → improving → completed
---
```

### 완성된 글 메타데이터
```markdown
---
title: '포스트 제목'
date: 'YYYY-MM-DD'
category: '카테고리명'
tags: ['태그1', '태그2']
description: '글 요약'
thumbnail: 'assets/images/썸네일.jpg'
status: 'ready-to-publish' # ready-to-publish → published
velog_url: '' # 발행 후 URL 기록
quality_score: '1-10점' # Claude와의 작업을 통한 품질 평가
---
```

## 프로젝트 현황

### 완료된 작업

#### ✅ 디렉토리 구조 구축
- `drafts/` - 새 컨텐츠 기획 공간
- `in-progress/` - Claude와 협업 중인 컨텐츠
- `archive/` - 완성된 고품질 컨텐츠
- `assets/` - 공통 이미지 자원
- `tools/` - 자동화 스크립트

#### ✅ 워크플로우 도구 생성
- `create-new-draft.sh` - 새 draft 생성
- `move-to-progress.sh` - 작업 시작
- `move-to-archive.sh` - 완성 후 아카이브

#### ✅ 템플릿 시스템
- Draft template (metadata + planning sections)
- README 파일들 (각 폴더 사용법)

#### ✅ 예제 생성
- `claude-workflow-system-구축기` draft 생성

### 현재 사용 가능한 자동화 스크립트

```bash
# 새 draft 생성
./tools/create-new-draft.sh "토픽명"

# 작업 시작 (draft → in-progress)
./tools/move-to-progress.sh "폴더명"

# 완성 후 아카이브 (in-progress → archive)
./tools/move-to-archive.sh "폴더명" [품질점수]

# velog-fetcher 포스트 정리 (일회성)
./tools/organize-velog-posts.sh
```

모든 스크립트는 실행 권한이 자동으로 설정되며, 프로젝트 루트에서 실행해야 합니다.

## 컨텐츠 개선 진행 상황

### 작업 개요
총 58개 블로그 포스트의 품질 개선 작업을 진행 중입니다. (1개 삭제됨)

### 완료된 포스트 (Archive로 이동 완료)

#### 🎯 Ready-to-Publish (10개)
**Dev-tools 관련 (완료)**:
- `archive/ready-to-publish/2025-09-17-turbopack-vite-yarn-berry-호환성-정리/` (품질점수: 8.5/10)
- `archive/ready-to-publish/2025-09-17-swc/` (품질점수: 8.0/10)
- `archive/ready-to-publish/2022-10-19-using-cache/` (품질점수: 7.5/10)
- `archive/ready-to-publish/2022-10-20-detail-setting/` (품질점수: 8.0/10)
- `archive/ready-to-publish/2022-11-03-update-writer/` (품질점수: 7.5/10)
- `archive/ready-to-publish/2022-11-18-package-prefix/` (품질점수: 8.0/10)
- `archive/ready-to-publish/2022-11-20-git-checkout-file/` (품질점수: 7.5/10)
- `archive/ready-to-publish/2022-11-20-git-reflog/` (품질점수: 8.0/10)

**Frontend 관련 (완료)**:
- `archive/ready-to-publish/2025-09-17-lodash-꼭-써야-할까-가벼운-대안-라이브러리-찾아보기/` (품질점수: 8.0/10)
- `archive/ready-to-publish/2025-09-17-vite-typescript-프로젝트-모듈-경로-aliasing/` (품질점수: 7.5/10)

#### 🔄 현재 In-Progress (4개)
- `in-progress/2022-10-20-web-storage-api/` (Frontend - 진행 중)
- `in-progress/2022-11-03-core-js/` (Frontend - 진행 중)
- `in-progress/2022-11-23-frontend-first-step/` (Frontend - 진행 중)
- `in-progress/2025-09-17-javascript-promiseall과-promiseallsettled-직접-구현해보기/` (Frontend - 진행 중)

### 카테고리별 현황

#### ✅ Dev-tools 카테고리 완료
- **진행률**: 100% 완료 (6개 처리 완료)
- **결과**: 5개 개선완료 + 1개 삭제
- **평균 품질점수**: 7.8/10

#### 🔄 Frontend 카테고리 진행 중
- **완료**: 2개 (archive 이동)
- **진행 중**: 4개 (in-progress)
- **남은 작업**: 31개
- **진행률**: 6/37 (16.2%)

#### ⏳ 대기 중 카테고리
- **Infrastructure**: 5개 대기
- **Patterns**: 6개 대기

### 전체 진행률
- **전체**: 58개 포스트
- **Archive 완료**: 10개 (17.2%)
- **In-Progress**: 4개 (6.9%)
- **남은 작업**: 44개 (75.9%)
- **평균 품질점수**: 7.8/10

## 변경사항 기록

### [1.0.0] - 2025-09-18

#### 프로젝트 전면 전환
- Next.js 블로그에서 Claude 기반 컨텐츠 생성 워크플로우 시스템으로 완전 전환
- 기존 블로그 포스트 39개를 새로운 구조로 마이그레이션 완료

#### Added
- 새로운 워크플로우 디렉토리 구조 (`drafts/`, `in-progress/`, `archive/`, `assets/`, `tools/`)
- Draft template 시스템 (`drafts/templates/draft-template.md`)
- 자동화 스크립트 3개:
  - `tools/create-new-draft.sh` - 새 draft 생성
  - `tools/move-to-progress.sh` - draft를 in-progress로 이동
  - `tools/move-to-archive.sh` - 완성된 컨텐츠를 archive로 이동
- 각 워크플로우 폴더별 README 가이드

#### Changed
- CLAUDE.md 전면 재작성 (Claude 기반 컨텐츠 생성 워크플로우로)
- 기존 content/posts/ 구조에서 카테고리별 정리 (frontend, patterns, dev-tools, infrastructure, algorithms)
- 이미지 경로를 절대 경로에서 상대 경로로 변경 (`./images/...`)

#### Removed
- 기존 _my-assets/ 디렉토리 및 레거시 구조
- 사용하지 않는 외부 이미지 링크들
- 불필요한 테마 관련 코드

#### Technical
- 모든 자동화 스크립트에 실행 권한 부여 (`chmod +x`)
- 예제 draft "claude-workflow-system-구축기" 생성
- 환경 변경 추적 규칙을 CLAUDE.md에 명시
- velog-fetcher 포스트 20개 자동 정리 스크립트 (`organize-velog-posts.sh`) 추가
- 블로그 글 개선 방법론을 CLAUDE.md에 체계화 (5가지 핵심 영역)
- 글 톤 가이드라인 정립 (경험 공유 톤, 자연스러운 표현, 불필요한 섹션 금지)
- Turbopack 글 샘플 개선 완료 (개선 방법론 적용 예시)
- SWC 글 개선 완료 (개선 방법론 적용)
- 개선 완료된 글 2개를 in-progress 디렉토리로 이동

#### Migration
- 기존 39개 블로그 포스트를 카테고리별로 재구성
- velog-fetcher 20개 포스트를 기존 구조에 통합
- 총 59개 포스트가 카테고리별로 정리됨:
  - frontend: 38개 (기존 21개 + 신규 12개)
  - dev-tools: 12개 (기존 7개 + 신규 4개)
  - infrastructure: 6개 (기존 4개 + 신규 1개)
  - patterns: 7개 (기존 3개 + 신규 3개)
- 17개 이미지 파일을 각 포스트 디렉토리 내 images/ 폴더로 이동
- 모든 이미지 참조 경로를 상대 경로로 수정

### [1.1.0] - 2025-09-19

#### 문서 통합 및 구조 개선
- 모든 프로젝트 관련 .md 파일을 CLAUDE.md로 통합
- 통합된 파일: claude_code_commands.md, PROJECT-STATUS.md, CHANGELOG.md, CONTENT-IMPROVEMENT-STATUS.md, WORKFLOW-MANAGEMENT.md
- Claude Code 명령어 가이드 제거 (실제 사용하지 않는 복잡한 명령어들)
- 실제 사용하는 3개 스크립트 사용법으로 단순화
- 계층적 문서 구조로 재정리

## 환경 변경 추적 규칙

프로젝트 설정이나 환경이 변경될 때마다 다음을 업데이트합니다:

### 자동 업데이트 규칙

1. **새로운 도구/스크립트 추가시**
   - tools/ 디렉토리의 스크립트는 실행 권한 자동 부여 (`chmod +x`)
   - CLAUDE.md의 자동화 스크립트 섹션 업데이트
   - 변경사항 기록 섹션에 Added 항목 기록

2. **워크플로우 변경시**
   - 관련 README 파일들 업데이트
   - CLAUDE.md 현재 상태 반영
   - 변경사항 기록 섹션에 Changed 항목 기록

3. **디렉토리 구조 변경시**
   - CLAUDE.md의 저장소 구조 섹션 업데이트
   - 각 폴더별 README 파일 동기화
   - 변경사항 기록에 Added/Changed/Removed 적절히 기록

4. **모든 변경사항**
   - 변경사항 기록에 날짜와 함께 상세 기록
   - 버전 태그 관리 (Major.Minor.Patch)

## 품질 관리 및 발행 체크리스트

### 컨텐츠 품질 기준
- Claude와의 대화를 통한 지속적 품질 개선
- 타겟 독자에 맞는 적절한 난이도 유지
- 정확성과 최신성 확보
- 독창성과 가치 있는 인사이트 제공

### 기술적 주의사항
- 이미지 파일 크기 최적화 (웹 최적화)
- 메타데이터 일관성 유지
- 파일 명명 규칙 준수
- 정기적인 백업 및 버전 관리

### 발행 전 체크리스트
- 오타 및 문법 검토 완료
- 이미지 최적화 및 대체 텍스트 추가
- 메타데이터 완성도 확인
- 구조 및 흐름 최종 점검

## 이미지 생성 및 관리

### In-Progress 단계 이미지 워크플로우

#### 1. 이미지 플레이스홀더 삽입
- 글의 핵심 섹션에 전략적으로 이미지 플레이스홀더 배치
- 형식: `![이미지 설명](./images/파일명.jpg)`
- 썸네일, 설명 이미지, 비교 차트, 다이어그램 등 다양한 용도

#### 2. 이미지 생성 프롬프트 시스템
- 각 컨텐츠 폴더 내 `/images/image-generation-prompts.md` 파일 생성
- 각 이미지별 상세 정보 포함:
  - **용도 및 위치**: 이미지의 목적과 글 내 배치 위치
  - **생성 프롬프트**: AI 이미지 생성 도구용 상세 프롬프트
  - **대체 텍스트**: 접근성을 위한 alt text 제안
  - **기술적 요구사항**: 해상도, 파일 형식, 색상 팔레트

#### 3. 스타일 가이드라인
- **공통 디자인 원칙**: 브랜드 색상, 폰트, 스타일 통일
- **기술적 요구사항**: 최소 해상도, 16:9 비율, 웹 최적화
- **접근성 고려**: 색맹 사용자 대비, 명확한 시각적 구분

#### 4. 이미지 생성 및 적용
- 사용자가 제공된 프롬프트로 AI 도구에서 이미지 생성
- 생성된 이미지를 해당 파일명으로 저장
- 필요시 크기 조정 및 웹 최적화 수행

### 파일 관리
- 체계적 파일명 규칙: `01-개요.jpg`, `02-비교차트.jpg` 등
- 각 컨텐츠 폴더 내 `/images/` 디렉토리에 이미지 보관
- 상대 경로 사용으로 이식성 확보

## 확장 계획

- 검색 기능 추가 (전체 텍스트 검색)
- 통계 대시보드 (포스트 수, 카테고리별 분포 등)
- 다른 플랫폼 연동 (Medium, 티스토리 등)
- 자동 배포 스크립트 개발