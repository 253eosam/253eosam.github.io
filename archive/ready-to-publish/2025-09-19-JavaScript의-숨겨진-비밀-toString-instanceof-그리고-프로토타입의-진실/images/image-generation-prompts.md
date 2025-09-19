# 이미지 생성 프롬프트 가이드

이 파일은 JavaScript 타입 체크 관련 글에 필요한 이미지들의 생성 프롬프트를 제공합니다.

## 이미지 목록 및 생성 프롬프트

### 1. 01-javascript-type-system-overview.jpg (썸네일)
**용도**: 글 대표 이미지, 썸네일
**위치**: 글 제목 하단

**생성 프롬프트:**
```
Create a modern, professional illustration representing JavaScript's type system complexity. Show multiple JavaScript data types (Array, Object, String, Number, Date, RegExp) as colorful geometric shapes or icons floating around a central JavaScript logo. Include visual elements suggesting type checking methods like magnifying glasses or comparison symbols. Use a clean, technical aesthetic with JavaScript's signature yellow/orange colors. The image should convey the complexity and depth of JavaScript's type system. Style: flat design, technical illustration, 16:9 aspect ratio.
```

### 2. 02-typeof-limitations.jpg
**용도**: typeof 연산자의 한계점 시각화
**위치**: "왜 typeof만으로는 부족한가?" 섹션 하단

**생성 프롬프트:**
```
Create an infographic showing the limitations of JavaScript's typeof operator. Design a split comparison chart where the left side shows different JavaScript values (null, [], {}, new Date(), /regex/) and the right side shows all their typeof results as "object". Use red color to highlight the problem areas. Include a confused emoji or question mark to represent developer confusion. Add visual elements like warning signs or X marks to emphasize the limitations. Style: clean infographic, technical diagram, professional color scheme with red highlights.
```

### 3. 03-object-prototype-toString-mechanism.jpg
**용도**: Object.prototype.toString의 동작 원리 설명
**위치**: toString 메커니즘 설명 후

**생성 프롬프트:**
```
Illustrate the internal mechanism of Object.prototype.toString. Show a flowchart or process diagram with arrows indicating how JavaScript internally determines the [[Class]] or Symbol.toStringTag of different objects. Include examples like Array → "[object Array]", Date → "[object Date]". Use JavaScript code-style fonts and a technical blueprint aesthetic. Show the internal process as a series of connected steps or gears. Colors: blue and yellow (JavaScript colors), with clear text labels and arrows.
```

### 4. 04-prototype-chain-traversal.jpg
**용도**: instanceof의 프로토타입 체인 탐색 과정 시각화
**위치**: 프로토타입 체인 탐색 과정 설명 후

**생성 프롬프트:**
```
Create a visual diagram showing JavaScript prototype chain traversal for instanceof operation. Display a chain of connected objects (myDog → Dog.prototype → Animal.prototype → Object.prototype → null) with arrows indicating the traversal path. Use different colors for each level of the chain. Include checkmarks (✓) at successful comparison points. Show the instanceof operator as a magnifying glass or search tool moving along the chain. Style: technical diagram, clean lines, JavaScript color scheme, hierarchical layout.
```

### 5. 05-auto-boxing-unboxing.jpg
**용도**: 자동 박싱/언박싱 과정 시각화
**위치**: 자동 박싱/언박싱 설명 하단

**생성 프롬프트:**
```
Illustrate JavaScript's automatic boxing and unboxing process. Show a primitive string value "hello" transforming into a String object temporarily, then back to primitive. Use transformation arrows and visual effects like sparkles or magic wands to represent the automatic conversion. Include a timeline or step-by-step process showing: primitive → temporary wrapper object → method call → primitive. Use contrasting colors to distinguish between primitive values and objects. Style: process diagram, animated-style illustrations, technical but friendly.
```

### 6. 06-performance-comparison-chart.jpg
**용도**: 타입 체크 방법별 성능 비교 차트
**위치**: 성능 비교 섹션

**생성 프롬프트:**
```
Design a professional bar chart or performance comparison graph showing the relative speed of different JavaScript type checking methods: typeof (fastest), Array.isArray(), instanceof, and Object.prototype.toString (slowest). Use different colors for each method and include approximate timing numbers (2ms, 3ms, 5ms, 15ms). Add a title "Type Checking Performance Comparison" and y-axis label "Execution Time (ms)". Style: clean business chart, professional colors, clear typography, data visualization aesthetic.
```

## 이미지 스타일 가이드

### 공통 디자인 원칙
- **색상 팔레트**: JavaScript 테마 (노랑 #F7DF1E, 검정 #000000, 파랑 #007ACC)
- **폰트**: 모던하고 가독성 좋은 sans-serif 폰트
- **스타일**: 플랫 디자인, 미니멀, 기술적이면서도 이해하기 쉬운
- **크기**: 16:9 비율 권장 (블로그에 최적화)

### 기술적 요구사항
- **해상도**: 최소 1200x675px (16:9)
- **파일 형식**: JPG (웹 최적화)
- **압축**: 웹 게재용으로 적절히 압축
- **접근성**: 색맹 사용자도 구분 가능한 색상 대비

## 사용 방법

1. 위의 프롬프트를 AI 이미지 생성 도구(DALL-E, Midjourney, Stable Diffusion 등)에 입력
2. 생성된 이미지를 해당 파일명으로 저장
3. images/ 폴더에 업로드
4. 필요시 크기 조정 및 웹 최적화

## 대체 텍스트 (Alt Text) 제안

각 이미지에 대한 접근성을 위한 대체 텍스트:

1. **01-javascript-type-system-overview.jpg**: "JavaScript의 다양한 데이터 타입들과 타입 체크 방법들을 시각화한 개요 이미지"
2. **02-typeof-limitations.jpg**: "typeof 연산자가 모든 객체를 'object'로 반환하는 한계점을 보여주는 비교 차트"
3. **03-object-prototype-toString-mechanism.jpg**: "Object.prototype.toString이 내부적으로 타입을 판별하는 과정을 보여주는 플로우차트"
4. **04-prototype-chain-traversal.jpg**: "instanceof 연산자가 프로토타입 체인을 따라 탐색하는 과정을 보여주는 다이어그램"
5. **05-auto-boxing-unboxing.jpg**: "JavaScript의 원시 타입이 자동으로 래퍼 객체로 변환되는 박싱/언박싱 과정 시각화"
6. **06-performance-comparison-chart.jpg**: "다양한 타입 체크 방법들의 성능을 비교한 막대 차트"