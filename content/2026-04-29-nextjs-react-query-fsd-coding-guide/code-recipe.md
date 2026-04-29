# Next.js + FSD + React Query Code Recipe

## Core Rule

```txt
조회는 entities
변경은 features
독립적인 화면 조합은 widgets
라우팅/배치/route 전용 섹션은 app
공통 재료는 shared
```

## Layer Responsibility

```txt
app       = 라우팅, 페이지 조립, server prefetch, route 전용 UI
widgets   = 독립적인 화면 블록, entity/feature 조합 단위
features  = 사용자 행동, 동사로 표현되는 기능
entities  = 비즈니스 도메인, 명사로 표현되는 대상
shared    = 공통 인프라, primitive UI
```

`entities`와 `features`는 **무엇과 행동**으로 구분한다.

```txt
entities
= transaction, user, member, category
= 시스템이 다루는 대상
= 명사로 표현되는 것

features
= create-transaction, delete-transaction, invite-member
= 사용자가 수행하는 행동
= 동사로 표현되는 것
```

## app/_ui vs widgets

```txt
app/[route]/_ui
= 특정 route에서만 쓰는 가벼운 섹션
= 정적 소개, 단순 배치, page 전용 JSX 분리

widgets
= 여러 하위 레이어를 조합한 화면 블록
= 데이터 조회, 화면 상태, feature action, entity UI를 연결하는 단위
```

## Query Layout

```txt
entities/transaction/
  api/
    get-transactions.ts
    get-transaction.ts
  model/
    query-keys.ts
    queries.ts
    use-transactions.ts
    use-transaction.ts
```

조회 API와 query option은 `entities`에 둔다.

```ts
// entities/transaction/model/query-keys.ts
export const transactionQueryKeys = {
  all: ['transactions'] as const,
  lists: () => [...transactionQueryKeys.all, 'list'] as const,
  list: (type: TransactionType) =>
    [...transactionQueryKeys.lists(), type] as const,
  details: () => [...transactionQueryKeys.all, 'detail'] as const,
  detail: (id: string) => [...transactionQueryKeys.details(), id] as const,
};
```

```ts
// entities/transaction/model/queries.ts
export const transactionQueries = {
  list: (type: TransactionType) =>
    queryOptions({
      queryKey: transactionQueryKeys.list(type),
      queryFn: () => getTransactions({ type }),
      staleTime: 1000 * 60,
    }),
};
```

## Mutation Layout

생성/수정/삭제 mutation은 `features`에 둔다.

```txt
features/
  create-transaction/
  update-transaction/
  delete-transaction/
```

행동이 명확한 feature UI는 보통 자기 feature의 mutation hook을 내부에서 호출한다.

```txt
features/delete-transaction/model/use-delete-transaction.ts
→ useMutation으로 mutate 생성

features/delete-transaction/ui/delete-transaction-button.tsx
→ useDeleteTransaction() 호출
→ mutate를 버튼 이벤트에 연결

widgets/transaction-list/ui/transaction-list-section.tsx
→ DeleteTransactionButton을 화면에 배치
```

widget이 `mutate`를 만들어 feature UI에 props로 넘기는 구조가 기본은 아니다. widget은 feature UI를 조합하고, 행동의 구현은 feature 내부에 둔다.

```txt
행동이 명확한 feature UI
→ feature 내부에서 mutation hook 호출

범용 UI / presentational component
→ props로 상태와 핸들러를 받음
```

```ts
// features/create-transaction/model/use-create-transaction.ts
export function useCreateTransaction() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: createTransaction,
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: transactionQueryKeys.list(variables.type),
      });
    },
  });
}
```

## Checklist

```txt
shared인가?
- 도메인 없는 재료인가?
- 여러 곳에서 그대로 쓸 수 있는가?

entities인가?
- 비즈니스 객체인가?
- 명사로 표현되는 대상인가?
- 조회 중심인가?

features인가?
- 사용자 행동인가?
- 동사로 표현되는 기능인가?
- mutation이 있는가?

widgets인가?
- entity와 feature를 조합하는가?
- 검색 + 리스트 + 액션처럼 화면 단위인가?

app인가?
- 라우팅인가?
- page/layout인가?
- route 전용 _ui인가?
```

## Forbidden

```txt
shared에서 도메인 API 호출 ❌
entities에서 create/update/delete mutation 구현 ❌
widgets에서 직접 fetch 호출 ❌
page.tsx에 비즈니스 로직 작성 ❌
feature UI에서 fetch 직접 호출 ❌
queryKey를 문자열로 직접 작성 ❌
수입/지출을 거의 같은 코드로 각각 복사 ❌
```
