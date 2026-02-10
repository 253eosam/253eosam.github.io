#!/bin/bash

# 컨텐츠 워크플로우 도구 가이드

cd "$(dirname "$0")/.."

# 색상 정의
BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
RESET='\033[0m'

# 개별 도움말 정의
show_detail() {
    local name="$1"
    case "$name" in
        new|new.sh)
            echo -e "${BOLD}new.sh${RESET} - 새 글 시작"
            echo ""
            echo "  content/in-progress/에 바로 작업 폴더를 생성합니다."
            echo "  content/templates/draft-template.md를 기반으로 draft.md가 복사되고,"
            echo "  날짜와 토픽명이 자동으로 채워집니다."
            echo ""
            echo -e "  ${CYAN}사용법:${RESET} ./tools/new.sh <토픽명>"
            echo -e "  ${CYAN}예시:${RESET}   ./tools/new.sh \"react-hooks-정리\""
            echo ""
            echo -e "  ${DIM}생성 경로: content/in-progress/YYYY-MM-DD-<토픽명>/${RESET}"
            echo -e "  ${DIM}다음 단계: done.sh${RESET}"
            ;;
        done|done.sh)
            echo -e "${BOLD}done.sh${RESET} - 글 완성 처리"
            echo ""
            echo "  content/in-progress/의 완성된 글을 content/ready-to-publish/로 이동합니다."
            echo "  index.md의 frontmatter에서 메타데이터를 자동 추출하여 metadata.json을 생성합니다."
            echo ""
            echo -e "  ${CYAN}사용법:${RESET} ./tools/done.sh <폴더명> [품질점수]"
            echo -e "  ${CYAN}예시:${RESET}   ./tools/done.sh \"2024-03-15-react-hooks-정리\" 8.5"
            echo ""
            echo -e "  ${CYAN}인자:${RESET}"
            echo "    폴더명      content/in-progress/ 내 폴더 이름 (필수)"
            echo "    품질점수    1-10 사이 점수 (선택, metadata.json에 기록)"
            echo ""
            echo -e "  ${DIM}이전 단계: new.sh${RESET}"
            echo -e "  ${DIM}다음 단계: publish.sh${RESET}"
            ;;
        publish|publish.sh)
            echo -e "${BOLD}publish.sh${RESET} - 발행 처리"
            echo ""
            echo "  content/ready-to-publish/의 글을 content/published/로 이동합니다."
            echo "  metadata.json의 status를 published로 변경하고 발행일을 기록합니다."
            echo ""
            echo -e "  ${CYAN}사용법:${RESET} ./tools/publish.sh <폴더명> [velog-url]"
            echo -e "  ${CYAN}예시:${RESET}   ./tools/publish.sh \"2024-03-15-react-hooks-정리\" \"https://velog.io/@253eosam/...\""
            echo ""
            echo -e "  ${CYAN}인자:${RESET}"
            echo "    폴더명      ready-to-publish/ 내 폴더 이름 (필수)"
            echo "    velog-url   발행된 블로그 URL (선택)"
            echo ""
            echo -e "  ${DIM}이전 단계: done.sh${RESET}"
            ;;
        status|status.sh)
            echo -e "${BOLD}status.sh${RESET} - 실시간 프로젝트 현황"
            echo ""
            echo "  전체 워크플로우의 현재 상태를 한눈에 보여줍니다."
            echo "  각 단계별 폴더 수와 목록을 컬러로 출력합니다."
            echo ""
            echo -e "  ${CYAN}사용법:${RESET} ./tools/status.sh"
            ;;
        generate-registry|generate-registry.sh)
            echo -e "${BOLD}generate-registry.sh${RESET} - content-registry.json 생성"
            echo ""
            echo "  모든 포스트의 메타데이터를 수집하여 content-registry.json 파일을 생성합니다."
            echo "  content/ 하위 전체(in-progress, ready-to-publish, published, posts)를 스캔합니다."
            echo ""
            echo -e "  ${CYAN}사용법:${RESET} ./tools/generate-registry.sh"
            echo -e "  ${CYAN}출력:${RESET}   content-registry.json (프로젝트 루트)"
            ;;
        fix-metadata|fix-metadata.sh)
            echo -e "${BOLD}fix-metadata.sh${RESET} - metadata.json 빈 필드 보완"
            echo ""
            echo "  content/ready-to-publish/ 내 metadata.json의 빈 필드를"
            echo "  index.md frontmatter에서 추출하여 보완하는 일회성 유틸리티입니다."
            echo ""
            echo -e "  ${CYAN}사용법:${RESET} ./tools/fix-metadata.sh"
            ;;
        organize-velog-posts|organize-velog-posts.sh)
            echo -e "${BOLD}organize-velog-posts.sh${RESET} - velog 포스트 정리"
            echo ""
            echo "  velog-fetcher로 가져온 포스트들을 카테고리별로 정리합니다."
            echo "  초기 마이그레이션용 일회성 스크립트입니다."
            echo ""
            echo -e "  ${CYAN}사용법:${RESET} ./tools/organize-velog-posts.sh"
            ;;
        *)
            echo -e "❌ 알 수 없는 스크립트: ${BOLD}$name${RESET}"
            echo ""
            echo "사용 가능한 스크립트:"
            echo "  new, done, publish, status, generate-registry"
            return 1
            ;;
    esac
}

# 전체 가이드 출력
show_all() {
    echo ""
    echo -e "${BOLD}📚 컨텐츠 워크플로우 도구 가이드${RESET}"
    echo ""
    echo -e "${YELLOW}━━ 워크플로우 (3단계) ━━${RESET}"
    echo ""
    echo -e "  ${GREEN}1.${RESET} ${BOLD}new.sh${RESET}        새 글 시작 (content/in-progress/에 생성)"
    echo -e "     ${GRAY}사용법: ./tools/new.sh \"토픽명\"${RESET}"
    echo ""
    echo -e "  ${GREEN}2.${RESET} ${BOLD}done.sh${RESET}       글 완성 (in-progress → ready-to-publish)"
    echo -e "     ${GRAY}사용법: ./tools/done.sh \"폴더명\" [품질점수]${RESET}"
    echo ""
    echo -e "  ${GREEN}3.${RESET} ${BOLD}publish.sh${RESET}    발행 처리 (ready-to-publish → published)"
    echo -e "     ${GRAY}사용법: ./tools/publish.sh \"폴더명\" [velog-url]${RESET}"
    echo ""
    echo -e "${BLUE}━━ 현황 확인 ━━${RESET}"
    echo ""
    echo -e "  ${BOLD}status.sh${RESET}                 실시간 프로젝트 현황"
    echo -e "     ${GRAY}사용법: ./tools/status.sh${RESET}"
    echo ""
    echo -e "  ${BOLD}generate-registry.sh${RESET}      content-registry.json 생성"
    echo -e "     ${GRAY}사용법: ./tools/generate-registry.sh${RESET}"
    echo ""
    echo -e "${MAGENTA}━━ 유틸리티 (일회성) ━━${RESET}"
    echo ""
    echo -e "  ${BOLD}fix-metadata.sh${RESET}           metadata.json 빈 필드 보완"
    echo -e "  ${BOLD}organize-velog-posts.sh${RESET}   velog 포스트 정리 (마이그레이션용)"
    echo ""
    echo -e "${GRAY}💡 개별 도움말: ./tools/help.sh <스크립트명>${RESET}"
    echo ""
}

# 메인 로직
if [ $# -eq 0 ]; then
    show_all
else
    echo ""
    show_detail "$1"
    echo ""
fi
