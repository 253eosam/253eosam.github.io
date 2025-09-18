#!/bin/bash

# Draft를 in-progress로 이동하는 스크립트

set -e

usage() {
    echo "사용법: $0 <draft-폴더명>"
    echo "예시: $0 \"2024-03-15-react-hooks-정리\""
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

FOLDER_NAME="$1"
DRAFT_PATH="drafts/${FOLDER_NAME}"
PROGRESS_PATH="in-progress/${FOLDER_NAME}"

# Draft 폴더 존재 확인
if [ ! -d "$DRAFT_PATH" ]; then
    echo "❌ 오류: $DRAFT_PATH 폴더가 존재하지 않습니다."
    exit 1
fi

# in-progress에 이미 존재하는지 확인
if [ -d "$PROGRESS_PATH" ]; then
    echo "❌ 오류: $PROGRESS_PATH 폴더가 이미 존재합니다."
    exit 1
fi

# 폴더 이동
mv "$DRAFT_PATH" "$PROGRESS_PATH"

# images 폴더 생성
mkdir -p "$PROGRESS_PATH/images"

# notes.md 생성
cat > "$PROGRESS_PATH/notes.md" << EOF
# 작업 노트 - $FOLDER_NAME

## Claude 대화 기록

### 초기 컨텐츠 생성
- 날짜:
- 주요 결과:
- 개선 포인트:

### 개선 작업
- 날짜:
- 변경사항:
- 품질 향상도:

## 품질 체크

- [ ] 구조와 흐름 개선
- [ ] 예제 및 설명 보강
- [ ] 문체 및 가독성 개선
- [ ] 이미지 및 자료 추가
- [ ] 최종 검토 완료

## 다음 단계

- [ ] archive/ready-to-publish로 이동

EOF

echo "✅ $FOLDER_NAME이 in-progress로 이동되었습니다."
echo "📝 작업을 시작하세요: $PROGRESS_PATH/"