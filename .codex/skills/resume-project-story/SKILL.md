---
name: resume-project-story
description: Use when editing or reviewing resume content, project issue narratives, data structures, or resume page UI in /Users/hiconsy/Developer/253eosam-resume-project-story.
---

# Resume Project Story

## Overview

This skill is for maintaining the resume site in this repository. Use it when updating resume copy, highlighted project narratives, data models in `src/data/resume.ts`, or the resume page layout in `src/pages/resume.astro`.

## When To Use

- The user wants to revise resume wording in Korean.
- The user wants to restructure project stories, issue blocks, facts, or labels.
- The user wants to change `src/data/resume.ts`, `src/types/resume.ts`, or `src/pages/resume.astro`.
- The user wants project-level consistency across copy, data model, and UI.

## Project Conventions

- Treat `시대인재C` as the best-practice reference for issue-based storytelling.
- Highlighted projects should read in this order:
  `문제정의 → 해결전략 → 주요 실행 → 성과 → 회고`
- Keep `주요 실행` and `성과` separate.
- Prefer concrete operational or maintenance effects over abstract claims.
- Keep Korean copy concise and resume-like. Avoid loose spoken phrasing.
- When a project title needs only partial linking, use `ResumeTextWithLink`.
- Experience records use:
  - `startDate: "YYYY-MM"`
  - `endDate?: "YYYY-MM"`
  - `isCurrent?: boolean`
- Tech stack is rendered inside project facts as the `기술` row.

## File Map

- `src/data/resume.ts`: source of truth for resume content
- `src/types/resume.ts`: resume data types
- `src/pages/resume.astro`: resume page layout and rendering logic

## Editing Workflow

1. Read the relevant files first.
2. If the user is still refining wording, review and suggest better copy before applying.
3. Once the user approves, apply the change directly.
4. After every applied change:
   - run `npm run build`
   - create a commit
5. Keep commits scoped to the change that was just applied.

## Writing Rules

- Project facts should stay compact.
- Team composition and contribution should not contradict each other.
- If a sentence explains why a technical choice was made, that belongs in `해결전략`.
- If a sentence explains what was built or applied, that belongs in `주요 실행`.
- If a sentence explains measurable or maintenance outcomes, that belongs in `성과`.
- If a sentence explains lessons learned or what should be documented next time, that belongs in `회고`.

## UI Rules

- Favor minimal layout changes over decorative UI.
- Preserve the existing resume visual language.
- When adjusting spacing, consider multi-line wrapping cases explicitly.
- Keep link behavior consistent with existing inline/project link styles.

## Validation

- Run `npm run build` after applied changes.
- If data types change, also run `npx tsc --noEmit`.
- Do not leave the repo with uncommitted applied changes.
