const { z } = require('zod');

const createProductSchema = z.object({
  body: z.object({
    name: z.string().min(1).max(200),
    slug: z.string().min(1).max(200),
    description: z.string().max(5000).optional(),
    categoryId: z.string().min(1).optional(),
    priceMin: z.coerce.number().int().nonnegative().optional(),
    colors: z.array(z.string().min(1)).optional(),
    sizes: z.array(z.string().min(1)).optional(),
  }).passthrough(),
});

const updateProductSchema = z.object({
  params: z.object({ id: z.string().min(1) }),
  body: z.object({
    name: z.string().min(1).max(200).optional(),
    slug: z.string().min(1).max(200).optional(),
    description: z.string().max(5000).optional(),
    categoryId: z.string().min(1).optional(),
    priceMin: z.coerce.number().int().nonnegative().optional(),
    colors: z.array(z.string().min(1)).optional(),
    sizes: z.array(z.string().min(1)).optional(),
  }).passthrough(),
});

const idParamSchema = z.object({
  params: z.object({ id: z.string().min(1) }),
});

const updateVariantStockSchema = z.object({
  params: z.object({ id: z.string().min(1) }),
  body: z.object({
    stock: z.coerce.number().int().min(0).max(1000000),
  }),
});

const updateOrderStatusSchema = z.object({
  params: z.object({ id: z.string().min(1) }),
  body: z.object({
    status: z.enum(['PENDING', 'PROCESSING', 'FAILED', 'CANCELED', 'SHIPPED', 'DELIVERED']),
  }),
});

const createCouponSchema = z.object({
  body: z.object({
    code: z.string().min(1).max(50),
    type: z.enum(['PERCENT', 'AMOUNT']),
    percentOff: z.coerce.number().int().min(1).max(100).optional(),
    amountOff: z.coerce.number().int().min(1).optional(),
    expiresAt: z.string().datetime().optional(),
    maxUses: z.coerce.number().int().min(1).optional(),
    minOrderAmount: z.coerce.number().int().min(0).optional(),
  }).passthrough(),
});

const createVariantSchema = z.object({
  body: z.object({
    productId: z.string().min(1),
    sku: z.string().min(1).max(100),
    label: z.string().min(1).max(200),
    price: z.coerce.number().int().nonnegative(),
    stock: z.coerce.number().int().min(0).max(1000000),
  }).passthrough(),
});

module.exports = {
  createProductSchema,
  updateProductSchema,
  idParamSchema,
  updateVariantStockSchema,
  updateOrderStatusSchema,
  createCouponSchema,
  createVariantSchema,
};
