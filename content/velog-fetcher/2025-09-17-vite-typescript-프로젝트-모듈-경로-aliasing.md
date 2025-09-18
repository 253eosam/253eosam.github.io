---
title: "Vite + TypeScript 프로젝트 모듈 경로 aliasing"
date: "2025-09-17T07:46:54.843Z"
tags:
  - alias
  - typescript
  - vite
description: "프로젝트 vite와 typescript를 사용하는 작업 공간에서 alias를 통해 절대경로를 설정하는 방법에대해서 설명한다."
url: "https://velog.io/@253eosam/Vite-TypeScript-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EB%AA%A8%EB%93%88-%EA%B2%BD%EB%A1%9C-aliasing"
---

**as-is:**

```jsx
import AppComponent from "../../AppComponent.vue"
```

**to-be:**

```jsx
import AppComponent from "@/components/AppComponent.vue" 
```

> 👉 변경 후 불필요한 경로가 노출되지않아 가독성 상승

## ⚙️ 설정 방법

**1\. vite.config :**

```jsx
import { defineConfig } from "vite"
import vue from "@vitejs/plugin-vue"

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: [
      { find: "@", replacement: "/src" }
    ],
  },
})
```

**2\. tscofing :**

```jsx
{
  "compilerOptions": {
    "baseUrl": ".",
		"paths": {
			"@/*": ["src/*"],
		},

    // ...
}
```