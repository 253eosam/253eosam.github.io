#!/bin/bash

# 새 글 시작 - content/in-progress/에 바로 작업 폴더 생성

set -e
cd "$(dirname "$0")/.."

usage() {
    echo "사용법: $0 <토픽명>"
    echo "예시: $0 \"react-hooks-정리\""
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

TOPIC="$1"
DATE=$(date "+%Y-%m-%d")
FOLDER_NAME="${DATE}-${TOPIC}"
PROGRESS_PATH="content/in-progress/${FOLDER_NAME}"

# 이미 존재하는지 확인
if [ -d "$PROGRESS_PATH" ]; then
    echo "❌ 오류: $PROGRESS_PATH 폴더가 이미 존재합니다."
    exit 1
fi

# 폴더 생성
mkdir -p "$PROGRESS_PATH"
mkdir -p "$PROGRESS_PATH/images"

# 템플릿 복사 및 기본 정보 채우기
cp "content/templates/draft-template.md" "$PROGRESS_PATH/draft.md"

# 기본 메타데이터 채우기
sed -i.bak "s/created_date: ''/created_date: '$DATE'/" "$PROGRESS_PATH/draft.md"
sed -i.bak "s/topic: ''/topic: '$TOPIC'/" "$PROGRESS_PATH/draft.md"
rm -f "$PROGRESS_PATH/draft.md.bak"

echo "✅ 새 글이 생성되었습니다: $PROGRESS_PATH"
echo "📝 draft를 작성하세요: $PROGRESS_PATH/draft.md"
