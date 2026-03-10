#!/usr/bin/env node

/**
 * Velog 포스트 스크래핑 스크립트
 *
 * Velog GraphQL API를 사용하여 모든 포스트를 가져와
 * content/YYYY-MM-DD-slug/index.md 형식으로 저장한다.
 *
 * 사용법: node scripts/scrape-velog.mjs [username]
 * 기본 username: 253eosam
 */

import { writeFileSync, mkdirSync, existsSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { dirname } from 'node:path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const CONTENT_DIR = join(__dirname, '..', 'content');

const VELOG_API = 'https://v3.velog.io/graphql';
const USERNAME = process.argv[2] || '253eosam';

const POSTS_QUERY = `
  query Posts($username: String!, $cursor: ID) {
    posts(username: $username, cursor: $cursor) {
      id
      title
      url_slug
      released_at
      short_description
      tags
    }
  }
`;

const POST_DETAIL_QUERY = `
  query Post($username: String!, $url_slug: String!) {
    post(username: $username, url_slug: $url_slug) {
      id
      title
      body
      released_at
      tags
      short_description
    }
  }
`;

async function graphqlFetch(query, variables) {
  const res = await fetch(VELOG_API, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables }),
  });

  if (!res.ok) {
    throw new Error(`GraphQL request failed: ${res.status} ${res.statusText}`);
  }

  const json = await res.json();

  if (json.errors) {
    throw new Error(`GraphQL errors: ${JSON.stringify(json.errors)}`);
  }

  return json.data;
}

/** 모든 포스트 목록을 페이지네이션으로 가져온다 */
async function fetchAllPosts() {
  const allPosts = [];
  let cursor = null;

  while (true) {
    console.log(`Fetching posts... (cursor: ${cursor || 'start'})`);
    const data = await graphqlFetch(POSTS_QUERY, { username: USERNAME, cursor });
    const posts = data.posts;

    if (!posts || posts.length === 0) break;

    allPosts.push(...posts);
    cursor = posts[posts.length - 1].id;

    // API 부하 방지
    await sleep(300);
  }

  return allPosts;
}

/** 개별 포스트의 본문을 가져온다 */
async function fetchPostDetail(urlSlug) {
  const data = await graphqlFetch(POST_DETAIL_QUERY, {
    username: USERNAME,
    url_slug: urlSlug,
  });
  return data.post;
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/** released_at에서 YYYY-MM-DD를 추출한다 */
function toDateString(releasedAt) {
  return new Date(releasedAt).toISOString().slice(0, 10);
}

/** frontmatter를 생성한다 */
function buildFrontmatter(post) {
  const date = toDateString(post.released_at);
  const tags = (post.tags || []).map((t) => `'${t}'`).join(', ');
  const title = post.title.replace(/'/g, "''");
  const description = (post.short_description || '').replace(/'/g, "''");

  return [
    '---',
    `title: '${title}'`,
    `date: '${date}'`,
    `category: 'velog'`,
    `tags: [${tags}]`,
    `description: '${description}'`,
    '---',
  ].join('\n');
}

/** 폴더명을 생성한다: YYYY-MM-DD-slug */
function buildFolderName(post) {
  const date = toDateString(post.released_at);
  const slug = post.url_slug;
  return `${date}-${slug}`;
}

/** 기존 content 폴더 목록을 가져온다 */
function getExistingFolders() {
  if (!existsSync(CONTENT_DIR)) return new Set();
  return new Set(readdirSync(CONTENT_DIR));
}

async function main() {
  console.log(`Velog 포스트 스크래핑 시작 (username: ${USERNAME})`);
  console.log(`저장 경로: ${CONTENT_DIR}\n`);

  const existingFolders = getExistingFolders();
  console.log(`기존 콘텐츠 폴더: ${existingFolders.size}개\n`);

  // 1. 모든 포스트 목록 가져오기
  const posts = await fetchAllPosts();
  console.log(`\n총 ${posts.length}개 포스트 발견\n`);

  let created = 0;
  let skipped = 0;

  // 2. 각 포스트의 상세 내용을 가져와 저장
  for (let i = 0; i < posts.length; i++) {
    const post = posts[i];
    const folderName = buildFolderName(post);
    const folderPath = join(CONTENT_DIR, folderName);
    const filePath = join(folderPath, 'index.md');

    // 중복 체크
    if (existingFolders.has(folderName) || existsSync(folderPath)) {
      console.log(`[${i + 1}/${posts.length}] SKIP (이미 존재): ${folderName}`);
      skipped++;
      continue;
    }

    console.log(`[${i + 1}/${posts.length}] 가져오는 중: ${post.title}`);

    try {
      const detail = await fetchPostDetail(post.url_slug);

      if (!detail) {
        console.log(`  → 상세 내용을 가져올 수 없음, 건너뜀`);
        skipped++;
        continue;
      }

      const frontmatter = buildFrontmatter(detail);
      const content = `${frontmatter}\n\n${detail.body || ''}`;

      mkdirSync(folderPath, { recursive: true });
      writeFileSync(filePath, content, 'utf-8');

      console.log(`  → 저장 완료: ${folderName}/index.md`);
      created++;

      // API 부하 방지
      await sleep(500);
    } catch (err) {
      console.error(`  → 에러 발생: ${err.message}`);
    }
  }

  console.log(`\n완료!`);
  console.log(`  새로 생성: ${created}개`);
  console.log(`  건너뜀: ${skipped}개`);
  console.log(`  총 콘텐츠: ${existingFolders.size + created}개`);
}

main().catch((err) => {
  console.error('스크래핑 실패:', err);
  process.exit(1);
});
