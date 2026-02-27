const { z } = require('zod');

const addItemSchema = z.object({
  body: z.object({
    variantId: z.string().min(1),
    quantity: z.coerce.number().int().min(1).max(99),
  }),
});

const updateItemSchema = z.object({
  params: z.object({ itemId: z.string().min(1) }),
  body: z.object({
    quantity: z.coerce.number().int().min(1).max(99),
  }),
});

const deleteItemSchema = z.object({
  params: z.object({ itemId: z.string().min(1) }),
});

const applyCouponSchema = z.object({
  body: z.object({
    code: z.string().min(1).max(50),
  }),
});

module.exports = {
  addItemSchema,
  updateItemSchema,
  deleteItemSchema,
  applyCouponSchema,
};
