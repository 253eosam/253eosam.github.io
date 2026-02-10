#!/bin/bash

# 프로젝트 실시간 상태 리포트

set -e
cd "$(dirname "$0")/.."

# 색상 정의
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
RESET='\033[0m'

# 폴더별 카운트
count_folders() {
    local dir="$1"
    if [ -d "$dir" ]; then
        local count=0
        for d in "$dir"/*/; do
            [ -d "$d" ] && count=$((count + 1))
        done
        echo "$count"
    else
        echo "0"
    fi
}

# content/posts 하위 카테고리별 카운트
count_posts_by_category() {
    local category="$1"
    local dir="content/posts/$category"
    count_folders "$dir"
}

# 진행률 바 생성
progress_bar() {
    local current=$1
    local total=$2
    local width=30

    if [ "$total" -eq 0 ]; then
        printf '[%*s] 0%%' "$width" ''
        return
    fi

    local pct=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf '['
    printf '%0.s█' $(seq 1 "$filled" 2>/dev/null) || true
    printf '%0.s░' $(seq 1 "$empty" 2>/dev/null) || true
    printf '] %d%%' "$pct"
}

# 폴더 목록 나열
list_folders() {
    local dir="$1"
    if [ -d "$dir" ]; then
        for d in "$dir"/*/; do
            [ -d "$d" ] && basename "$d"
        done
    fi
}

# metadata.json에서 quality_score 추출
get_quality_score() {
    local json_file="$1"
    if [ -f "$json_file" ]; then
        grep -o '"quality_score":[[:space:]]*[0-9.]*' "$json_file" 2>/dev/null | grep -o '[0-9.]*$' || echo ""
    fi
}

# --- 데이터 수집 ---

DRAFTS=$(count_folders "drafts" 2>/dev/null)
# templates 폴더 제외
if [ -d "drafts/templates" ]; then
    DRAFTS=$((DRAFTS - 1))
fi
[ "$DRAFTS" -lt 0 ] && DRAFTS=0

IN_PROGRESS=$(count_folders "in-progress")
READY=$(count_folders "archive/ready-to-publish")
PUBLISHED=$(count_folders "archive/published")

# content/posts 카테고리별 카운트
FRONTEND=$(count_posts_by_category "frontend")
DEVTOOLS=$(count_posts_by_category "dev-tools")
INFRA=$(count_posts_by_category "infrastructure")
PATTERNS=$(count_posts_by_category "patterns")
UNPROCESSED=$((FRONTEND + DEVTOOLS + INFRA + PATTERNS))

TOTAL=$((DRAFTS + IN_PROGRESS + READY + PUBLISHED + UNPROCESSED))
COMPLETED=$((READY + PUBLISHED))

# quality_score 평균 계산
SCORE_SUM=0
SCORE_COUNT=0
for meta in archive/ready-to-publish/*/metadata.json archive/published/*/metadata.json; do
    if [ -f "$meta" ]; then
        score=$(get_quality_score "$meta")
        if [ -n "$score" ] && [ "$score" != "0" ]; then
            SCORE_SUM=$(echo "$SCORE_SUM + $score" | bc 2>/dev/null || echo "$SCORE_SUM")
            SCORE_COUNT=$((SCORE_COUNT + 1))
        fi
    fi
done

if [ "$SCORE_COUNT" -gt 0 ]; then
    AVG_SCORE=$(echo "scale=1; $SCORE_SUM / $SCORE_COUNT" | bc 2>/dev/null || echo "N/A")
else
    AVG_SCORE="N/A"
fi

# --- 출력 ---

echo ""
echo -e "${BOLD}📊 컨텐츠 워크플로우 현황${RESET}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 전체 요약
echo -e "${BOLD}전체 현황${RESET}  총 ${TOTAL}개 포스트"
echo -e "  $(progress_bar "$COMPLETED" "$TOTAL")"
echo ""

# 워크플로우 단계별
echo -e "  ${GRAY}📝 Drafts:${RESET}              $DRAFTS"
echo -e "  ${YELLOW}🔄 In-Progress:${RESET}         $IN_PROGRESS"
echo -e "  ${GREEN}✅ Ready-to-Publish:${RESET}    $READY"
echo -e "  ${BLUE}📤 Published:${RESET}           $PUBLISHED"
echo -e "  ${GRAY}📦 Unprocessed:${RESET}         $UNPROCESSED"
echo ""

# 카테고리별 현황
echo -e "${BOLD}카테고리별 (미처리)${RESET}"
echo -e "  Frontend:        $FRONTEND"
echo -e "  Dev-tools:       $DEVTOOLS"
echo -e "  Infrastructure:  $INFRA"
echo -e "  Patterns:        $PATTERNS"
echo ""

# 품질 점수
echo -e "${BOLD}품질${RESET}"
echo -e "  평균 품질점수: ${CYAN}$AVG_SCORE${RESET}/10 (${SCORE_COUNT}개 기준)"
echo ""

# 최근 완료 포스트 (archive에서 최신 3개)
echo -e "${BOLD}최근 완료 포스트${RESET}"
RECENT_COUNT=0
for dir in $(ls -dt archive/ready-to-publish/*/ archive/published/*/ 2>/dev/null | head -3); do
    if [ -d "$dir" ]; then
        folder=$(basename "$dir")
        score=""
        meta="$dir/metadata.json"
        if [ -f "$meta" ]; then
            score=$(get_quality_score "$meta")
        fi
        parent=$(basename "$(dirname "$dir")")
        status_label="ready"
        [ "$parent" = "published" ] && status_label="published"
        echo -e "  ${GREEN}•${RESET} $folder ${GRAY}(${score:-?}/10, $status_label)${RESET}"
        RECENT_COUNT=$((RECENT_COUNT + 1))
    fi
done
[ "$RECENT_COUNT" -eq 0 ] && echo -e "  ${GRAY}(없음)${RESET}"

# In-Progress 목록
if [ "$IN_PROGRESS" -gt 0 ]; then
    echo ""
    echo -e "${BOLD}현재 작업 중${RESET}"
    for dir in in-progress/*/; do
        [ -d "$dir" ] && echo -e "  ${YELLOW}•${RESET} $(basename "$dir")"
    done
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GRAY}$(date '+%Y-%m-%d %H:%M:%S')${RESET}"
