# Changelog

프로젝트의 모든 중요한 변경사항이 이 파일에 문서화됩니다.

## [1.0.0] - 2025-09-18

### 프로젝트 전면 전환
- Next.js 블로그에서 Claude 기반 컨텐츠 생성 워크플로우 시스템으로 완전 전환
- 기존 블로그 포스트 39개를 새로운 구조로 마이그레이션 완료

### Added
- 새로운 워크플로우 디렉토리 구조 (`drafts/`, `in-progress/`, `archive/`, `assets/`, `tools/`)
- Draft template 시스템 (`drafts/templates/draft-template.md`)
- 자동화 스크립트 3개:
  - `tools/create-new-draft.sh` - 새 draft 생성
  - `tools/move-to-progress.sh` - draft를 in-progress로 이동
  - `tools/move-to-archive.sh` - 완성된 컨텐츠를 archive로 이동
- 각 워크플로우 폴더별 README 가이드
- PROJECT-STATUS.md - 프로젝트 현재 상태 추적
- CHANGELOG.md - 변경사항 추적 시스템

### Changed
- CLAUDE.md 전면 재작성 (Claude 기반 컨텐츠 생성 워크플로우로)
- 기존 content/posts/ 구조에서 카테고리별 정리 (frontend, patterns, dev-tools, infrastructure, algorithms)
- 이미지 경로를 절대 경로에서 상대 경로로 변경 (`./images/...`)

### Removed
- 기존 _my-assets/ 디렉토리 및 레거시 구조
- 사용하지 않는 외부 이미지 링크들
- 불필요한 테마 관련 코드

### Technical
- 모든 자동화 스크립트에 실행 권한 부여 (`chmod +x`)
- 예제 draft "claude-workflow-system-구축기" 생성
- 환경 변경 추적 규칙을 CLAUDE.md에 명시
- velog-fetcher 포스트 20개 자동 정리 스크립트 (`organize-velog-posts.sh`) 추가
- 블로그 글 개선 방법론을 CLAUDE.md에 체계화 (5가지 핵심 영역)
- 글 톤 가이드라인 정립 (경험 공유 톤, 자연스러운 표현, 불필요한 섹션 금지)
- Turbopack 글 샘플 개선 완료 (개선 방법론 적용 예시)
- SWC 글 개선 완료 (개선 방법론 적용)
- CONTENT-IMPROVEMENT-STATUS.md 생성 (59개 포스트 개선 진행 상황 추적)
- WORKFLOW-MANAGEMENT.md 생성 (워크플로우 관리 가이드)
- 개선 완료된 글 2개를 in-progress 디렉토리로 이동

### Migration
- 기존 39개 블로그 포스트를 카테고리별로 재구성
- velog-fetcher 20개 포스트를 기존 구조에 통합
- 총 59개 포스트가 카테고리별로 정리됨:
  - frontend: 38개 (기존 21개 + 신규 12개)
  - dev-tools: 12개 (기존 7개 + 신규 4개)
  - infrastructure: 6개 (기존 4개 + 신규 1개)
  - patterns: 7개 (기존 3개 + 신규 3개)
- 17개 이미지 파일을 각 포스트 디렉토리 내 images/ 폴더로 이동
- 모든 이미지 참조 경로를 상대 경로로 수정