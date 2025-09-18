#!/bin/bash

# velog-fetcher 포스트들을 기존 posts 구조에 통합하는 스크립트

set -e

VELOG_DIR="content/velog-fetcher"
POSTS_DIR="content/posts"

if [ ! -d "$VELOG_DIR" ]; then
    echo "❌ 오류: $VELOG_DIR 폴더가 존재하지 않습니다."
    exit 1
fi

echo "📁 velog-fetcher 포스트들을 카테고리별로 정리합니다..."

# Frontend 카테고리
echo "📂 Frontend 카테고리 처리 중..."
frontend_posts=(
    "2025-09-17-css-길이-단위-정리-px-em-rem.md"
    "2025-09-17-html-table-cell-너비-동일하게-고정.md"
    "2025-09-17-hydration-layout-shift-lazy-load-chunk-등의-개념-정리.md"
    "2025-09-17-input-태그에서-keydown-enter-두번-실행.md"
    "2025-09-17-javascript-promiseall과-promiseallsettled-직접-구현해보기.md"
    "2025-09-17-javascript에서-숫자를-이진법으로-변환하고-다시-10진법으로-변환하는-방법.md"
    "2025-09-17-react-부모컴포넌에서-ref를-이용하여-자식-컴포넌트에-정의된-함수-사용하기.md"
    "2025-09-17-react에서-컴포넌트-언마운트-시-최신-상태를-api로-전송하는-방법.md"
    "2025-09-17-sse.md"
    "2025-09-17-tabindex-정리-htmlaccessibility.md"
    "2025-09-17-zustand-vs-jotai-비교-분석.md"
    "2025-09-17-nuxtjs-의-api-request-간단-정리.md"
)

for post in "${frontend_posts[@]}"; do
    if [ -f "$VELOG_DIR/$post" ]; then
        folder_name=$(basename "$post" .md)
        target_dir="$POSTS_DIR/frontend/$folder_name"

        # 폴더 생성
        mkdir -p "$target_dir/images"

        # 파일 이동
        mv "$VELOG_DIR/$post" "$target_dir/index.md"
        echo "✅ $post → frontend/$folder_name/"
    fi
done

# Dev-tools 카테고리
echo "📂 Dev-tools 카테고리 처리 중..."
devtools_posts=(
    "2025-09-17-swc.md"
    "2025-09-17-turbopack-vite-yarn-berry-호환성-정리.md"
    "2025-09-17-vite-typescript-프로젝트-모듈-경로-aliasing.md"
    "2025-09-17-lodash-꼭-써야-할까-가벼운-대안-라이브러리-찾아보기.md"
)

for post in "${devtools_posts[@]}"; do
    if [ -f "$VELOG_DIR/$post" ]; then
        folder_name=$(basename "$post" .md)
        target_dir="$POSTS_DIR/dev-tools/$folder_name"

        # 폴더 생성
        mkdir -p "$target_dir/images"

        # 파일 이동
        mv "$VELOG_DIR/$post" "$target_dir/index.md"
        echo "✅ $post → dev-tools/$folder_name/"
    fi
done

# Infrastructure 카테고리
echo "📂 Infrastructure 카테고리 처리 중..."
infrastructure_posts=(
    "2025-09-17-jenkins와-github-trigger설정.md"
)

for post in "${infrastructure_posts[@]}"; do
    if [ -f "$VELOG_DIR/$post" ]; then
        folder_name=$(basename "$post" .md)
        target_dir="$POSTS_DIR/infrastructure/$folder_name"

        # 폴더 생성
        mkdir -p "$target_dir/images"

        # 파일 이동
        mv "$VELOG_DIR/$post" "$target_dir/index.md"
        echo "✅ $post → infrastructure/$folder_name/"
    fi
done

# Patterns 카테고리
echo "📂 Patterns 카테고리 처리 중..."
patterns_posts=(
    "2025-09-17-디자인-시스템에서-간격-폰트-크기를-짝수특히-8의-배수로-설정하는-이유.md"
    "2025-09-17-모듈-설계의-핵심-개념-응집도-결합도-의존성.md"
    "2025-09-17-브라우저-인쇄-시-배경-이미지가-출력되지-않는-문제-해결법.md"
)

for post in "${patterns_posts[@]}"; do
    if [ -f "$VELOG_DIR/$post" ]; then
        folder_name=$(basename "$post" .md)
        target_dir="$POSTS_DIR/patterns/$folder_name"

        # 폴더 생성
        mkdir -p "$target_dir/images"

        # 파일 이동
        mv "$VELOG_DIR/$post" "$target_dir/index.md"
        echo "✅ $post → patterns/$folder_name/"
    fi
done

# 남은 파일들 확인
echo "📋 처리되지 않은 파일들 확인 중..."
remaining_files=$(ls -1 "$VELOG_DIR"/*.md 2>/dev/null | wc -l)
if [ "$remaining_files" -gt 0 ]; then
    echo "⚠️  처리되지 않은 파일들:"
    ls -1 "$VELOG_DIR"/*.md
else
    echo "✅ 모든 파일이 성공적으로 정리되었습니다."

    # velog-fetcher 디렉토리가 비어있다면 제거
    if [ -z "$(ls -A "$VELOG_DIR")" ]; then
        rmdir "$VELOG_DIR"
        echo "🗑️  빈 velog-fetcher 디렉토리를 제거했습니다."
    fi
fi

echo "🎉 velog-fetcher 포스트 정리가 완료되었습니다!"