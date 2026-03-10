import { visit } from 'unist-util-visit';

/**
 * 마크다운 테이블을 <div class="table-wrapper">로 감싸서
 * 넓은 테이블이 가로 스크롤되도록 한다.
 */
export default function rehypeWrapTable() {
  return (tree) => {
    visit(tree, 'element', (node, index, parent) => {
      if (node.tagName !== 'table' || !parent) return;

      const wrapper = {
        type: 'element',
        tagName: 'div',
        properties: { className: ['table-wrapper'] },
        children: [node],
      };

      parent.children[index] = wrapper;
    });
  };
}
