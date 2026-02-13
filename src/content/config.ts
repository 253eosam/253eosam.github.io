import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const notes = defineCollection({
  loader: glob({
    pattern: '**/index.md',
    base: './content/completed',
  }),
  schema: z.object({
    title: z.string(),
    date: z.string().optional(),
    layout: z.string().optional(),
    category: z.string().optional(),
    categories: z.union([z.string(), z.array(z.string())]).optional(),
    tags: z.union([z.string(), z.array(z.string())]).nullable().optional(),
    tag: z.union([z.string(), z.array(z.string())]).nullable().optional(),
    description: z.string().optional(),
    status: z.string().optional(),
    quality_score: z.string().optional(),
    link: z.string().optional(),
    url: z.string().optional(),
  }),
});

export const collections = { notes };
