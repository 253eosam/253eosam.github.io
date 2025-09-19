# Claude Content Generation Workflow

Claude AI를 활용한 체계적인 고품질 블로그 컨텐츠 생성 시스템입니다.

## 🎯 프로젝트 목적

- Claude 기반 고품질 컨텐츠 생성
- Draft template을 통한 체계적 글 기획
- 대화형 방식으로 글의 품질 지속 개선
- 완성된 컨텐츠의 체계적 관리 및 아카이브
- Velog 발행을 위한 최종 컨텐츠 준비

## 🚀 빠른 시작

### 1. 새로운 글 기획 시작

```bash
# 새 draft 생성
./tools/create-new-draft.sh "react-hooks-완벽-가이드"
```

### 2. Claude와 컨텐츠 작업 시작

```bash
# draft를 in-progress로 이동
./tools/move-to-progress.sh "2025-09-18-react-hooks-완벽-가이드"
```

### 3. 완성된 컨텐츠 아카이브

```bash
# 품질 검토 완료 후 archive로 이동
./tools/move-to-archive.sh "2025-09-18-react-hooks-완벽-가이드" 8.5
```

## 📁 프로젝트 구조

```
/
├── drafts/                    # 작성 중인 초안들
│   ├── templates/            # Draft 템플릿
│   │   └── draft-template.md # 기본 draft 템플릿
│   └── [YYYY-MM-DD-topic]/   # 날짜별 draft 폴더
├── in-progress/              # Claude와 작업 중인 컨텐츠
│   └── [YYYY-MM-DD-topic]/   # 진행 중인 글들
│       ├── draft.md          # 원본 draft
│       ├── content-v1.md     # 버전별 컨텐츠
│       ├── content-v2.md     # 개선된 버전
│       ├── images/           # 관련 이미지들
│       └── notes.md          # Claude 대화 기록
├── archive/                  # 완성된 고품질 컨텐츠
│   ├── ready-to-publish/     # Velog 발행 준비된 글
│   └── published/            # 발행 완료된 글
├── assets/                   # 공통 이미지 자원
│   ├── images/              # 생성된 이미지들
│   └── templates/           # 이미지 템플릿
├── tools/                   # 자동화 스크립트
│   ├── create-new-draft.sh  # 새 draft 생성
│   ├── move-to-progress.sh  # 작업 시작
│   └── move-to-archive.sh   # 완성 후 아카이브
└── content/                 # 기존 발행된 블로그 포스트
```

## 🔄 워크플로우

### 1단계: Draft Template 작성

- `templates/draft-template.md` 사용
- 토픽, 목차, 글의 컨셉 정의
- 타겟 독자 및 글의 목적 명시

### 2단계: Claude 대화형 컨텐츠 생성

- Draft template을 기반으로 초기 컨텐츠 생성
- 대화를 통한 반복적 품질 개선
- 구조, 내용, 문체 최적화

### 3단계: 이미지 생성 및 최적화

- 글에 맞는 적절한 이미지 생성 또는 선별
- 썸네일 및 본문 이미지 준비
- 이미지 파일 최적화 및 저장

### 4단계: 아카이브 이동

- 완성된 고품질 컨텐츠를 archive 폴더로 이동
- 최종 검토 및 메타데이터 완성
- Velog 발행 준비 완료

### 5단계: Velog 발행

- 사용자가 archive 내용을 직접 velog에 작성
- 발행 후 상태 업데이트

## 💻 사용 준비

### 필수 조건

- Git
- Bash 실행 환경 (macOS/Linux)

### 설치

```bash
# 저장소 클론
git clone https://github.com/253eosam/253eosam.github.io.git
cd 253eosam.github.io

# 스크립트 실행 권한 확인 (이미 설정됨)
ls -la tools/
```

## 📋 사용 가이드

### Draft 생성하기

```bash
# 새로운 주제로 draft 생성
./tools/create-new-draft.sh "주제명"

# 예시
./tools/create-new-draft.sh "next.js-14-새로운-기능들"
```

생성된 draft는 `drafts/YYYY-MM-DD-주제명/` 폴더에 저장됩니다.

### 작업 시작하기

```bash
# draft를 in-progress로 이동
./tools/move-to-progress.sh "폴더명"

# 예시
./tools/move-to-progress.sh "2025-09-18-next.js-14-새로운-기능들"
```

### 완성 후 아카이브

```bash
# 품질 점수와 함께 archive로 이동
./tools/move-to-archive.sh "폴더명" [품질점수]

# 예시
./tools/move-to-archive.sh "2025-09-18-next.js-14-새로운-기능들" 9.0
```

## 📊 품질 기준

모든 archive 컨텐츠는 다음 기준을 만족해야 합니다:

- 정확성 8점 이상 (10점 만점)
- 유용성 8점 이상
- 가독성 8점 이상
- 독창성 7점 이상
- 전체 품질 점수 8점 이상

## 📝 파일 명명 규칙

- **Draft 폴더**: `YYYY-MM-DD-주제명`
- **컨텐츠 버전**: `content-v1.md`, `content-v2.md`, ...
- **메타데이터**: `metadata.json` (archive 단계)
- **이미지**: `images/` 폴더 내 관리

## 🔧 기술 스택

- **컨텐츠**: Markdown
- **자동화**: Bash Scripts
- **이미지**: AI 생성 도구
- **발행**: Velog 수동 발행
- **버전 관리**: Git

## 📄 문서

- **CLAUDE.md**: 통합 프로젝트 가이드 (상세한 워크플로우, 변경사항 추적, 현재 상태, 컨텐츠 개선 진행 상황, 워크플로우 관리, Claude Code 명령어 등 모든 정보 포함)

## 🤝 기여 방법

1. 새로운 template 제안
2. 자동화 스크립트 개선
3. 품질 평가 기준 개선
4. 워크플로우 최적화 제안

## 📊 프로젝트 현황

- **워크플로우 시스템**: ✅ 완료
- **자동화 스크립트**: ✅ 완료
- **예제 draft**: ✅ 생성됨
- **문서화**: ✅ 완료

---

## 📝 최근 업데이트 (2025-09-19)

### 문서 통합 완료
- 모든 프로젝트 관련 .md 파일을 CLAUDE.md로 통합
- 통합된 파일:
  - claude_code_commands.md → Claude Code 명령어 가이드
  - PROJECT-STATUS.md → 프로젝트 현황 및 상태
  - CHANGELOG.md → 변경사항 기록
  - CONTENT-IMPROVEMENT-STATUS.md → 컨텐츠 개선 작업 진행 상황
  - WORKFLOW-MANAGEMENT.md → 워크플로우 관리 가이드

### 정리된 구조
- **단일 문서**: CLAUDE.md에 모든 정보 집중
- **일관된 정보**: 중복 제거 및 체계적 정리
- **쉬운 관리**: 하나의 파일에서 모든 프로젝트 정보 확인 가능

더 자세한 사용법과 모든 프로젝트 정보는 `CLAUDE.md` 파일을 참고하세요.
