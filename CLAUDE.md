# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Next.js 15 personal tech blog with TypeScript, using static export to deploy on GitHub Pages. The project has been completely restructured and simplified to focus purely on content management with a clean, minimal design.

## Commands

### Development
- `pnpm dev` - Start development server with Turbopack
- `pnpm build` - Build for production (static export to `./out`)
- `pnpm start` - Start production server

### Code Quality
- `pnpm lint` - Run ESLint
- `pnpm lint:fix` - Run ESLint with auto-fix

## Code Architecture

### Content Structure (Fully Migrated)
```
content/posts/
├── frontend/ (21 posts)
│   ├── JavaScript: interpreters, closures, prototypes, functional programming
│   ├── Vue.js: performance, reactivity, code style
│   ├── React/UI: modals, events, DOM, browser rendering, state management
│   ├── Advanced: Core.js, virtual DOM, web storage
│   └── Other: dynamic web pages, frontend development basics
├── patterns/ (3 posts)
│   ├── Proxy Pattern, Observer Pattern, PRG Pattern
├── dev-tools/ (7 posts)
│   ├── Git workflows, caching, project configuration
├── infrastructure/ (4 posts)
│   ├── Docker containers, Telegram bots, Excel processing, Sentry
└── algorithms/ (multiple)
    ├── data-structure/ and leetcode/ problems
```

### Directory Structure
- `src/app/` - Next.js App Router pages and layouts (minimal, clean UI)
- `src/types/` - TypeScript type definitions
- `src/utils/` - Utility functions
- `content/posts/` - All blog posts organized by category (39 posts total)
- `public/` - Static files for web

### Content Organization Principles
- **Post Structure**: Each post has its own directory with `index.md` and `images/` folder
- **Image Management**: All images are co-located with their posts using relative paths `./images/filename.png`
- **Categories**: Posts are systematically organized into 5 main categories
- **Frontmatter**: Posts use YAML frontmatter with `title`, `category`, `tags`, `layout` fields
- **Asset Migration**: All legacy `/assets/` references have been converted to relative paths

### Key Configuration
- **Next.js**: Configured with `output: 'export'` for static site generation
- **TypeScript**: Path mapping configured with `@/*` pointing to `src/*`
- **Package Manager**: Uses pnpm (specified in `packageManager` field)
- **Dependencies**: Minimal dependencies - Next.js core, dayjs for dates, no UI libraries

### Styling & UI
- Tailwind CSS v4 for styling
- Pretendard Variable font for Korean typography
- Clean, minimal blog design without component libraries
- Responsive grid layouts for content display
- Simple homepage with recent posts and category navigation

### Code Style
- ESLint with Next.js TypeScript rules and Prettier integration
- No semicolons (`;`), single quotes, trailing commas in multiline
- Unused variables with `_` prefix are ignored
- Korean language set in HTML (`lang="ko"`)

### Content Migration Status
- ✅ All 39 posts migrated from legacy structure
- ✅ All image assets moved to post-specific `images/` directories
- ✅ All `/assets/` references converted to relative paths
- ✅ External images downloaded and stored locally where possible
- ✅ Legacy `_my-assets/` and `/assets/` directories completely removed

### Image Management
- Each post directory contains its own `images/` folder
- 17 actual image files preserved (browser rendering, patterns, state management)
- Placeholder references for missing images use `./images/placeholder.ext` pattern
- All image references use relative paths for portability

### Deployment
- Automatic deployment to GitHub Pages via GitHub Actions on push to `main`
- Static files exported to `./out` directory
- Deployed to `gh-pages` branch
- Blog URL: https://253eosam.github.io