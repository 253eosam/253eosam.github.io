import { defineConfig } from 'astro/config';
import rehypeFixLiteralStrong from './src/plugins/rehype-fix-literal-strong.mjs';
import rehypeWrapTable from './src/plugins/rehype-wrap-table.mjs';

export default defineConfig({
  site: 'https://253eosam.github.io',
  server: {
    allowedHosts: ['all'],
  },
  markdown: {
    shikiConfig: {
      theme: 'github-dark',
    },
    rehypePlugins: [rehypeFixLiteralStrong, rehypeWrapTable],
  },
});
