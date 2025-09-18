#!/bin/bash

# 새로운 draft 생성 스크립트

set -e

# 사용법 출력
usage() {
    echo "사용법: $0 <토픽명>"
    echo "예시: $0 \"react-hooks-정리\""
    exit 1
}

# 인자 확인
if [ $# -eq 0 ]; then
    usage
fi

TOPIC="$1"
DATE=$(date "+%Y-%m-%d")
FOLDER_NAME="${DATE}-${TOPIC}"
DRAFT_PATH="drafts/${FOLDER_NAME}"

# 이미 존재하는지 확인
if [ -d "$DRAFT_PATH" ]; then
    echo "❌ 오류: $DRAFT_PATH 폴더가 이미 존재합니다."
    exit 1
fi

# 폴더 생성
mkdir -p "$DRAFT_PATH"

# 템플릿 복사 및 기본 정보 채우기
cp "drafts/templates/draft-template.md" "$DRAFT_PATH/draft.md"

# 기본 메타데이터 채우기
sed -i.bak "s/created_date: ''/created_date: '$DATE'/" "$DRAFT_PATH/draft.md"
sed -i.bak "s/topic: ''/topic: '$TOPIC'/" "$DRAFT_PATH/draft.md"
rm "$DRAFT_PATH/draft.md.bak"

# README 생성
cat > "$DRAFT_PATH/README.md" << EOF
# $TOPIC

생성일: $DATE
상태: planning

## 작업 단계

- [ ] Draft template 작성 완료
- [ ] 기획 검토 완료
- [ ] in-progress로 이동 준비

## 메모

<!-- 여기에 기획 관련 메모 작성 -->

EOF

echo "✅ 새로운 draft가 생성되었습니다: $DRAFT_PATH"
echo "📝 다음 파일을 편집하세요: $DRAFT_PATH/draft.md"