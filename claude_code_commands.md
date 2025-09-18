# Claude Code 글 작성 명령어 가이드

## 1. Draft Template 관련 명령어

### `/new-draft [토픽명]`
새로운 draft template을 생성합니다.
```bash
/new-draft "React 18의 새로운 기능들"
```

### `/review-draft [파일명]`
기존 draft template을 검토하고 개선점을 제안합니다.
```bash
/review-draft "react-18-features.md"
```

### `/expand-outline [파일명]`
draft의 목차를 더 상세하게 확장합니다.
```bash
/expand-outline "react-18-features.md"
```

## 2. 컨텐츠 생성 관련 명령어

### `/write-from-draft [draft 파일명]`
draft template을 기반으로 첫 번째 컨텐츠 버전을 생성합니다.
```bash
/write-from-draft "drafts/react-18-features.md"
```

### `/improve-section [섹션명] [파일명]`
특정 섹션을 개선합니다.
```bash
/improve-section "Concurrent Features" "in-progress/react-18-article.md"
```

### `/add-examples [주제] [파일명]`
코드 예제나 실용적 예시를 추가합니다.
```bash
/add-examples "useTransition hook" "in-progress/react-18-article.md"
```

### `/enhance-intro [파일명]`
도입부를 더 매력적이고 명확하게 개선합니다.
```bash
/enhance-intro "in-progress/react-18-article.md"
```

### `/strengthen-conclusion [파일명]`
결론 부분을 강화하고 핵심 메시지를 명확히 합니다.
```bash
/strengthen-conclusion "in-progress/react-18-article.md"
```

## 3. 품질 개선 명령어

### `/quality-check [파일명]`
글의 전반적인 품질을 평가하고 개선점을 제안합니다.
```bash
/quality-check "in-progress/react-18-article.md"
```

### `/readability-check [파일명]`
가독성을 검토하고 문장 구조를 개선합니다.
```bash
/readability-check "in-progress/react-18-article.md"
```

### `/tech-accuracy [파일명]`
기술적 정확성을 검토하고 최신 정보로 업데이트합니다.
```bash
/tech-accuracy "in-progress/react-18-article.md"
```

### `/seo-optimize [파일명]`
SEO를 고려하여 제목, 소제목, 키워드를 최적화합니다.
```bash
/seo-optimize "in-progress/react-18-article.md"
```

## 4. 구조 및 형식 명령어

### `/restructure [파일명]`
글의 구조를 논리적으로 재정렬합니다.
```bash
/restructure "in-progress/react-18-article.md"
```

### `/add-metadata [파일명]`
적절한 메타데이터를 생성하고 추가합니다.
```bash
/add-metadata "in-progress/react-18-article.md"
```

### `/format-velog [파일명]`
Velog 발행에 맞는 형식으로 최종 포맷팅합니다.
```bash
/format-velog "archive/ready-to-publish/react-18-article.md"
```

## 5. 이미지 관련 명령어

### `/suggest-images [파일명]`
글에 필요한 이미지들을 제안합니다.
```bash
/suggest-images "in-progress/react-18-article.md"
```

### `/create-thumbnail-concept [파일명]`
썸네일 이미지 컨셉을 제안합니다.
```bash
/create-thumbnail-concept "archive/react-18-article.md"
```

### `/image-prompts [파일명]`
AI 이미지 생성을 위한 프롬프트를 생성합니다.
```bash
/image-prompts "archive/react-18-article.md"
```

## 6. 아카이브 및 발행 관리 명령어

### `/ready-to-archive [파일명]`
글이 아카이브할 준비가 되었는지 최종 검토합니다.
```bash
/ready-to-archive "in-progress/react-18-article.md"
```

### `/move-to-archive [파일명]`
완성된 글을 아카이브로 이동합니다.
```bash
/move-to-archive "in-progress/react-18-article.md"
```

### `/publish-checklist [파일명]`
Velog 발행 전 체크리스트를 생성합니다.
```bash
/publish-checklist "archive/ready-to-publish/react-18-article.md"
```

### `/post-published [파일명] [velog-url]`
Velog에 발행 완료 후 상태를 업데이트합니다.
```bash
/post-published "archive/react-18-article.md" "https://velog.io/@username/react-18-features"
```

## 7. 대화형 컨텐츠 개선 명령어

### `/brainstorm [주제]`
특정 주제에 대해 아이디어 브레인스토밍을 합니다.
```bash
/brainstorm "React 18의 실무 활용 방안"
```

### `/explain-better [개념] [파일명]`
복잡한 개념을 더 쉽게 설명하는 방법을 제안합니다.
```bash
/explain-better "Concurrent Rendering" "in-progress/react-18-article.md"
```

### `/target-audience [독자층] [파일명]`
특정 독자층에 맞게 글을 조정합니다.
```bash
/target-audience "초급 개발자" "in-progress/react-18-article.md"
```

### `/add-personality [스타일] [파일명]`
글에 개성과 톤을 추가합니다.
```bash
/add-personality "친근하고 실용적인" "in-progress/react-18-article.md"
```

## 8. 분석 및 통계 명령어

### `/content-stats`
프로젝트 내 모든 컨텐츠의 통계를 보여줍니다.
```bash
/content-stats
```

### `/quality-report [기간]`
특정 기간 동안의 품질 리포트를 생성합니다.
```bash
/quality-report "last-month"
```

### `/popular-topics`
인기 있는 토픽과 트렌드를 분석합니다.
```bash
/popular-topics
```

## 9. 자동화 명령어

### `/batch-update-metadata`
모든 파일의 메타데이터를 일괄 업데이트합니다.
```bash
/batch-update-metadata
```

### `/optimize-images`
assets 폴더의 모든 이미지를 최적화합니다.
```bash
/optimize-images
```

### `/backup-project`
전체 프로젝트를 백업합니다.
```bash
/backup-project
```

## 사용 예시

### 완전한 글 작성 워크플로우
```bash
# 1. 새 draft 생성
/new-draft "Next.js 14 App Router 완벽 가이드"

# 2. draft 검토 및 개선
/review-draft "nextjs-14-app-router.md"
/expand-outline "nextjs-14-app-router.md"

# 3. 첫 번째 컨텐츠 생성
/write-from-draft "drafts/nextjs-14-app-router.md"

# 4. 섹션별 개선
/improve-section "라우팅 시스템" "in-progress/nextjs-14-guide.md"
/add-examples "App Router vs Pages Router" "in-progress/nextjs-14-guide.md"

# 5. 품질 검토
/quality-check "in-progress/nextjs-14-guide.md"
/tech-accuracy "in-progress/nextjs-14-guide.md"
/readability-check "in-progress/nextjs-14-guide.md"

# 6. 이미지 준비
/suggest-images "in-progress/nextjs-14-guide.md"
/create-thumbnail-concept "in-progress/nextjs-14-guide.md"

# 7. 최종 준비
/add-metadata "in-progress/nextjs-14-guide.md"
/format-velog "in-progress/nextjs-14-guide.md"
/ready-to-archive "in-progress/nextjs-14-guide.md"

# 8. 아카이브 이동
/move-to-archive "in-progress/nextjs-14-guide.md"

# 9. 발행 준비
/publish-checklist "archive/ready-to-publish/nextjs-14-guide.md"

# 10. 발행 완료 후
/post-published "archive/nextjs-14-guide.md" "https://velog.io/@username/nextjs-14-complete-guide"
```

## 명령어 커스터마이징

필요에 따라 다음과 같이 명령어를 조합하거나 커스터마이징할 수 있습니다:

```bash
# 여러 명령어 조합
/quality-check && /readability-check && /seo-optimize "article.md"

# 특정 조건으로 명령어 실행
/improve-section "성능 최적화" --detail-level=advanced "article.md"

# 대화형 모드로 명령어 실행
/brainstorm --interactive "React 성능 최적화 기법"
```