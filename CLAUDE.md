# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Next.js 15 personal tech blog with TypeScript, using static export to deploy on GitHub Pages. The project has been simplified to focus purely on content without unnecessary UI libraries or complex theming.

## Commands

### Development
- `pnpm dev` - Start development server with Turbopack
- `pnpm build` - Build for production (static export to `./out`)
- `pnpm start` - Start production server

### Code Quality
- `pnpm lint` - Run ESLint
- `pnpm lint:fix` - Run ESLint with auto-fix

## Code Architecture

### Content Structure
```
content/
├── posts/
│   ├── frontend/
│   │   ├── 2022-10-20-browser-rendering/
│   │   │   ├── index.md
│   │   │   └── images/
│   │   └── 2022-10-20-state-management/
│   │       ├── index.md
│   │       └── images/
│   ├── patterns/
│   │   ├── 2022-11-03-proxy-pattern/
│   │   │   ├── index.md
│   │   │   └── images/
│   │   └── 2022-11-03-observer-pattern/
│   │       ├── index.md
│   │       └── images/
│   └── algorithms/
│       ├── data-structure/
│       │   └── array.md
│       └── leetcode/
│           ├── p37.md
│           └── p27.md
```

### Directory Structure
- `src/app/` - Next.js App Router pages and layouts
- `src/types/` - TypeScript type definitions
- `src/utils/` - Utility functions
- `content/posts/` - Blog posts organized by category
- `_my-assets/` - Legacy assets (being migrated to content structure)
- `public/` - Static files for web

### Content Organization
- **Posts Structure**: Each post has its own directory with `index.md` and `images/` folder
- **Image Paths**: Use relative paths like `./images/filename.png` in markdown
- **Categories**: Posts are organized into `frontend/`, `patterns/`, and `algorithms/`
- **Frontmatter**: Posts use YAML frontmatter with `title`, `category`, `tags` fields

### Key Configuration
- **Next.js**: Configured with `output: 'export'` for static site generation
- **TypeScript**: Path mapping configured with `@/*` pointing to `src/*`
- **Package Manager**: Uses pnpm (specified in `packageManager` field)
- **Dependencies**: Minimal dependencies focused on Next.js core functionality

### Styling & UI
- Tailwind CSS v4 for styling
- Pretendard Variable font for Korean typography
- Clean, minimal design without UI component libraries
- Responsive grid layouts for content display

### Code Style
- ESLint with Next.js TypeScript rules and Prettier integration
- No semicolons (`;`), single quotes, trailing commas in multiline
- Unused variables with `_` prefix are ignored
- Korean language set in HTML (`lang="ko"`)

### Content Migration
- Legacy content in `_my-assets/_posts/` should be migrated to new structure
- Image paths need to be updated from `/assets/post-img/...` to `./images/...`
- External images (Velog, etc.) should be downloaded and stored locally when possible

### Deployment
- Automatic deployment to GitHub Pages via GitHub Actions on push to `main`
- Static files exported to `./out` directory
- Deployed to `gh-pages` branch