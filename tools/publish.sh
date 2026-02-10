#!/bin/bash

# content/ready-to-publish → content/published로 이동하는 스크립트

set -e
cd "$(dirname "$0")/.."

usage() {
    echo "사용법: $0 <폴더명> [velog-url]"
    echo "예시: $0 \"2024-03-15-react-hooks-정리\" \"https://velog.io/@253eosam/...\""
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

FOLDER_NAME="$1"
VELOG_URL="${2:-}"
SOURCE="content/ready-to-publish/${FOLDER_NAME}"
DEST="content/published/${FOLDER_NAME}"

# 소스 폴더 존재 확인
if [ ! -d "$SOURCE" ]; then
    echo "❌ 오류: $SOURCE 폴더가 존재하지 않습니다."
    exit 1
fi

# 대상 폴더 중복 확인
if [ -d "$DEST" ]; then
    echo "❌ 오류: $DEST 폴더가 이미 존재합니다."
    exit 1
fi

# published 폴더 생성
mkdir -p "content/published"

# 폴더 이동
mv "$SOURCE" "$DEST"

# metadata.json 업데이트
META="$DEST/metadata.json"
if [ -f "$META" ]; then
    # status 변경
    sed -i.bak 's/"status":.*"ready-to-publish"/"status": "published"/' "$META"

    # velog_url 업데이트
    if [ -n "$VELOG_URL" ]; then
        sed -i.bak "s|\"velog_url\":.*\"\"|\"velog_url\": \"$VELOG_URL\"|" "$META"
    fi

    # published_date 추가 (workflow 블록 안에)
    PUBLISHED_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    sed -i.bak "s|\"ready_for_publish\":.*|\"ready_for_publish\": true,\n    \"published_date\": \"$PUBLISHED_DATE\"|" "$META"

    rm -f "$META.bak"
    echo "✅ metadata.json 업데이트 완료"
else
    echo "⚠️  metadata.json이 없습니다. 수동으로 생성하세요."
fi

echo "✅ $FOLDER_NAME이 content/published로 이동되었습니다."
[ -n "$VELOG_URL" ] && echo "🔗 Velog URL: $VELOG_URL"
echo "📅 발행일: $(date '+%Y-%m-%d')"
