import type { ResumeData } from '../types/resume';

const resume = {
  "profile": {
    "name": "이성준",
    "profileImage": "/images/profile.png",
    "role": "프론트엔드 개발자",
    "email": "253eosam@gmail.com",
    "links": [
      { "label": "GitHub", "url": "https://github.com/253eosam" },
      { "label": "Blog", "url": "https://253eosam.github.io/" }
    ],
    "introduction": "비즈니스 도메인과 프로젝트 히스토리 이해를 바탕으로 안정적인 서비스 운영을 추구하는 6년차 FE 개발자입니다.",
    "highlights": [
      "서비스 전 과정(기획-개발-배포-운영) 경험 보유",
      "스타트업 초기 멤버로 참여하여 실무자의 요구사항을 분석하고 구현한 경험",
      "대규모 트래픽(동시 접속 16,000명) 안정적 처리 경험",
      "개발 경험(DX) 개선을 통한 팀 생산성 향상 경험",
      "이커머스 어드민 장기 유지보수 및 개선 경험"
    ]
  },
  "skills": ["TypeScript", "Nuxt.js", "Next.js", "TailwindCSS", "styled-components", "Git", "Vue.js", "React"],
  "experience": [
    {
      "company": "하이컨시",
      "logo": "/images/company/hiconsy.webp",
      "role": "팀원",
      "department": "FE개발팀",
      "startDate": "2025-04",
      "isCurrent": true,
      "employmentType": "정규직",
      "description": "시대인재 브랜드를 운영하는 대치동 기반 교육 기업입니다.",
      "projects": [
        {
          "name": {
            "text": "시대인재 북스 마이그레이션 & 디자인 시스템",
            "link": {
              "label": "시대인재 북스 마이그레이션",
              "url": "https://sdijbooks.com/"
            }
          },
          "highlighted": true,
          "summary": "ASP 기반 모바일/PC 도서 판매 서비스를 Next.js 기반의 반응형 웹으로 통합 마이그레이션하고, 배포 파이프라인을 재구성한 프로젝트입니다.",
          "contribution": "프론트엔드 프로젝트 리딩, 프로젝트 환경 설정, CI/CD 배포 프로세스 구축, 디자인 시스템 개발, 도서·구매 서브도메인 관련 페이지 퍼블리싱 및 프론트엔드 개발을 담당했습니다.",
          "techStack": ["Next", "tailwindcss", "pnpm", "monorepo", "zustand", "daisyUI", "orval", "react-query"],
          "team": "FE 4명, 퍼블리셔 1명, BE 2명, 기획자 2명, 디자이너 2명",
          "issues": [
            {
              "problem": "디자인 개편과 마이그레이션이 동시에 진행되면서 디자이너와 개발자가 재사용 기준 없이 화면을 만들면 서비스마다 구현 방식이 달라지고, 통일된 UI 체계를 세우기 어려운 상황이었습니다.",
              "strategy": "디자이너와 함께 Figma 컴포넌트를 기준으로 재사용 범위와 디자인 시스템 적용 가능성을 먼저 검증하고, 공통 UI와 브랜드별 스타일을 분리하는 구조를 설계했습니다.",
              "execution": "TailwindCSS와 daisyUI를 채택하고 style layer로 framework 스타일을 커스터마이징했습니다. 프리미티브 UI를 조합한 Molecule/Organism 컴포넌트를 구축해 Storybook으로 화면과 개발 범위를 공유했고, 컬러·타이포그래피·breakpoint·spacing을 디자인 토큰으로 분리해 브랜드별 스타일을 앱 단위로 주입할 수 있게 설계했습니다.",
              "impact": "Figma-Storybook-앱 구현이 같은 컴포넌트 단위로 연결되면서 디자인 일관성과 협업 생산성을 높였고, 동일 컴포넌트를 서비스별 브랜드 스타일에 맞게 재사용할 수 있는 기반을 마련했습니다.",
              "retrospective": "디자인 시스템은 컴포넌트 구축 자체보다 재사용 기준과 운영 원칙을 디자이너와 먼저 합의하는 과정이 더 중요하다는 점을 확인했습니다."
            },
            {
              "problem": "기존 ASP 환경은 ASP 친화적인 개발자에게 업무가 편중되기 쉬웠고, 화면 로직과 정책이 여러 레이어에 분산돼 FE·BE 역할 경계가 모호했습니다. 또한 SP 기반 구조와 query가 함께 얽혀 있어 유지보수와 연동 방식 정리에 비효율이 있었습니다.",
              "strategy": "Next.js 마이그레이션을 계기로 FE·BE 책임 경계를 명확히 나누고, 화면 정책·연동 구조·공통 자산을 각 영역의 전문성에 맞게 관리할 수 있는 구조로 재편하고자 했습니다.",
              "execution": "ASP 화면을 Next.js로 전환하면서 기존 SP 기반 구조와 query가 함께 얽혀 있던 연동 방식을 API 중심으로 재정리하고, Swagger 명세를 추적해 Orval로 API interface와 호출 함수를 자동화했습니다. 또한 공통 유틸리티와 UI를 모노레포 구조로 분리하고 패키지 버전까지 한곳에서 관리하도록 구성했습니다.",
              "impact": [
                "FE·BE 역할 경계가 명확해져 협업 효율과 유지보수성이 개선됐고, API 연동 코드와 패키지 관리가 표준화되면서 생산성을 높였습니다.",
                "dev 환경 Lighthouse 기준 Performance 84.5점, Best Practices 92.1점을 기록했습니다.",
                "주요 성능 지표: FCP 640.8ms, LCP 1.68s, TBT 13.9ms, Speed Index 1.16s, TTI 1.68s",
                "대표 페이지 기준 books-main 96점, column-main 84점, main 87점을 확인했습니다."
              ],
              "retrospective": "초기 분석 내용을 더 일찍 문서화했다면 팀 간 페이지 구현 속도 차이를 더 줄일 수 있었겠다고 판단했습니다."
            },
            {
              "strategy": "Swagger 기반 API를 Orval로 생성해 프론트와 백엔드 인터페이스를 명확히 하고 수작업 API 레이어를 줄였습니다.",
              "execution": "전시 → 주문 → 결제 프로세스를 구현하고, Orval을 활용한 Swagger API code generation을 적용했습니다.",
              "impact": "디자인 시스템과 API 생성 체계를 먼저 정리해 팀 단위 구현 일관성과 유지보수성을 확보했습니다."
            },
            {
              "strategy": "배포 환경은 ECS 기준으로 Docker/PM2 설정을 정리하고, 오픈 전 Lighthouse 비교를 통해 병목 구간을 계측 중심으로 최적화했습니다.",
              "execution": "dockerfile 작성, ECS 배포 환경 설정, PM2 기반 프로세스 운영 최적화를 수행했습니다."
            },
            {
              "execution": "번들 구조를 조정하고 불필요한 JavaScript를 제거해 초기 전송량을 줄였습니다."
            }
          ]
        },
        {
          "name": "시대인재C 서비스 오픈 & 유지보수",
          "url": "https://www.sdijc.com/main/survival-pro",
          "highlighted": true,
          "summary": "자사 브랜드 도서, 모의고사 접수, 성적 조회 및 분석 기능을 제공하는 반응형 웹 서비스",
          "contribution": "공통 UI 컴포넌트와 레이아웃 설계, 모집 이벤트 페이지, 전시 페이지, 성적 조회 페이지 개발을 담당했습니다.",
          "techStack": ["Nuxt", "SCSS"],
          "team": "FE 2명, BE 2명, 디자이너 2명, 기획자 2명",
          "issues": [
            {
              "problem": "전시 페이지와 이벤트성 모집 페이지는 목적과 트래픽 특성이 달랐고, 특히 선착순 모집 페이지는 짧은 시간에 사용자가 집중돼 일반적인 방식으로 운영하면 서버 부하와 사용자 대기 경험 저하가 발생할 수 있었습니다.",
              "strategy": "페이지 목적에 따라 SSR/CSR 렌더링 전략을 분리하고, 모집 페이지는 서버 부담을 줄이면서도 대기 상태를 명확히 인지할 수 있도록 캐싱 전략과 로딩 UX를 함께 설계했습니다.",
              "execution": "전시·성적 조회 등 서버 렌더링이 필요한 화면은 SSR로 유지하고, 모집·이벤트 페이지는 CSR + S3 기반으로 구성했습니다. 선착순 모집 페이지에는 TTL 기반 캐싱을 적용하고, 실제 응답 대기 구간에 맞춘 로딩 화면을 구현했습니다.",
              "impact": "동시 접속 16,000명 규모의 모집 페이지를 안정적으로 운영하며 서버 리소스 부담을 낮췄고, 페이지 특성별 렌더링 전략 기준을 정리해 신규 페이지 개발과 수정 시 판단 기준을 명확히 만들었습니다.",
              "retrospective": "트래픽 대응은 기능 완성보다 병목 지점을 먼저 분리하는 설계가 핵심이었고, 렌더링 전략 기준을 초기부터 더 명확히 문서화했다면 운영 중 의사결정 비용을 더 줄일 수 있었겠다고 판단했습니다."
            },
            {
              "problem": "디자인이 확정되지 않은 상태에서 개발을 병행해야 했고, 특히 전시 페이지마다 자사 상품의 테마가 달라 화면 변경 범위와 재작업 비용이 커질 수 있었습니다.",
              "strategy": "디자인 변경에 유연하게 대응할 수 있도록 필요에 따라 조립하여 사용할 수 있는 구조를 우선했습니다.",
              "execution": "컴파운드 패턴 기반의 재사용 컴포넌트를 정의해 화면마다 필요한 요소를 조합해 사용할 수 있도록 했고, 로직은 관심사별 컴포지션으로 분리해 필요한 기능을 조립하는 방식으로 설계하고 구현했습니다.",
              "impact": "공통 UI와 반응형 유틸리티를 정비해 이후 화면 유지보수 속도와 일관성을 개선했습니다."
            },
            {
              "problem": "진행 중이던 프로젝트는 있었지만 기존 팀이 사라진 상태에서, 서비스를 안정적으로 오픈하고 운영해야 하는 문제가 발생했습니다.",
              "strategy": "빠른 운영 대응과 협업 일관성을 위해 코드 품질 규칙과 커밋 규칙을 표준화하고, 작업 히스토리를 추적할 수 있는 기준을 함께 정리했습니다.",
              "execution": {
                "text": "Nuxt.js 기반 JavaScript 프로젝트에 TypeScript 설정을 확장하고 API interface를 생성했으며, 페이지 interface와 매핑하는 mapper layer를 도입했습니다. 또한 일관된 코드 품질 유지를 위해 ESLint를 적용하고 git commit formatter를 개발·도입했습니다.",
                "link": {
                  "label": "git commit formatter",
                  "url": "https://253eosam.github.io/commit-from-branch/"
                }
              },
              "impact": "JavaScript 기반 코드에 TypeScript를 확장해 타입 안정성과 협업 생산성을 높였고, mapper layer 도입으로 API 응답값 정규화와 페이지 모델 변환 책임을 분리했습니다. 이를 통해 API 스펙 변경 시 페이지 컴포넌트 전체를 수정하지 않고 변환 계층만 조정할 수 있게 해 유지보수성과 대응 속도를 개선했습니다. 또한 작업 중인 Jira를 커밋에 자동 기입해 작업 히스토리와 코드 추적 용이성을 높였습니다.",
              "retrospective": "인수인계 문서는 주기적으로 최신화해야 하고, 그렇지 못한 경우에는 함수 호출부나 컴포저블 수준에서 코드의 의도와 목적을 드러내야 한다고 느꼈습니다. 또한 복잡한 워크플로우는 선언형 코드와 주석, Jira·Confluence 링크를 함께 남겨 히스토리를 추적할 수 있게 해야 정보가 부족한 상황에서도 빠르게 맥락을 복원할 수 있다고 판단했습니다."
            }
          ]
        }
      ]
    },
    {
      "company": "팀리부뜨",
      "logo": "/images/company/team-reboot.png",
      "role": "팀원",
      "department": "제품개발팀",
      "startDate": "2023-09",
      "endDate": "2024-12",
      "employmentType": "정규직",
      "description": "무역 사무업무 솔루션 제공",
      "projects": [
        {
          "name": "askyour.trade 서비스 오픈 및 유지보수",
          "url": "https://askyour.trade",
          "highlighted": true,
          "summary": "무역 사무 업무를 웹 서비스로 옮기기 위해 메일, 화물 모니터링, 전자도장 기능을 설계하고 운영한 B2B/B2C 프로젝트입니다.",
          "contribution": "FE 1명으로 제품 기능 설계부터 구현, 운영까지 담당했습니다. 메일 기능 구조 설계, 실시간 알림, 에디터 확장, 캔버스/PDF 기반 기능 개발을 단독 수행했습니다.",
          "techStack": ["React", "Styled-component", "react-query", "zustand"],
          "team": "FE 1명",
          "issues": [
            {
              "problem": "무역 실무자는 메일 확인, 화물 추적, 문서 날인 같은 반복 업무를 여러 도구에서 분산 처리하고 있었고, 이를 서비스 안으로 가져오려면 도메인 요구사항을 화면과 상태 구조로 정확히 번역해야 했습니다.",
              "strategy": "메일 기능은 레이아웃 기반 라우팅으로 화면 구조를 먼저 고정하고, editor·AI·알림 기능은 재사용 가능한 단위로 분리했습니다.",
              "execution": "Froala editor를 커스터마이징해 서명, 템플릿 기능을 추가했습니다.",
              "impact": "무역 실무자가 분산된 업무를 서비스 내부에서 이어서 처리할 수 있도록 제품 기능 범위를 확장했습니다.",
              "retrospective": "도메인 지식이 부족한 상태에서 기능을 만들기보다, 실무자 언어를 데이터 흐름으로 치환하는 과정이 가장 중요하다는 점을 배웠습니다."
            },
            {
              "problem": "FE 단독 담당 환경이라 기능 추가 속도만 높이면 구조가 빠르게 무너질 수 있어, 재사용성과 유지보수성을 고려한 설계 기준이 필요했습니다.",
              "strategy": "AI 기능은 custom hook과 atomic한 UI 조합으로 설계해 여러 페이지에서 같은 흐름을 재사용하도록 구성했습니다.",
              "execution": "AI 기반 기능을 custom hook으로 구현하고 3개 페이지에서 재사용 가능한 구조로 정리했습니다.",
              "impact": "FE 단독 환경에서도 재사용 구조를 먼저 잡아 메일과 AI 관련 기능을 여러 화면에 일관되게 적용했습니다.",
              "retrospective": "초기부터 이벤트와 상태 흐름 다이어그램을 더 체계적으로 남겼다면 이후 유지보수 속도를 더 높일 수 있었겠다고 판단했습니다."
            },
            {
              "strategy": "실시간성이 필요한 메일 알림은 SSE와 Web Notification API를 조합하고, 화물 모니터링과 전자도장은 브라우저 환경 제약을 고려한 별도 상태 흐름으로 설계했습니다.",
              "execution": "SSE + Web Notification API 기반 실시간 메일 수신 알림을 개발했습니다.",
              "impact": "브라우저 기반으로 전자도장과 문서 출력 흐름을 제공해 오프라인 문서 처리 단계를 서비스 안으로 끌어왔습니다."
            },
            {
              "execution": "관세청 유니패스번호 기반 수입화물 모니터링 페이지와 주기 조회 로직, popup 상태 동기화를 구현했습니다."
            },
            {
              "execution": "fabric.js + pdf.js 기반 전자도장 편집 기능과 PDF 출력 기능을 개발했습니다."
            }
          ]
        },
        {
          "name": "askyour.trade 어드민",
          "description": "askyour.trade 서비스 관리 어드민",
          "contribution": "FE 2명 중 운영 기능 개발과 관리 화면 개선을 담당했습니다.",
          "techStack": ["React", "Material-UI", "Styled-component", "react-query", "zustand"],
          "team": "FE 2명",
          "details": [
            { "text": "운영 기능 개발 및 유지보수를 담당했습니다." },
            { "text": "Material-UI 기반 관리 화면을 구현해 기능 추가와 유지보수 속도를 높였습니다." }
          ]
        }
      ]
    },
    {
      "company": "위메프",
      "logo": "/images/company/wemakeprice.jpg",
      "role": "팀원",
      "department": "프론트개발그룹 | FE백오피스팀",
      "startDate": "2020-07",
      "endDate": "2023-05",
      "employmentType": "정규직",
      "description": "이커머스",
      "projects": [
        {
          "name": "위메프 어드민 유지보수",
          "description": "위메프에 등록된 각 상품의 고유 아이디를 부여하여 동일한 상품을 비교하고 데이터 통일 목적",
          "contribution": "5명 조직에서 운영성 기능 개발, Vue 3 마이그레이션, 반복 작업 자동화 도구 개발에 참여했습니다.",
          "techStack": ["Vue.js", "Vuex", "Element-UI", "Hygen", "React"],
          "team": "5명",
          "details": [
            { "text": "장기 운영 중인 어드민 기능 개발과 유지보수를 담당했습니다." },
            { "text": "Vue 2 → Vue 3 마이그레이션과 일부 컴포넌트 리팩토링에 참여했습니다." },
            { "text": "반복되는 페이지 개발 패턴을 추상화해 CLI 자동 생성 도구를 만들어 개발 생산성을 높였습니다." }
          ]
        },
        {
          "name": "위메프 여행·레저 서비스 유지보수",
          "description": "위메프 여행, 숙박, 액티비티, 공연티켓을 판매하는 서비스",
          "contribution": "6명 조직에서 여행·레저 운영 기능 개발과 공연 티켓 프로젝트의 JSP → Vue 전환에 참여했습니다.",
          "techStack": ["Vue.js", "Vuex", "vue-property-decorator", "vue-class-component", "JSP", "jQuery"],
          "team": "6명",
          "details": [
            { "text": "여행·레저 서비스 기능 개발과 운영 이슈 대응을 담당했습니다." },
            { "text": "공연 티켓 프로젝트를 JSP에서 Vue로 전환해 팀 내 개발 환경과 스펙을 통일했습니다." }
          ]
        }
      ]
    }
  ],
  "certifications": [
    {
      "name": "정보처리기사",
      "organization": "한국산업인력공단",
      "date": "2019.05"
    }
  ],
  "education": [
    {
      "institution": "금오공과대학교",
      "major": "컴퓨터소프트웨어공학과",
      "period": "2013.03 - 2019.08",
      "degree": "학사"
    },
    {
      "institution": "운암고등학교",
      "period": "2010.03 - 2013.02"
    }
  ],
  "activities": [
    {
      "name": "사내 알고리즘 스터디",
      "organization": "(주)위메프",
      "period": "2022",
      "description": "JavaScript 알고리즘 스터디 진행",
      "details": [
        "기본적인 자료구조 개념 설명 및 구현 방법 학습",
        "알고리즘 풀이 방법 및 효율적인 접근 방식 공유"
      ],
      "link": { "label": "다룬 알고리즘 및 자료구조", "url": "https://253eosam.github.io/algo-wiki/" }
    },
    {
      "name": "SSAFY 2기(구미)",
      "organization": "삼성전자",
      "period": "2019",
      "description": "SSAFY(Samsung Software Academy For Youth)는 삼성에서 운영하는 소프트웨어 개발자 양성 과정으로, 약 1년간 집중적인 교육과 실무 프로젝트를 수행하는 프로그램이다.",
      "details": [
        "알고리즘 문제 해결 능력 향상, 풀스택 웹 개발, 팀 프로젝트 경험, 협업 툴 활용 등을 중점적으로 학습"
      ]
    }
  ]
} satisfies ResumeData;

export default resume;
