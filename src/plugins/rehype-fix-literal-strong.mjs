import { visit } from 'unist-util-visit';

const LITERAL_STRONG_PATTERN = /\*\*([\s\S]+?)\*\*/g;

function createStrong(children) {
  return {
    type: 'element',
    tagName: 'strong',
    properties: {},
    children,
  };
}

function createText(value) {
  return {
    type: 'text',
    value,
  };
}

function expandLiteralStrongText(node) {
  if (node.type !== 'text' || !node.value.includes('**')) {
    return null;
  }

  const nodes = [];
  let lastIndex = 0;

  for (const match of node.value.matchAll(LITERAL_STRONG_PATTERN)) {
    const [fullMatch, innerValue] = match;
    const matchIndex = match.index ?? 0;

    if (!innerValue.trim()) {
      continue;
    }

    if (matchIndex > lastIndex) {
      nodes.push(createText(node.value.slice(lastIndex, matchIndex)));
    }

    nodes.push(createStrong([createText(innerValue)]));
    lastIndex = matchIndex + fullMatch.length;
  }

  if (nodes.length === 0) {
    return null;
  }

  if (lastIndex < node.value.length) {
    nodes.push(createText(node.value.slice(lastIndex)));
  }

  return nodes;
}

function normalizeChildren(parent) {
  if (!Array.isArray(parent.children) || parent.children.length === 0) {
    return;
  }

  for (let index = 0; index < parent.children.length; index += 1) {
    const child = parent.children[index];
    const expanded = expandLiteralStrongText(child);

    if (expanded) {
      parent.children.splice(index, 1, ...expanded);
      index += expanded.length - 1;
      continue;
    }

    const next = parent.children[index + 1];
    const nextNext = parent.children[index + 2];

    if (
      child?.type === 'text' &&
      next?.type === 'element' &&
      next.tagName !== 'strong' &&
      nextNext?.type === 'text' &&
      child.value.endsWith('**') &&
      nextNext.value.startsWith('**')
    ) {
      child.value = child.value.slice(0, -2);
      nextNext.value = nextNext.value.slice(2);
      parent.children[index + 1] = createStrong([next]);

      if (child.value === '') {
        parent.children.splice(index, 1);
        index -= 1;
      }

      const trailingIndex = child.value === '' ? index + 2 : index + 2;
      if (parent.children[trailingIndex]?.type === 'text' && parent.children[trailingIndex].value === '') {
        parent.children.splice(trailingIndex, 1);
      }
    }
  }
}

export default function rehypeFixLiteralStrong() {
  return (tree) => {
    visit(tree, (node) => {
      normalizeChildren(node);
    });
  };
}
