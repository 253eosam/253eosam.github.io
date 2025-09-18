---
title: "프론트엔드 프레임워크 3종 세트 직접 써보고 느낀 현실적인 비교"
layout: post
category: frontend
tags: [React, Vue, Angular, 프레임워크비교, 개발경험]
description: "React, Vue, Angular을 실제 프로젝트에서 사용해보면서 각 프레임워크의 장단점과 적합한 상황을 경험 기반으로 정리했습니다. 이론적 비교가 아닌 실무에서 느낀 솔직한 후기입니다."
---

프론트엔드 개발을 시작하면서 React, Vue, Angular 중 어떤 걸 선택할지 고민이 많았습니다. 각각 실제 프로젝트에 적용해보면서 느낀 점들을 정리해봤어요.

## 각 프레임워크를 실제로 써본 경험

### React: 자유도 높지만 선택의 피로감

**사용한 프로젝트**: 개인 블로그, 회사 관리자 페이지

```jsx
// React의 전형적인 컴포넌트
const UserProfile = ({ userId }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUser(userId).then(userData => {
      setUser(userData);
      setLoading(false);
    });
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  return <div>{user.name}</div>;
};
```

**좋았던 점**:
- JSX가 직관적이고 JavaScript와 HTML이 자연스럽게 섞임
- 라이브러리 생태계가 방대해서 원하는 기능은 대부분 있음
- 커뮤니티가 활발해서 문제 해결이 빠름

**힘들었던 점**:
- 상태 관리 라이브러리 선택부터 고민 (Redux, Zustand, Recoil...)
- 폴더 구조, 코딩 컨벤션을 모두 직접 정해야 함
- 설정할 게 많아서 프로젝트 초기 세팅이 오래 걸림

### Vue: 배우기 쉽고 개발 속도 빠름

**사용한 프로젝트**: 사내 대시보드, 개인 토이 프로젝트

```vue
<template>
  <div>
    <div v-if="loading">Loading...</div>
    <div v-else>{{ user.name }}</div>
  </div>
</template>

<script>
export default {
  props: ['userId'],
  data() {
    return {
      user: null,
      loading: true
    }
  },
  async mounted() {
    this.user = await fetchUser(this.userId);
    this.loading = false;
  }
}
</script>
```

**좋았던 점**:
- 문법이 직관적이어서 HTML/CSS 경험만 있어도 빠르게 익힐 수 있음
- SFC(Single File Component) 구조가 깔끔하고 이해하기 쉬움
- 공식 문서가 정말 친절하고 한국어 번역도 잘 되어 있음
- Vue Router, Vuex 등 공식 라이브러리가 잘 정리되어 있음

**아쉬웠던 점**:
- 큰 프로젝트에서는 타입스크립트 지원이 React보다 아쉬움 (Vue 3에서 많이 개선됨)
- 채용 공고에서 React 요구사항이 더 많음

### Angular: 엔터프라이즈급 프로젝트에 적합

**사용한 프로젝트**: 회사 ERP 시스템

```typescript
@Component({
  selector: 'app-user-profile',
  template: `
    <div *ngIf="loading">Loading...</div>
    <div *ngIf="!loading">{{ user?.name }}</div>
  `
})
export class UserProfileComponent implements OnInit {
  @Input() userId: number;
  user: User | null = null;
  loading = true;

  constructor(private userService: UserService) {}

  async ngOnInit() {
    this.user = await this.userService.getUser(this.userId);
    this.loading = false;
  }
}
```

**좋았던 점**:
- TypeScript가 기본이라 대규모 프로젝트에서 안정적
- CLI 도구가 강력해서 컴포넌트, 서비스 생성이 자동화됨
- 의존성 주입, 라우팅, HTTP 클라이언트 등 필요한 모든 게 내장되어 있음
- 코딩 컨벤션이 명확해서 팀 개발할 때 일관성 유지 쉬움

**어려웠던 점**:
- 러닝 커브가 가장 높음 (RxJS, 데코레이터, 의존성 주입 등)
- 간단한 프로젝트에는 오버엔지니어링 느낌
- 빌드 속도가 다른 프레임워크보다 느림

## 실무에서 느낀 선택 기준

### 프로젝트 규모별 선택

**소규모 프로젝트 (1-3명, 개발 기간 1-3개월)**
→ **Vue 추천**
- 빠른 프로토타이핑 가능
- 학습 비용 낮아서 새로운 팀원 투입 쉬움
- 설정보다 개발에 집중 가능

**중규모 프로젝트 (3-8명, 개발 기간 3-12개월)**
→ **React 추천**
- 개발자 채용이 상대적으로 쉬움
- 라이브러리 선택의 자유도 높음
- 커뮤니티가 활발해서 문제 해결 용이

**대규모 프로젝트 (8명 이상, 장기 운영)**
→ **Angular 추천**
- 타입 안정성과 코드 일관성 보장
- 대규모 팀에서 필요한 구조와 규칙 제공
- 장기적인 유지보수 관점에서 유리

### 팀 상황별 선택

**신입 개발자가 많은 팀**
```
Vue > React > Angular
```
- Vue: 가장 배우기 쉬움
- React: 자바스크립트 기본기가 탄탄하면 적응 빠름
- Angular: 웹 개발 전반적인 이해 필요

**경험 많은 개발자 팀**
```
상황에 따라 다름 (모두 가능)
```
- 프로젝트 요구사항과 팀 선호도에 따라 결정

**백엔드 개발자가 프론트엔드 겸업하는 경우**
```
Angular > Vue > React
```
- Angular: 백엔드 개발자에게 친숙한 구조
- Vue: 템플릿 문법이 서버사이드 템플릿과 유사
- React: JSX가 처음에는 어색할 수 있음

## 실제 성능 비교 (체감 기준)

### 개발 속도
1. **Vue**: 가장 빠른 개발 속도
2. **React**: 라이브러리 선택 시간 고려하면 중간
3. **Angular**: 초기 설정은 오래 걸리지만 이후 안정적

### 번들 크기 (Hello World 기준)
1. **Vue**: 약 34KB
2. **React**: 약 42KB (React + ReactDOM)
3. **Angular**: 약 130KB

### 러닝 커브
1. **Vue**: 가장 쉬움 (HTML/CSS 경험자 기준 1-2주)
2. **React**: 중간 (자바스크립트 경험자 기준 2-4주)
3. **Angular**: 가장 어려움 (웹 개발 경험자 기준 1-2개월)

## 현재 시점에서의 추천

### 2024년 기준 상황별 추천

**개인 프로젝트나 스타트업**
- **Vue 3 + Vite**: 빠른 개발, 쉬운 유지보수
- **React + Next.js**: 더 넓은 생태계, 취업 시 유리

**회사 프로젝트**
- **소규모**: Vue + Nuxt
- **중대규모**: React + Next.js 또는 Angular

**학습 목적**
1. **첫 프레임워크**: Vue (쉬운 진입)
2. **두 번째 프레임워크**: React (시장 점유율)
3. **세 번째 프레임워크**: Angular (엔터프라이즈 경험)

## 결론: 정답은 없다

세 프레임워크 모두 훌륭하고, 각각의 철학과 장점이 다릅니다:

- **React**: 자유도와 생태계
- **Vue**: 접근성과 개발 경험
- **Angular**: 안정성과 확장성

개인적으로는 Vue로 시작해서 웹 개발의 재미를 느끼고, React로 시장성을 확보하고, Angular로 대규모 프로젝트 경험을 쌓는 순서를 추천합니다.

가장 중요한 건 프레임워크보다는 **자바스크립트 기본기**와 **웹 개발 전반의 이해**입니다. 프레임워크는 도구일 뿐, 결국 문제를 해결하는 건 개발자의 역량이니까요.