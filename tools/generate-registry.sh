#!/bin/bash

# 전체 포스트 현황을 content-registry.json으로 자동 생성하는 스크립트

set -e
cd "$(dirname "$0")/.."

python3 << 'PYTHON_SCRIPT'
import json, os, re
from datetime import datetime, timezone

OUTPUT = "content-registry.json"

def parse_frontmatter(filepath):
    try:
        with open(filepath, 'r') as f:
            content = f.read()
    except:
        return {}
    match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
    if not match:
        return {}
    fm = match.group(1)
    result = {}

    for field in ['title', 'category', 'description', 'date', 'quality_score']:
        m = re.search(rf'^{field}:\s*(.+)$', fm, re.MULTILINE)
        if m:
            val = m.group(1).strip().strip('"').strip("'")
            result[field] = val

    # tags: inline [tag1, tag2]
    tag_inline = re.search(r'^tags?:\s*\[(.+)\]', fm, re.MULTILINE)
    if tag_inline:
        raw = tag_inline.group(1)
        tags = [t.strip().strip("'").strip('"') for t in raw.split(',')]
        result['tags'] = [t for t in tags if t]
    else:
        # YAML list format
        tag_match = re.search(r'^tags?:\s*\n', fm, re.MULTILINE)
        if tag_match:
            rest = fm[tag_match.end():]
            tags = []
            for line in rest.split('\n'):
                m2 = re.match(r'^\s+-\s+(.+)', line)
                if m2:
                    tags.append(m2.group(1).strip().strip("'").strip('"'))
                elif line.strip() == '':
                    continue
                else:
                    break
            if tags:
                result['tags'] = tags

    return result

def find_content_file(dir_path):
    for fname in ['index.md', 'content.md', 'draft.md']:
        fpath = os.path.join(dir_path, fname)
        if os.path.isfile(fpath):
            return fpath
    return None

def extract_post(dir_path, location, status):
    folder = os.path.basename(dir_path)

    # Date from folder name
    date_match = re.match(r'^(\d{4}-\d{2}-\d{2})', folder)
    date = date_match.group(1) if date_match else ""

    title = ""
    category = ""
    quality_score = None

    # Parse content file frontmatter
    content_file = find_content_file(dir_path)
    if content_file:
        fm = parse_frontmatter(content_file)
        title = fm.get('title', '')
        category = fm.get('category', '')
        if fm.get('date'):
            d = fm['date']
            dm = re.match(r'^(\d{4}-\d{2}-\d{2})', d)
            if dm:
                date = dm.group(1)

    # Override with metadata.json if available
    meta_path = os.path.join(dir_path, 'metadata.json')
    if os.path.isfile(meta_path):
        try:
            with open(meta_path) as f:
                meta = json.load(f)
            if not title and meta.get('title'):
                title = meta['title']
            if not category and meta.get('category'):
                category = meta['category']
            if meta.get('quality_score'):
                try:
                    quality_score = float(meta['quality_score'])
                except (ValueError, TypeError):
                    pass
        except:
            pass

    # Fallback title from folder name
    if not title:
        title = re.sub(r'^\d{4}-\d{2}-\d{2}-', '', folder)

    return {
        "folder": folder,
        "title": title,
        "category": category,
        "status": status,
        "quality_score": quality_score,
        "location": location,
        "date": date
    }

# --- Collect data ---
posts = []
counts = {"in_progress": 0, "ready_to_publish": 0, "published": 0, "unprocessed": 0}
categories = {}
scores = []

# 1. content/in-progress
ip_dir = "content/in-progress"
if os.path.isdir(ip_dir):
    for folder in sorted(os.listdir(ip_dir)):
        dir_path = os.path.join(ip_dir, folder)
        if not os.path.isdir(dir_path):
            continue
        posts.append(extract_post(dir_path, ip_dir, "in_progress"))
        counts["in_progress"] += 1

# 2. content/ready-to-publish
rtp_dir = "content/ready-to-publish"
if os.path.isdir(rtp_dir):
    for folder in sorted(os.listdir(rtp_dir)):
        dir_path = os.path.join(rtp_dir, folder)
        if not os.path.isdir(dir_path):
            continue
        post = extract_post(dir_path, rtp_dir, "ready_to_publish")
        posts.append(post)
        counts["ready_to_publish"] += 1
        if post["quality_score"] is not None:
            scores.append(post["quality_score"])
        cat = post.get("category", "").lower()
        if cat:
            categories[cat] = categories.get(cat, 0) + 1

# 3. content/published
pub_dir = "content/published"
if os.path.isdir(pub_dir):
    for folder in sorted(os.listdir(pub_dir)):
        dir_path = os.path.join(pub_dir, folder)
        if not os.path.isdir(dir_path):
            continue
        post = extract_post(dir_path, pub_dir, "published")
        posts.append(post)
        counts["published"] += 1
        if post["quality_score"] is not None:
            scores.append(post["quality_score"])
        cat = post.get("category", "").lower()
        if cat:
            categories[cat] = categories.get(cat, 0) + 1

# 4. content/posts
content_dir = "content/posts"
if os.path.isdir(content_dir):
    for cat_name in sorted(os.listdir(content_dir)):
        cat_path = os.path.join(content_dir, cat_name)
        if not os.path.isdir(cat_path):
            continue
        for folder in sorted(os.listdir(cat_path)):
            dir_path = os.path.join(cat_path, folder)
            if not os.path.isdir(dir_path):
                continue
            post = extract_post(dir_path, f"content/posts/{cat_name}", "unprocessed")
            posts.append(post)
            counts["unprocessed"] += 1
            categories[cat_name] = categories.get(cat_name, 0) + 1

total = sum(counts.values())
avg_score = round(sum(scores) / len(scores), 2) if scores else 0

registry = {
    "last_updated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S"),
    "summary": {
        "total": total,
        "by_status": counts,
        "by_category": categories,
        "avg_quality_score": avg_score
    },
    "posts": posts
}

with open(OUTPUT, 'w') as f:
    json.dump(registry, f, ensure_ascii=False, indent=2)
    f.write('\n')

print(f"✅ {OUTPUT} 생성 완료")
print(f"   총 {total}개 포스트 등록")
print(f"   (in-progress: {counts['in_progress']}, ready: {counts['ready_to_publish']}, published: {counts['published']}, unprocessed: {counts['unprocessed']})")
PYTHON_SCRIPT
