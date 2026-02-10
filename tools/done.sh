#!/bin/bash

# content/in-progress를 content/ready-to-publish로 이동하는 스크립트
# index.md frontmatter에서 메타데이터를 자동 추출하여 metadata.json 생성

set -e
cd "$(dirname "$0")/.."

usage() {
    echo "사용법: $0 <폴더명> [품질점수]"
    echo "예시: $0 \"2024-03-15-react-hooks-정리\" 8.5"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

FOLDER_NAME="$1"
QUALITY_SCORE="${2:-}"
PROGRESS_PATH="content/in-progress/${FOLDER_NAME}"
ARCHIVE_PATH="content/ready-to-publish/${FOLDER_NAME}"

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

# --- frontmatter 파싱 함수 ---

# index.md 또는 content.md 찾기
find_content_file() {
    local dir="$1"
    if [ -f "$dir/index.md" ]; then
        echo "$dir/index.md"
    elif [ -f "$dir/content.md" ]; then
        echo "$dir/content.md"
    elif [ -f "$dir/draft.md" ]; then
        echo "$dir/draft.md"
    else
        echo ""
    fi
}

# frontmatter 영역 추출 (--- 사이)
extract_frontmatter() {
    local file="$1"
    sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d'
}

# frontmatter에서 단일 값 추출
get_field() {
    local frontmatter="$1"
    local field="$2"
    echo "$frontmatter" | grep -E "^${field}:" | head -1 | sed "s/^${field}:[[:space:]]*//" | sed 's/^["'"'"']//' | sed 's/["'"'"']$//'
}

# tags/tag 파싱 (3가지 형식 지원)
parse_tags() {
    local frontmatter="$1"

    # 형식 C: tags: [tag1, tag2] 또는 tag: ['tag1', 'tag2']
    local inline_tags
    inline_tags=$(echo "$frontmatter" | grep -E "^(tags?):.*\[" | head -1 | sed -E 's/^tags?:[[:space:]]*//' | tr -d "[]'" | sed 's/"//g')
    if [ -n "$inline_tags" ]; then
        # 쉼표로 분리하여 JSON 배열로 변환
        local result="["
        local first=true
        IFS=',' read -ra tag_arr <<< "$inline_tags"
        for t in "${tag_arr[@]}"; do
            t=$(echo "$t" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            if [ -n "$t" ]; then
                if [ "$first" = true ]; then
                    first=false
                else
                    result+=", "
                fi
                result+="\"$t\""
            fi
        done
        result+="]"
        echo "$result"
        return
    fi

    # 형식 B: YAML 배열
    #   - tag1
    #   - tag2
    local in_tags=false
    local result="["
    local first=true
    while IFS= read -r line; do
        if echo "$line" | grep -qE "^(tags?):"; then
            # 같은 줄에 값이 없으면 YAML 배열 시작
            local val
            val=$(echo "$line" | sed -E 's/^tags?:[[:space:]]*//')
            if [ -z "$val" ]; then
                in_tags=true
                continue
            fi
        fi
        if [ "$in_tags" = true ]; then
            # 빈 줄 건너뛰기
            if [ -z "$(echo "$line" | tr -d '[:space:]')" ]; then
                continue
            fi
            if echo "$line" | grep -qE "^[[:space:]]+-"; then
                local tag
                tag=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | sed 's/^["'"'"']//' | sed 's/["'"'"']$//')
                if [ -n "$tag" ]; then
                    if [ "$first" = true ]; then
                        first=false
                    else
                        result+=", "
                    fi
                    result+="\"$tag\""
                fi
            else
                break
            fi
        fi
    done <<< "$frontmatter"
    result+="]"
    echo "$result"
}

# --- 메인 로직 ---

# 콘텐츠 파일 찾기
CONTENT_FILE=$(find_content_file "$PROGRESS_PATH")

# frontmatter에서 메타데이터 추출
FM_TITLE=""
FM_DATE=""
FM_CATEGORY=""
FM_TAGS="[]"
FM_DESCRIPTION=""
FM_STATUS="ready-to-publish"
FM_QUALITY=""

if [ -n "$CONTENT_FILE" ]; then
    FRONTMATTER=$(extract_frontmatter "$CONTENT_FILE")

    if [ -n "$FRONTMATTER" ]; then
        FM_TITLE=$(get_field "$FRONTMATTER" "title")
        FM_DATE=$(get_field "$FRONTMATTER" "date")
        FM_CATEGORY=$(get_field "$FRONTMATTER" "category")
        FM_DESCRIPTION=$(get_field "$FRONTMATTER" "description")
        FM_QUALITY=$(get_field "$FRONTMATTER" "quality_score")
        FM_TAGS=$(parse_tags "$FRONTMATTER")
    fi
fi

# 날짜: frontmatter에 없으면 폴더명에서 추출, 그것도 없으면 오늘 날짜
if [ -z "$FM_DATE" ]; then
    FM_DATE=$(echo "$FOLDER_NAME" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' || date '+%Y-%m-%d')
fi
# ISO 형식 날짜를 YYYY-MM-DD로 정규화
FM_DATE=$(echo "$FM_DATE" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')

# quality_score: 인자 > frontmatter > 기본값 8.0
if [ -n "$QUALITY_SCORE" ]; then
    : # 인자 우선
elif [ -n "$FM_QUALITY" ]; then
    QUALITY_SCORE="$FM_QUALITY"
else
    QUALITY_SCORE="8.0"
fi

# 폴더 이동
mv "$PROGRESS_PATH" "$ARCHIVE_PATH"

# 최종 content.md 파일 확인
VERSIONED_FILE=""
for file in "$ARCHIVE_PATH"/content-v*.md; do
    if [ -f "$file" ]; then
        VERSIONED_FILE="$file"
    fi
done

if [ -n "$VERSIONED_FILE" ]; then
    cp "$VERSIONED_FILE" "$ARCHIVE_PATH/content.md"
    echo "✅ $VERSIONED_FILE을 content.md로 복사했습니다."
fi

# JSON 문자열 이스케이프
escape_json() {
    echo "$1" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g'
}

ESCAPED_TITLE=$(escape_json "$FM_TITLE")
ESCAPED_DESC=$(escape_json "$FM_DESCRIPTION")

# metadata.json 생성
cat > "$ARCHIVE_PATH/metadata.json" << EOF
{
  "title": "$ESCAPED_TITLE",
  "date": "$FM_DATE",
  "category": "$FM_CATEGORY",
  "tags": $FM_TAGS,
  "description": "$ESCAPED_DESC",
  "status": "ready-to-publish",
  "velog_url": "",
  "quality_score": $QUALITY_SCORE,
  "workflow": {
    "created_date": "$FM_DATE",
    "moved_to_archive": "$(date '+%Y-%m-%d %H:%M:%S')",
    "ready_for_publish": true
  }
}
EOF

# workflow-history.md 생성
cat > "$ARCHIVE_PATH/workflow-history.md" << EOF
# 작업 히스토리 - $FOLDER_NAME

## 프로젝트 개요

- **시작일**: $FM_DATE
- **완료일**: $(date '+%Y-%m-%d')
- **품질 점수**: $QUALITY_SCORE/10

## 워크플로우 단계

### 1. 기획 + 작성
- Draft template 작성
- Claude 협업 컨텐츠 생성
- 반복적 품질 개선

### 2. 완성
- 최종 검토 완료
- 메타데이터 정리
- 발행 준비 완료

## 다음 단계

- [ ] Velog에 발행
- [ ] published 폴더로 이동
EOF

echo "✅ $FOLDER_NAME이 content/ready-to-publish로 이동되었습니다."
echo "📋 메타데이터 자동 추출 완료:"
echo "   제목: ${FM_TITLE:-'(없음)'}"
echo "   카테고리: ${FM_CATEGORY:-'(없음)'}"
echo "   날짜: $FM_DATE"
echo "   품질점수: $QUALITY_SCORE/10"
