# Claude 기반 컨텐츠 생성 워크플로우

이 프로젝트는 Claude를 활용하여 높은 퀄리티의 블로그 컨텐츠를 생성하는 공간입니다. draft template을 통해 체계적으로 글을 기획하고, AI 대화를 통해 품질을 개선하여 최종적으로 블로그에 발행할 수 있는 완성된 컨텐츠를 생산합니다.

## 목적

- Claude 기반 고품질 컨텐츠 생성
- Draft template을 통한 체계적 글 기획
- 대화형 방식으로 글의 품질 지속 개선
- 완성된 컨텐츠의 체계적 관리 및 아카이브
- 블로그 발행을 위한 최종 컨텐츠 준비

## 빠른 시작

### 자동화 스크립트

모든 스크립트는 프로젝트 루트에서 실행합니다.

```bash
# 새 draft 생성
./tools/create-new-draft.sh "토픽명"

# 작업 시작 (draft → in-progress)
./tools/move-to-progress.sh "폴더명"

# 완성 후 아카이브 (in-progress → archive, frontmatter 자동 파싱)
./tools/move-to-archive.sh "폴더명" [품질점수]

# 발행 처리 (ready-to-publish → published)
./tools/publish.sh "폴더명" "https://velog.io/@253eosam/..."

# 실시간 현황 확인
./tools/status.sh

# 전체 포스트 레지스트리 생성
./tools/generate-registry.sh
```

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

4. **approve로 완성 확정**
   - **approve** 명령으로 `archive/ready-to-publish/`로 이동
   - 메타태그 `status: ready-to-publish` 설정
   - 최종 검토 및 메타데이터 완성

5. **발행 및 상태 관리**
   - 사용자가 실제 블로그에 발행
   - `./tools/publish.sh`로 `archive/published/`로 이동

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
├── content-registry.json     # 전체 포스트 현황 (자동 생성)
└── tools/                   # 자동화 스크립트
```

### 컨텐츠 워크플로우

#### 기존 컨텐츠 개선
```
content/posts/ → [rewrite] → in-progress/ → [approve] → archive/ready-to-publish/ → [publish] → archive/published/
```

#### 신규 컨텐츠 생성
```
1. Draft Template 생성 → drafts/
2. Draft 작성 완료
3. [make content] → drafts/ 이동 → archive/used-draft/ + 초안 생성 → in-progress/
4. in-progress/에서 Claude AI와 대화형 고도화 작업
5. [approve] → in-progress/ → archive/ready-to-publish/
6. [publish] → archive/ready-to-publish/ → archive/published/
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
difficulty_level: '난이도 (초급/중급/고급)'
created_date: 'YYYY-MM-DD'
status: 'planning'
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
status: 'ready-to-publish'
quality_score: '1-10점'
---
```

## 품질 관리 및 발행 체크리스트

### 컨텐츠 품질 기준
- Claude와의 대화를 통한 지속적 품질 개선
- 타겟 독자에 맞는 적절한 난이도 유지
- 정확성과 최신성 확보
- 독창성과 가치 있는 인사이트 제공

### 발행 전 체크리스트
- 오타 및 문법 검토 완료
- 메타데이터 완성도 확인
- 구조 및 흐름 최종 점검
