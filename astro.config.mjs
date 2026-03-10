import { defineConfig } from 'astro/config';
import rehypeWrapTable from './src/plugins/rehype-wrap-table.mjs';

export default defineConfig({
  site: 'https://253eosam.github.io',
  markdown: {
    shikiConfig: {
      theme: 'github-dark',
    },
    rehypePlugins: [rehypeWrapTable],
  },
});
