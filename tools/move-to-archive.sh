#!/bin/bash

# in-progress를 archive로 이동하는 스크립트

set -e

usage() {
    echo "사용법: $0 <progress-폴더명> [quality-score]"
    echo "예시: $0 \"2024-03-15-react-hooks-정리\" 8.5"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

FOLDER_NAME="$1"
QUALITY_SCORE="${2:-8.0}"
PROGRESS_PATH="in-progress/${FOLDER_NAME}"
ARCHIVE_PATH="archive/ready-to-publish/${FOLDER_NAME}"

# in-progress 폴더 존재 확인
if [ ! -d "$PROGRESS_PATH" ]; then
    echo "❌ 오류: $PROGRESS_PATH 폴더가 존재하지 않습니다."
    exit 1
fi

# archive에 이미 존재하는지 확인
if [ -d "$ARCHIVE_PATH" ]; then
    echo "❌ 오류: $ARCHIVE_PATH 폴더가 이미 존재합니다."
    exit 1
fi

# 폴더 이동
mv "$PROGRESS_PATH" "$ARCHIVE_PATH"

# 최종 content.md 파일 확인
CONTENT_FILE=""
for file in "$ARCHIVE_PATH"/content-v*.md; do
    if [ -f "$file" ]; then
        CONTENT_FILE="$file"
    fi
done

if [ -z "$CONTENT_FILE" ]; then
    echo "⚠️  경고: content-v*.md 파일을 찾을 수 없습니다."
    echo "📝 $ARCHIVE_PATH/content.md 파일을 수동으로 생성하세요."
else
    # 가장 높은 버전을 content.md로 복사
    cp "$CONTENT_FILE" "$ARCHIVE_PATH/content.md"
    echo "✅ $CONTENT_FILE을 content.md로 복사했습니다."
fi

# metadata.json 생성
cat > "$ARCHIVE_PATH/metadata.json" << EOF
{
  "title": "",
  "date": "$(date '+%Y-%m-%d')",
  "category": "",
  "tags": [],
  "description": "",
  "thumbnail": "thumbnail.jpg",
  "status": "ready-to-publish",
  "velog_url": "",
  "quality_score": $QUALITY_SCORE,
  "workflow": {
    "created_date": "$(date '+%Y-%m-%d')",
    "moved_to_archive": "$(date '+%Y-%m-%d %H:%M:%S')",
    "ready_for_publish": true
  }
}
EOF

# workflow-history.md 생성
cat > "$ARCHIVE_PATH/workflow-history.md" << EOF
# 작업 히스토리 - $FOLDER_NAME

## 프로젝트 개요

- **시작일**: $(date '+%Y-%m-%d')
- **완료일**: $(date '+%Y-%m-%d')
- **품질 점수**: $QUALITY_SCORE/10

## 워크플로우 단계

### 1. Draft 기획
- Draft template 작성
- 토픽 및 구조 정의

### 2. In-Progress 작업
- Claude 협업 컨텐츠 생성
- 반복적 품질 개선
- 이미지 및 자료 추가

### 3. Archive 준비
- 최종 검토 완료
- 메타데이터 정리
- 발행 준비 완료

## 주요 성과

- 최종 컨텐츠 품질: $QUALITY_SCORE/10
- 타겟 독자 만족도 예상: 높음
- Velog 발행 준비: 완료

## 다음 단계

- [ ] Velog에 수동 발행
- [ ] URL 및 성과 추적
- [ ] published 폴더로 이동

EOF

echo "✅ $FOLDER_NAME이 archive/ready-to-publish로 이동되었습니다."
echo "📝 메타데이터를 완성하세요: $ARCHIVE_PATH/metadata.json"
echo "🎯 품질 점수: $QUALITY_SCORE/10"