---
title: 'next.js + react-query + FSD coding guide'
date: '2026-04-29'
category: 'frontend'
tags: ['Next.js', 'React Query', 'FSD', 'App Router', 'architecture']
description: 'Next.js App Router, Feature-Sliced Design, React Query를 함께 사용할 때의 코드 구조와 작성 기준을 정리한다.'
---

# Next.js + FSD + React Query 개발 지침서

> 한줄 정의: 조회는 entities, 변경은 features, 독립적인 화면 조합은 widgets, 라우팅과 route 전용 섹션은 app, 공통 재료는 shared에 둔다.

## 목차

- [개요](#개요)
- [이 글을 읽는 방법](#이-글을-읽는-방법)
- [기본 원칙](#기본-원칙)
- [추천 폴더 구조](#추천-폴더-구조)
- [shared 규칙](#shared-규칙)
- [entities 규칙](#entities-규칙)
- [transaction entity 설계 예시](#transaction-entity-설계-예시)
- [Query Key 설계 규칙](#query-key-설계-규칙)
- [Queries 설계 규칙](#queries-설계-규칙)
- [entities/ui 규칙](#entitiesui-규칙)
- [features 규칙](#features-규칙)
- [생성 mutation 예시](#생성-mutation-예시)
- [삭제 mutation과 optimistic update 예시](#삭제-mutation과-optimistic-update-예시)
- [수정 mutation과 optimistic update 예시](#수정-mutation과-optimistic-update-예시)
- [search feature 예시](#search-feature-예시)
- [widgets 규칙](#widgets-규칙)
- [transaction-list widget 예시](#transaction-list-widget-예시)
- [app 규칙](#app-규칙)
- [지출 페이지 예시](#지출-페이지-예시)
- [수입 페이지 예시](#수입-페이지-예시)
- [사용 방법: 새 목록 페이지를 추가할 때](#사용-방법-새-목록-페이지를-추가할-때)
- [사용 방법: 새 feature를 추가할 때](#사용-방법-새-feature를-추가할-때)
- [사용 방법: 새 entity UI를 추가할 때](#사용-방법-새-entity-ui를-추가할-때)
- [사용 방법: page section을 분리할 때](#사용-방법-page-section을-분리할-때)
- [사용 방법: React Query prefetch를 적용할 때](#사용-방법-react-query-prefetch를-적용할-때)
- [레이어 판단 체크리스트](#레이어-판단-체크리스트)
- [금지 패턴](#금지-패턴)
- [요약](#요약)
- [참고 자료](#참고-자료)

## 개요

이 문서는 Next.js App Router, Feature-Sliced Design(FSD), React Query를 한 프로젝트에서 함께 사용할 때의 코드 배치 기준을 정리한다.

세 도구는 서로 다른 문제를 해결한다. Next.js App Router는 라우팅과 서버 렌더링 경계를 제공하고, React Query는 클라이언트에서 서버 상태를 관리하며, FSD는 코드를 관심사와 의존성 방향에 따라 나누는 기준을 제공한다. 문제는 이 셋을 함께 쓰면 `page.tsx`, query hook, mutation, UI 컴포넌트가 어느 폴더에 있어야 하는지 금방 애매해진다는 점이다.

이 글의 목적은 그 애매함을 줄이는 것이다. 특히 수입/지출 내역 화면을 예시로 삼아, 조회는 어디에 두고 변경은 어디에 두는지, `app/[route]/_ui`와 `widgets`는 어떻게 구분하는지, query key는 어떻게 일관되게 관리하는지를 설명한다.

목표는 다음과 같다.

- 같은 관심사의 코드는 같은 위치에 둔다.
- page는 조립만 담당한다.
- 조회 API와 query option은 `entities`에 두고, 생성/수정/삭제 mutation은 `features`에 둔다.
- query key를 일관되게 관리한다.
- 이 문서에서는 수입과 지출처럼 데이터 구조와 화면 흐름이 비슷한 도메인을 추상화하는 예시로, `income`, `expense`를 따로 복사하지 않고 `transaction`과 `type`으로 묶는 방식을 사용한다.

## 이 글을 읽는 방법

이 글은 FSD 자체를 처음부터 설명하는 문서라기보다, Next.js App Router와 React Query를 이미 쓰는 프로젝트에서 폴더와 책임을 정할 때 참고하는 가이드에 가깝다.

앞부분의 [기본 원칙](#기본-원칙)과 [추천 폴더 구조](#추천-폴더-구조)는 전체 구조를 잡기 위한 기준이다. 중간의 `entities`, `features`, `widgets`, `app` 섹션은 각 레이어에 어떤 코드가 들어가는지 보여준다. 마지막의 [레이어 판단 체크리스트](#레이어-판단-체크리스트)는 실제 구현 중 파일 위치가 헷갈릴 때 빠르게 확인하는 용도다.

예시 코드는 완성된 애플리케이션 코드라기보다 책임 배치를 설명하기 위한 샘플이다. 실제 프로젝트에서는 인증, 에러 처리, 폼 검증, 디자인 시스템에 맞춰 세부 구현을 조정한다.

## 기본 원칙

프로젝트는 다음 레이어를 기준으로 나눈다.

```txt
app       = 라우팅, 페이지 조립, server prefetch, route 전용 UI
widgets   = 독립적인 화면 블록, entity/feature 조합 단위
features  = 사용자 행동, 동사로 표현되는 기능
entities  = 비즈니스 도메인, 명사로 표현되는 대상
shared    = 공통 인프라, primitive UI
```

`entities`와 `features`를 구분할 때는 **무엇과 행동**으로 나누어 생각하면 쉽다. `transaction`, `user`, `category`처럼 시스템이 다루는 대상은 명사에 가까우므로 `entities`에 둔다. `create-transaction`, `delete-transaction`, `invite-member`처럼 사용자가 무엇을 하는지는 동사에 가까우므로 `features`에 둔다.

`app/[route]/_ui`와 `widgets`는 구분한다. `page.tsx`를 읽기 쉽게 나누기 위한 route 전용 섹션은 `app/[route]/_ui`에 둔다. 서버 상태, 클라이언트 상태, 사용자 행동, entity UI를 묶어 하나의 독립적인 화면 블록이 되면 `widgets`에 둔다.

의존성 방향은 항상 아래로만 흐른다.

```txt
app
 ↓
widgets
 ↓
features
 ↓
entities
 ↓
shared
```

반대 방향 import는 금지한다.

```txt
shared → entities ❌
entities → features ❌
features → widgets ❌
widgets → app ❌
```

## 추천 폴더 구조

```txt
src/
  app/
    expenses/
      page.tsx
      _ui/
        expense-page-header.tsx
    incomes/
      page.tsx
    home/
      page.tsx
      _ui/
        hero-section.tsx
        intro-section.tsx

  shared/
    api/
      server-fetch.ts
    ui/
      button.tsx
      input.tsx
      badge.tsx
      section.tsx
    lib/
      cn.ts
    constants/
      routes.ts

  entities/
    transaction/
      api/
        get-transactions.ts
        get-transaction.ts
      model/
        types.ts
        query-keys.ts
        queries.ts
        use-transactions.ts
        use-transaction.ts
        filter-transactions.ts
      ui/
        transaction-row.tsx
        transaction-badge.tsx

  features/
    create-transaction/
      api/
        create-transaction.ts
      model/
        use-create-transaction.ts
      ui/
        create-transaction-form.tsx

    update-transaction/
      api/
        update-transaction.ts
      model/
        use-update-transaction.ts
      ui/
        update-transaction-dialog.tsx

    delete-transaction/
      api/
        delete-transaction.ts
      model/
        use-delete-transaction.ts
      ui/
        delete-transaction-button.tsx

    search-transaction/
      ui/
        transaction-search-input.tsx

  widgets/
    transaction-list/
      model/
        use-transaction-list.ts
      ui/
        transaction-list-section.tsx
```

## shared 규칙

`shared`에는 도메인 지식이 없는 코드를 둔다.

### 들어갈 수 있는 것

```txt
shared/ui/button.tsx
shared/ui/badge.tsx
shared/ui/input.tsx
shared/ui/section.tsx
shared/api/server-fetch.ts
shared/lib/cn.ts
shared/constants/routes.ts
```

### 넣으면 안 되는 것

```txt
shared/ui/transaction-badge.tsx ❌
shared/api/get-transactions.ts ❌
shared/lib/calculate-settlement.ts ❌
```

도메인 이름이 들어가거나 비즈니스 규칙이 포함되면 `shared`가 아니다.

### 예시: shared primitive Badge

```tsx
// shared/ui/badge.tsx
import type { ReactNode } from 'react';

export type BadgeVariant = 'default' | 'success' | 'danger' | 'warning';

type BadgeProps = {
  children: ReactNode;
  variant?: BadgeVariant;
};

export function Badge({ children, variant = 'default' }: BadgeProps) {
  return (
    <span data-variant={variant} className="rounded-full px-2 py-1 text-xs">
      {children}
    </span>
  );
}
```

### 예시: shared server fetch

```ts
// shared/api/server-fetch.ts
export async function serverFetch<T>(
  path: string,
  init?: RequestInit
): Promise<T> {
  const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}${path}`, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...init?.headers,
    },
  });

  if (!res.ok) {
    throw new Error('API 요청에 실패했습니다.');
  }

  return res.json();
}
```

## entities 규칙

`entities`는 비즈니스 객체를 표현한다. 이름은 보통 명사로 잡는다. 즉, 사용자가 조작하는 행동이 아니라 애플리케이션이 다루는 "무엇"에 해당한다.

예:

```txt
transaction
user
member
category
trip
```

예를 들어 `transaction`은 거래내역이라는 대상이고, `category`는 카테고리라는 대상이다. 이 대상의 타입, 조회 API, query key, 표시 UI는 같은 도메인 지식을 공유하므로 entity 안에 모은다.

### entities에 들어가는 것

```txt
조회 API
queryKey
queryOptions
도메인 타입
도메인 표시 UI
순수 도메인 함수
```

### entities에 넣지 않는 것

```txt
생성
수정
삭제
로그인
정산 실행
공유
초대
```

이런 행동은 `features`에 둔다.

## transaction entity 설계 예시

수입과 지출은 별도 entity로 쪼개기보다 `transaction`으로 추상화한다.

```ts
// entities/transaction/model/types.ts
export type TransactionType = 'income' | 'expense';

export type Transaction = {
  id: string;
  type: TransactionType;
  title: string;
  amount: number;
  category: string;
  occurredAt: string;
  memo?: string;
};
```

### 목록 조회 API

```ts
// entities/transaction/api/get-transactions.ts
import { serverFetch } from '@/shared/api/server-fetch';
import type { Transaction, TransactionType } from '../model/types';

type GetTransactionsParams = {
  type: TransactionType;
};

export function getTransactions({ type }: GetTransactionsParams) {
  return serverFetch<Transaction[]>(`/transactions?type=${type}`, {
    next: {
      revalidate: 60,
    },
  });
}
```

### 상세 조회 API

```ts
// entities/transaction/api/get-transaction.ts
import { serverFetch } from '@/shared/api/server-fetch';
import type { Transaction } from '../model/types';

type GetTransactionParams = {
  id: string;
};

export function getTransaction({ id }: GetTransactionParams) {
  return serverFetch<Transaction>(`/transactions/${id}`, {
    next: {
      revalidate: 60,
    },
  });
}
```

## Query Key 설계 규칙

query key와 query option은 분리한다. query key 문자열을 여러 파일에 직접 작성하지 않는다.

```ts
// entities/transaction/model/query-keys.ts
import type { TransactionType } from './types';

export const transactionQueryKeys = {
  all: ['transactions'] as const,

  lists: () => [...transactionQueryKeys.all, 'list'] as const,

  list: (type: TransactionType) =>
    [...transactionQueryKeys.lists(), type] as const,

  details: () => [...transactionQueryKeys.all, 'detail'] as const,

  detail: (id: string) => [...transactionQueryKeys.details(), id] as const,
};
```

이렇게 분리하면 캐시 무효화가 명확해진다.

```ts
queryClient.invalidateQueries({
  queryKey: transactionQueryKeys.all,
});

queryClient.invalidateQueries({
  queryKey: transactionQueryKeys.lists(),
});

queryClient.invalidateQueries({
  queryKey: transactionQueryKeys.list('expense'),
});

queryClient.invalidateQueries({
  queryKey: transactionQueryKeys.detail(transactionId),
});
```

## Queries 설계 규칙

```ts
// entities/transaction/model/queries.ts
import { queryOptions } from '@tanstack/react-query';

import { getTransaction } from '../api/get-transaction';
import { getTransactions } from '../api/get-transactions';
import { transactionQueryKeys } from './query-keys';
import type { TransactionType } from './types';

export const transactionQueries = {
  list: (type: TransactionType) =>
    queryOptions({
      queryKey: transactionQueryKeys.list(type),
      queryFn: () => getTransactions({ type }),
      staleTime: 1000 * 60,
    }),

  detail: (id: string) =>
    queryOptions({
      queryKey: transactionQueryKeys.detail(id),
      queryFn: () => getTransaction({ id }),
      staleTime: 1000 * 60,
    }),
};
```

### Client hook

```ts
// entities/transaction/model/use-transactions.ts
'use client';

import { useQuery } from '@tanstack/react-query';
import { transactionQueries } from './queries';
import type { TransactionType } from './types';

export function useTransactions(type: TransactionType) {
  return useQuery(transactionQueries.list(type));
}
```

```ts
// entities/transaction/model/use-transaction.ts
'use client';

import { useQuery } from '@tanstack/react-query';
import { transactionQueries } from './queries';

export function useTransaction(id: string) {
  return useQuery(transactionQueries.detail(id));
}
```

## entities/ui 규칙

`entities/ui`는 도메인 데이터를 보여주는 최소 표현 UI다.

### 좋은 예시

```tsx
// entities/transaction/ui/transaction-row.tsx
import type { Transaction } from '../model/types';

type TransactionRowProps = {
  transaction: Transaction;
};

export function TransactionRow({ transaction }: TransactionRowProps) {
  const amountPrefix = transaction.type === 'income' ? '+' : '-';

  return (
    <li className="flex items-center justify-between rounded-xl border p-4">
      <div>
        <p className="font-medium">{transaction.title}</p>
        <p className="text-sm text-gray-500">
          {transaction.category} · {transaction.occurredAt}
        </p>
      </div>

      <strong>
        {amountPrefix}
        {transaction.amount.toLocaleString()}원
      </strong>
    </li>
  );
}
```

### primitive를 이용한 domain UI 예시

```tsx
// entities/transaction/ui/transaction-badge.tsx
import { Badge } from '@/shared/ui/badge';
import type { TransactionType } from '../model/types';

type TransactionBadgeProps = {
  type: TransactionType;
};

export function TransactionBadge({ type }: TransactionBadgeProps) {
  return (
    <Badge variant={type === 'income' ? 'success' : 'danger'}>
      {type === 'income' ? '수입' : '지출'}
    </Badge>
  );
}
```

### entities/ui에 넣으면 안 되는 것

```tsx
// ❌ entities/transaction/ui/delete-transaction-button.tsx
export function DeleteTransactionButton() {
  return <button>삭제</button>;
}
```

삭제는 사용자 행동이므로 `features/delete-transaction`으로 이동한다.

## features 규칙

`features`는 사용자 행동 단위로 만든다. 이름은 보통 동사로 시작한다. 즉, 특정 도메인 대상에 대해 사용자가 "무엇을 하는가"를 표현한다.

예:

```txt
create-transaction
update-transaction
delete-transaction
search-transaction
settle-payment
invite-member
```

예를 들어 `transaction`은 entity지만, 거래내역을 생성하는 행동은 `create-transaction` feature다. `member`는 entity지만, 멤버를 초대하는 행동은 `invite-member` feature다.

### features에 들어가는 것

```txt
mutation API
useMutation hook
invalidate 처리
optimistic update
action button
form
dialog
```

## 생성 mutation 예시

### API

```ts
// features/create-transaction/api/create-transaction.ts
import { serverFetch } from '@/shared/api/server-fetch';
import type { Transaction, TransactionType } from '@/entities/transaction/model/types';

type CreateTransactionPayload = {
  type: TransactionType;
  title: string;
  amount: number;
  category: string;
  occurredAt: string;
  memo?: string;
};

export function createTransaction(payload: CreateTransactionPayload) {
  return serverFetch<Transaction>('/transactions', {
    method: 'POST',
    body: JSON.stringify(payload),
  });
}
```

### Mutation hook

```ts
// features/create-transaction/model/use-create-transaction.ts
'use client';

import { useMutation, useQueryClient } from '@tanstack/react-query';

import { transactionQueryKeys } from '@/entities/transaction/model/query-keys';
import { createTransaction } from '../api/create-transaction';

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

## 삭제 mutation과 optimistic update 예시

삭제는 optimistic update와 궁합이 좋다.

```txt
1. 삭제 버튼 클릭
2. UI에서 먼저 제거
3. API 실패 시 이전 목록 복구
4. 성공/실패와 관계없이 최종 refetch
```

```ts
// features/delete-transaction/api/delete-transaction.ts
import { serverFetch } from '@/shared/api/server-fetch';

export function deleteTransaction({ id }: { id: string }) {
  return serverFetch<void>(`/transactions/${id}`, {
    method: 'DELETE',
  });
}
```

```ts
// features/delete-transaction/model/use-delete-transaction.ts
'use client';

import { useMutation, useQueryClient } from '@tanstack/react-query';

import { transactionQueryKeys } from '@/entities/transaction/model/query-keys';
import type {
  Transaction,
  TransactionType,
} from '@/entities/transaction/model/types';
import { deleteTransaction } from '../api/delete-transaction';

type DeleteTransactionVariables = {
  id: string;
  type: TransactionType;
};

export function useDeleteTransaction() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id }: DeleteTransactionVariables) =>
      deleteTransaction({ id }),

    onMutate: async ({ id, type }) => {
      const queryKey = transactionQueryKeys.list(type);

      await queryClient.cancelQueries({ queryKey });

      const previousTransactions =
        queryClient.getQueryData<Transaction[]>(queryKey);

      queryClient.setQueryData<Transaction[]>(queryKey, (old = []) =>
        old.filter((transaction) => transaction.id !== id)
      );

      return {
        previousTransactions,
      };
    },

    onError: (_error, variables, context) => {
      if (!context?.previousTransactions) return;

      queryClient.setQueryData(
        transactionQueryKeys.list(variables.type),
        context.previousTransactions
      );
    },

    onSettled: (_data, _error, variables) => {
      queryClient.invalidateQueries({
        queryKey: transactionQueryKeys.list(variables.type),
      });
    },
  });
}
```

## 수정 mutation과 optimistic update 예시

수정은 목록과 상세 캐시를 모두 갱신해야 한다.

```ts
// features/update-transaction/model/use-update-transaction.ts
'use client';

import { useMutation, useQueryClient } from '@tanstack/react-query';

import { transactionQueryKeys } from '@/entities/transaction/model/query-keys';
import type {
  Transaction,
  TransactionType,
} from '@/entities/transaction/model/types';
import { updateTransaction } from '../api/update-transaction';

type UpdateTransactionVariables = {
  id: string;
  type: TransactionType;
  payload: Partial<Transaction>;
};

export function useUpdateTransaction() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, payload }: UpdateTransactionVariables) =>
      updateTransaction({ id, payload }),

    onMutate: async ({ id, type, payload }) => {
      const listQueryKey = transactionQueryKeys.list(type);
      const detailQueryKey = transactionQueryKeys.detail(id);

      await Promise.all([
        queryClient.cancelQueries({ queryKey: listQueryKey }),
        queryClient.cancelQueries({ queryKey: detailQueryKey }),
      ]);

      const previousList = queryClient.getQueryData<Transaction[]>(listQueryKey);
      const previousDetail =
        queryClient.getQueryData<Transaction>(detailQueryKey);

      queryClient.setQueryData<Transaction[]>(listQueryKey, (old = []) =>
        old.map((transaction) =>
          transaction.id === id ? { ...transaction, ...payload } : transaction
        )
      );

      queryClient.setQueryData<Transaction>(detailQueryKey, (old) =>
        old ? { ...old, ...payload } : old
      );

      return {
        previousList,
        previousDetail,
      };
    },

    onError: (_error, variables, context) => {
      if (context?.previousList) {
        queryClient.setQueryData(
          transactionQueryKeys.list(variables.type),
          context.previousList
        );
      }

      if (context?.previousDetail) {
        queryClient.setQueryData(
          transactionQueryKeys.detail(variables.id),
          context.previousDetail
        );
      }
    },

    onSettled: (_data, _error, variables) => {
      queryClient.invalidateQueries({
        queryKey: transactionQueryKeys.list(variables.type),
      });

      queryClient.invalidateQueries({
        queryKey: transactionQueryKeys.detail(variables.id),
      });
    },
  });
}
```

## search feature 예시

검색은 서버 데이터를 변경하지 않지만, 사용자 행동에 의한 UI 상태 변화이므로 feature로 둔다.

```tsx
// features/search-transaction/ui/transaction-search-input.tsx
'use client';

type TransactionSearchInputProps = {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
};

export function TransactionSearchInput({
  value,
  onChange,
  placeholder = '내역 검색',
}: TransactionSearchInputProps) {
  return (
    <input
      value={value}
      onChange={(event) => onChange(event.target.value)}
      placeholder={placeholder}
      className="w-full rounded-xl border px-4 py-3 outline-none"
    />
  );
}
```

검색 필터링 함수는 transaction 도메인 규칙이므로 entity에 둔다.

```ts
// entities/transaction/model/filter-transactions.ts
import type { Transaction } from './types';

export function filterTransactions(
  transactions: Transaction[],
  keyword: string
) {
  const normalizedKeyword = keyword.trim().toLowerCase();

  if (!normalizedKeyword) {
    return transactions;
  }

  return transactions.filter((transaction) =>
    [
      transaction.title,
      transaction.category,
      transaction.occurredAt,
      transaction.memo,
      String(transaction.amount),
    ]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
      .includes(normalizedKeyword)
  );
}
```

## widgets 규칙

`widgets`는 페이지를 구성하는 의미 있는 화면 블록이다. 단순히 `page.tsx`를 작게 나누기 위한 섹션을 모두 `widgets`로 올리지는 않는다.

기준은 "페이지 섹션인가?"보다 "독립적인 기능/데이터/조합 단위인가?"에 가깝다.

### app/[route]/_ui와 widgets의 차이

```txt
app/[route]/_ui
= 특정 route에서만 쓰는 가벼운 섹션
= 정적 소개, 단순 배치, page 전용 JSX 분리

widgets
= 여러 하위 레이어를 조합한 화면 블록
= 데이터 조회, 화면 상태, feature action, entity UI를 연결하는 단위
```

예를 들어 `HeroSection`, `IntroSection`, `PricingSection`처럼 해당 page의 문맥에서만 의미가 있는 정적 섹션은 `app/home/_ui`에 둔다. 반면 `TransactionListSection`처럼 조회 hook, 검색 상태, entity row, 삭제 feature를 함께 묶는 섹션은 `widgets`에 둔다.

### widgets 역할

```txt
독립적인 화면 블록 구성
entities UI 조합
features UI 조합
화면용 상태 관리
검색 결과 필터링 연결
route와 무관하게 재사용 가능한 화면 블록 제공
```

### widgets에 넣으면 안 되는 것

```txt
직접 API 호출 ❌
mutation 직접 구현 ❌
query key 직접 작성 ❌
비즈니스 핵심 로직 직접 작성 ❌
```

## transaction-list widget 예시

```tsx
// widgets/transaction-list/ui/transaction-list-section.tsx
'use client';

import { useMemo, useState } from 'react';

import { filterTransactions } from '@/entities/transaction/model/filter-transactions';
import { useTransactions } from '@/entities/transaction/model/use-transactions';
import type { TransactionType } from '@/entities/transaction/model/types';
import { TransactionRow } from '@/entities/transaction/ui/transaction-row';
import { DeleteTransactionButton } from '@/features/delete-transaction/ui/delete-transaction-button';
import { TransactionSearchInput } from '@/features/search-transaction/ui/transaction-search-input';

type TransactionListSectionProps = {
  type: TransactionType;
  title: string;
  description: string;
  searchPlaceholder: string;
  emptyMessage: string;
};

export function TransactionListSection({
  type,
  title,
  description,
  searchPlaceholder,
  emptyMessage,
}: TransactionListSectionProps) {
  const [keyword, setKeyword] = useState('');
  const { data: transactions = [], isLoading } = useTransactions(type);

  const filteredTransactions = useMemo(
    () => filterTransactions(transactions, keyword),
    [transactions, keyword]
  );

  if (isLoading) {
    return <div>{title}을 불러오는 중입니다.</div>;
  }

  return (
    <section className="space-y-4">
      <div>
        <h1 className="text-2xl font-bold">{title}</h1>
        <p className="text-sm text-gray-500">{description}</p>
      </div>

      <TransactionSearchInput
        value={keyword}
        onChange={setKeyword}
        placeholder={searchPlaceholder}
      />

      {filteredTransactions.length > 0 ? (
        <ul className="space-y-3">
          {filteredTransactions.map((transaction) => (
            <li key={transaction.id} className="flex items-center gap-2">
              <TransactionRow transaction={transaction} />
              <DeleteTransactionButton
                id={transaction.id}
                type={transaction.type}
              />
            </li>
          ))}
        </ul>
      ) : (
        <div className="rounded-xl border p-6 text-center text-gray-500">
          {emptyMessage}
        </div>
      )}
    </section>
  );
}
```

## app 규칙

`app`은 라우팅과 페이지 조립을 담당한다. route 전용의 가벼운 섹션은 `app/[route]/_ui`에 둘 수 있다.

### app에서 하는 일

```txt
QueryClient 생성
prefetchQuery 실행
dehydrate
HydrationBoundary 적용
widget 배치
route 전용 section 배치
metadata 정의
```

### app에서 하지 않는 일

```txt
복잡한 데이터 가공 ❌
mutation 구현 ❌
fetch 함수를 직접 작성 ❌
query key 문자열 직접 작성 ❌
```

## 지출 페이지 예시

```tsx
// app/expenses/page.tsx
import {
  HydrationBoundary,
  QueryClient,
  dehydrate,
} from '@tanstack/react-query';

import { transactionQueries } from '@/entities/transaction/model/queries';
import { TransactionListSection } from '@/widgets/transaction-list/ui/transaction-list-section';

export default async function ExpensesPage() {
  const queryClient = new QueryClient();

  await queryClient.prefetchQuery(transactionQueries.list('expense'));

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <main className="mx-auto max-w-3xl px-4 py-8">
        <TransactionListSection
          type="expense"
          title="지출 내역"
          description="사용한 금액을 검색하고 확인할 수 있습니다."
          searchPlaceholder="지출 내역 검색"
          emptyMessage="검색된 지출 내역이 없습니다."
        />
      </main>
    </HydrationBoundary>
  );
}
```

## 수입 페이지 예시

```tsx
// app/incomes/page.tsx
import {
  HydrationBoundary,
  QueryClient,
  dehydrate,
} from '@tanstack/react-query';

import { transactionQueries } from '@/entities/transaction/model/queries';
import { TransactionListSection } from '@/widgets/transaction-list/ui/transaction-list-section';

export default async function IncomesPage() {
  const queryClient = new QueryClient();

  await queryClient.prefetchQuery(transactionQueries.list('income'));

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <main className="mx-auto max-w-3xl px-4 py-8">
        <TransactionListSection
          type="income"
          title="수입 내역"
          description="들어온 금액을 검색하고 확인할 수 있습니다."
          searchPlaceholder="수입 내역 검색"
          emptyMessage="검색된 수입 내역이 없습니다."
        />
      </main>
    </HydrationBoundary>
  );
}
```

## 사용 방법: 새 목록 페이지를 추가할 때

예: `카테고리별 거래내역 페이지`를 추가한다고 가정한다.

이미 `transactionQueries.list(type)`으로 충분하면 새 entity API를 만들지 않는다. 카테고리 조건이 필요하면 query를 확장한다.

```ts
// entities/transaction/api/get-transactions.ts
type GetTransactionsParams = {
  type?: TransactionType;
  categoryId?: string;
};

export function getTransactions({ type, categoryId }: GetTransactionsParams) {
  const searchParams = new URLSearchParams();

  if (type) searchParams.set('type', type);
  if (categoryId) searchParams.set('categoryId', categoryId);

  return serverFetch<Transaction[]>(
    `/transactions?${searchParams.toString()}`,
    {
      next: {
        revalidate: 60,
      },
    }
  );
}
```

```ts
// entities/transaction/model/query-keys.ts
listByCategory: (categoryId: string) =>
  [...transactionQueryKeys.lists(), 'category', categoryId] as const,
```

```ts
// entities/transaction/model/queries.ts
listByCategory: (categoryId: string) =>
  queryOptions({
    queryKey: transactionQueryKeys.listByCategory(categoryId),
    queryFn: () => getTransactions({ categoryId }),
    staleTime: 1000 * 60,
  }),
```

단, `TransactionListSection`이 내부에서 `useTransactions(type)`만 쓰고 있다면 `categoryId`를 반영하지 못한다. 이때는 widget props를 query 기준으로 확장한다.

```tsx
type TransactionListSectionProps = {
  queryOptions: ReturnType<typeof transactionQueries.list>;
  title: string;
  description: string;
  searchPlaceholder: string;
  emptyMessage: string;
};
```

## 사용 방법: 새 feature를 추가할 때

예: `거래내역 즐겨찾기` 기능을 추가한다고 가정한다.

### 1단계: feature 이름을 동사로 정한다

```txt
features/toggle-transaction-favorite
```

### 2단계: API를 만든다

```ts
// features/toggle-transaction-favorite/api/toggle-transaction-favorite.ts
import { serverFetch } from '@/shared/api/server-fetch';
import type { Transaction } from '@/entities/transaction/model/types';

type ToggleTransactionFavoriteParams = {
  id: string;
  isFavorite: boolean;
};

export function toggleTransactionFavorite({
  id,
  isFavorite,
}: ToggleTransactionFavoriteParams) {
  return serverFetch<Transaction>(`/transactions/${id}/favorite`, {
    method: 'PATCH',
    body: JSON.stringify({ isFavorite }),
  });
}
```

## 사용 방법: 새 entity UI를 추가할 때

primitive는 `shared`에 둔다.

```tsx
// shared/ui/badge.tsx
export function Badge({ children }: { children: React.ReactNode }) {
  return <span className="rounded-full px-2 py-1">{children}</span>;
}
```

도메인 의미가 붙으면 entity에 둔다.

```tsx
// entities/category/ui/category-badge.tsx
import { Badge } from '@/shared/ui/badge';
import type { Category } from '../model/types';

type CategoryBadgeProps = {
  category: Category;
};

export function CategoryBadge({ category }: CategoryBadgeProps) {
  return <Badge>{category.name}</Badge>;
}
```

## 사용 방법: page section을 분리할 때

페이지 section을 무조건 widget으로 만들 필요는 없다.

단순히 특정 page의 JSX를 정리하기 위해 나눈 섹션이라면 `app/[route]/_ui`에 둔다. 해당 섹션이 서버 상태, 클라이언트 상태, 사용자 행동, entity/feature 조합을 하나의 화면 단위로 묶을 때 `widgets`로 올린다.

```txt
app/
  home/
    page.tsx
    _ui/
      hero-section.tsx
      intro-section.tsx
      pricing-section.tsx
```

```tsx
// app/home/_ui/hero-section.tsx
export function HeroSection() {
  return (
    <section>
      <h1>여행 정산을 쉽게 관리하세요</h1>
      <p>로그인 없이도 지출을 기록하고 공유할 수 있습니다.</p>
    </section>
  );
}
```

## 사용 방법: React Query prefetch를 적용할 때

인터랙션이 많은 화면은 다음 패턴을 사용한다.

```txt
page.tsx
  1. QueryClient 생성
  2. prefetchQuery 실행
  3. dehydrate
  4. HydrationBoundary로 client section 또는 widget 감싸기

client section/widget
  1. useQuery 사용
  2. hydration된 캐시 사용
  3. 이후 인터랙션 처리
```

## 레이어 판단 체크리스트

헷갈리면 아래 순서로 판단한다.

### shared인가?

```txt
도메인 없는 재료인가?
여러 곳에서 그대로 쓸 수 있는가?
비즈니스 단어가 없는가?
```

YES → `shared`

### entities인가?

```txt
비즈니스 객체인가?
명사로 표현되는 대상인가?
데이터를 보여주는가?
조회 중심인가?
```

YES → `entities`

### features인가?

```txt
사용자 행동인가?
동사로 표현되는 기능인가?
버튼/폼/토글/다이얼로그인가?
mutation이 있는가?
서버 상태를 바꾸는가?
```

YES → `features`

### widgets인가?

```txt
단순 route 전용 섹션을 넘어 독립적인 화면 블록인가?
entity와 feature를 조합하는가?
검색 + 리스트 + 액션처럼 화면 단위인가?
여러 route에서 재사용할 수 있거나 route와 분리해도 의미가 유지되는가?
```

YES → `widgets`

### app인가?

```txt
라우팅인가?
page/layout인가?
server prefetch인가?
페이지 배치인가?
특정 route에서만 쓰는 정적/가벼운 섹션인가?
page.tsx를 정리하기 위한 route 전용 _ui인가?
```

YES → `app`

## 금지 패턴

```txt
shared에서 도메인 API 호출 ❌
entities에서 create/update/delete mutation 구현 ❌
widgets에서 직접 fetch 호출 ❌
page.tsx에 비즈니스 로직 작성 ❌
feature UI에서 fetch 직접 호출 ❌
queryKey를 문자열로 직접 작성 ❌
동일한 query key를 여러 파일에 중복 작성 ❌
수입/지출을 거의 같은 코드로 각각 복사 ❌
```

## 요약

```txt
조회는 entities
변경은 features
독립적인 화면 조합은 widgets
라우팅/배치/route 전용 섹션은 app
공통 재료는 shared
```

핵심은 파일을 종류별로만 나누는 것이 아니라, **같은 관심사의 코드가 함께 모이도록** 책임을 나누는 것이다. 조회 API, query key, query option은 같은 서버 상태를 설명하므로 `entities`에 모은다. 생성/수정/삭제처럼 사용자의 행동으로 서버 상태를 바꾸는 코드는 `features`에 둔다.

`page.tsx`는 라우팅과 조립에 집중한다. 단순히 한 페이지 안의 JSX를 읽기 좋게 나누는 정도라면 `app/[route]/_ui`에 둘 수 있다. 반대로 데이터 조회, 화면 상태, entity UI, feature action을 묶어 하나의 독립적인 화면 블록이 되면 `widgets`로 분리한다.

수입/지출처럼 구조가 유사한 도메인은 `transaction`처럼 추상화한다.

```ts
export type TransactionType = 'income' | 'expense';
```

페이지 차이는 props로 표현한다.

```tsx
<TransactionListSection
  type="expense"
  title="지출 내역"
  description="사용한 금액을 검색하고 확인할 수 있습니다."
  searchPlaceholder="지출 내역 검색"
  emptyMessage="검색된 지출 내역이 없습니다."
/>
```

```tsx
<TransactionListSection
  type="income"
  title="수입 내역"
  description="들어온 금액을 검색하고 확인할 수 있습니다."
  searchPlaceholder="수입 내역 검색"
  emptyMessage="검색된 수입 내역이 없습니다."
/>
```

이 기준을 프로젝트 전반에 일관되게 적용한다.

## 참고 자료

- [Next.js Docs - App Router](https://nextjs.org/docs/app)
- [Next.js Docs - `page.js` file convention](https://nextjs.org/docs/app/api-reference/file-conventions/page)
- [TanStack Query Docs - Query Options](https://tanstack.com/query/latest/docs/framework/react/guides/query-options)
- [TanStack Query Docs - `queryOptions`](https://tanstack.com/query/latest/docs/framework/react/reference/queryOptions)
