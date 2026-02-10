#!/bin/bash

# 기존 archive/ready-to-publish 내 metadata.json의 빈 필드를 index.md frontmatter에서 보완하는 일회성 스크립트

set -e
cd "$(dirname "$0")/.."

ARCHIVE_DIR="archive/ready-to-publish"
FIXED=0
SKIPPED=0
TOTAL=0

# frontmatter 영역 추출
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

    # 형식 1: tags: [tag1, tag2] 또는 tag: ['tag1', 'tag2']
    local inline_tags
    inline_tags=$(echo "$frontmatter" | grep -E "^(tags?):.*\[" | head -1 | sed -E 's/^tags?:[[:space:]]*//' | tr -d "[]'" | sed 's/"//g')
    if [ -n "$inline_tags" ]; then
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

    # 형식 2: YAML 배열
    local in_tags=false
    local result="["
    local first=true
    while IFS= read -r line; do
        if echo "$line" | grep -qE "^(tags?):"; then
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

# JSON 문자열 이스케이프
escape_json() {
    echo "$1" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g'
}

echo "🔧 metadata.json 보완 시작..."
echo ""

for dir in "$ARCHIVE_DIR"/*/; do
    [ ! -d "$dir" ] && continue
    TOTAL=$((TOTAL + 1))

    folder=$(basename "$dir")
    meta="$dir/metadata.json"

    # metadata.json이 없으면 스킵
    if [ ! -f "$meta" ]; then
        echo "⚠️  $folder: metadata.json 없음 - 스킵"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # 콘텐츠 파일 찾기
    content_file=""
    if [ -f "$dir/index.md" ]; then
        content_file="$dir/index.md"
    elif [ -f "$dir/content.md" ]; then
        content_file="$dir/content.md"
    fi

    if [ -z "$content_file" ]; then
        echo "⚠️  $folder: 콘텐츠 파일 없음 - 스킵"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # frontmatter 파싱
    frontmatter=$(extract_frontmatter "$content_file")
    if [ -z "$frontmatter" ]; then
        echo "⚠️  $folder: frontmatter 없음 - 스킵"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # 현재 metadata.json 값 확인 후 빈 필드만 업데이트
    current_title=$(grep -o '"title":[[:space:]]*"[^"]*"' "$meta" | sed 's/"title":[[:space:]]*"//' | sed 's/"$//')
    current_category=$(grep -o '"category":[[:space:]]*"[^"]*"' "$meta" | sed 's/"category":[[:space:]]*"//' | sed 's/"$//')
    current_desc=$(grep -o '"description":[[:space:]]*"[^"]*"' "$meta" | sed 's/"description":[[:space:]]*"//' | sed 's/"$//')
    current_tags=$(grep -o '"tags":[[:space:]]*\[.*\]' "$meta" | sed 's/"tags":[[:space:]]*//')

    updated_fields=""

    # title 보완
    if [ -z "$current_title" ]; then
        fm_title=$(get_field "$frontmatter" "title")
        if [ -n "$fm_title" ]; then
            escaped=$(escape_json "$fm_title")
            sed -i.bak "s|\"title\":[[:space:]]*\"\"|\"title\": \"$escaped\"|" "$meta"
            updated_fields+="title "
        fi
    fi

    # category 보완
    if [ -z "$current_category" ]; then
        fm_category=$(get_field "$frontmatter" "category")
        if [ -n "$fm_category" ]; then
            sed -i.bak "s|\"category\":[[:space:]]*\"\"|\"category\": \"$fm_category\"|" "$meta"
            updated_fields+="category "
        fi
    fi

    # description 보완
    if [ -z "$current_desc" ]; then
        fm_desc=$(get_field "$frontmatter" "description")
        if [ -n "$fm_desc" ]; then
            escaped=$(escape_json "$fm_desc")
            sed -i.bak "s|\"description\":[[:space:]]*\"\"|\"description\": \"$escaped\"|" "$meta"
            updated_fields+="description "
        fi
    fi

    # tags 보완 (빈 배열일 때만)
    if [ "$current_tags" = "[]" ]; then
        fm_tags=$(parse_tags "$frontmatter")
        if [ "$fm_tags" != "[]" ]; then
            # sed로 JSON 배열 교체
            # macOS sed 호환을 위해 임시 파일 사용
            python3 -c "
import json, sys
with open('$meta', 'r') as f:
    data = json.load(f)
tags = $fm_tags
data['tags'] = [t.strip('\"') for t in tags] if isinstance(tags, list) else $fm_tags
with open('$meta', 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write('\n')
" 2>/dev/null && updated_fields+="tags " || true
        fi
    fi

    # .bak 파일 정리
    rm -f "$meta.bak"

    if [ -n "$updated_fields" ]; then
        echo "✅ $folder: 보완됨 [$updated_fields]"
        FIXED=$((FIXED + 1))
    else
        echo "   $folder: 변경 없음 (이미 완성)"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 결과: 총 ${TOTAL}개 중 ${FIXED}개 보완, ${SKIPPED}개 스킵"
