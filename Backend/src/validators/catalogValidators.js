const { z } = require('zod');

const listProductsSchema = z.object({
  query: z.object({
    limit: z.coerce.number().int().min(1).max(50).default(20),
    cursor: z.string().min(1).optional(),
    category: z.string().min(1).optional(),
    color: z.string().min(1).optional(),
    size: z.string().min(1).optional(),
    priceMin: z.coerce.number().nonnegative().optional(),
    priceMax: z.coerce.number().nonnegative().optional(),
    sort: z.enum(['newest', 'price_asc', 'price_desc']).optional(),
  }),
});

const productSlugSchema = z.object({
  params: z.object({ slug: z.string().min(1) }),
});

const productIdSchema = z.object({
  params: z.object({ id: z.string().min(1) }),
});

module.exports = { listProductsSchema, productSlugSchema, productIdSchema };
