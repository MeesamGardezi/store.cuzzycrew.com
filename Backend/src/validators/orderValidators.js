const { z } = require('zod');

const quoteSchema = z.object({
  headers: z.object({
    'x-session-token': z.string().min(8).max(200).optional(),
    authorization: z.string().optional(),
  }).passthrough(),
});

const createOrderSchema = z.object({
  headers: z.object({
    'idempotency-key': z.string().min(8).max(200),
  }).passthrough(),
  body: z.object({
    shippingAddressId: z.string().min(1).optional(),
  }).passthrough(),
});

const orderIdSchema = z.object({
  params: z.object({ orderId: z.string().min(1) }),
});

module.exports = { quoteSchema, createOrderSchema, orderIdSchema };
