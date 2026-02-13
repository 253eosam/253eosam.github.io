interface RawData {
  title: string;
  date?: string;
  category?: string;
  categories?: string | string[];
  tags?: string | string[];
  tag?: string | string[];
  description?: string;
  [key: string]: unknown;
}

export interface NormalizedNote {
  title: string;
  date: string;
  category: string;
  tags: string[];
  description: string;
  slug: string;
}

/**
 * 폴더명에서 YYYY-MM-DD 날짜를 추출한다.
 * id 형식: "2021-01-22-docker-db-container/index.md" 또는 "2021-01-22-docker-db-container"
 */
function extractDateFromId(id: string): string {
  const match = id.match(/^(\d{4}-\d{2}-\d{2})/);
  return match ? match[1] : '1970-01-01';
}

/**
 * 폴더명에서 slug를 추출한다.
 */
function extractSlugFromId(id: string): string {
  // "2021-01-22-docker-db-container/index.md" → "2021-01-22-docker-db-container"
  return id.replace(/\/index\.md$/, '').replace(/\/index$/, '');
}

/**
 * ISO 8601 날짜 문자열을 YYYY-MM-DD로 변환한다.
 */
function normalizeDate(date: string): string {
  if (date.includes('T')) {
    return date.slice(0, 10);
  }
  return date;
}

/**
 * HTML 태그가 포함된 오염된 태그를 필터링한다.
 */
function cleanTags(raw: string | string[] | undefined): string[] {
  if (!raw) return [];
  const arr = typeof raw === 'string' ? [raw] : raw;
  return arr
    .filter((t) => typeof t === 'string' && !t.includes('<') && t.trim() !== '')
    .map((t) => t.trim());
}

/**
 * category / categories 필드를 단일 문자열로 정규화한다.
 */
function normalizeCategory(data: RawData): string {
  const raw = data.category ?? data.categories;
  if (!raw) return '미분류';
  const value = Array.isArray(raw) ? raw[0] : raw;
  return value.toLowerCase().trim();
}

/**
 * frontmatter 데이터를 정규화된 형태로 변환한다.
 */
export function normalize(id: string, data: RawData): NormalizedNote {
  const date = data.date ? normalizeDate(data.date) : extractDateFromId(id);

  // tags와 tag 필드를 병합
  const tags = [...cleanTags(data.tags), ...cleanTags(data.tag)];
  // 중복 제거
  const uniqueTags = [...new Set(tags)];

  return {
    title: data.title,
    date,
    category: normalizeCategory(data),
    tags: uniqueTags,
    description: data.description ?? '',
    slug: extractSlugFromId(id),
  };
}
