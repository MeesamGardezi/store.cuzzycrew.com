const { z } = require('zod');

const createCheckoutSchema = z.object({
  body: z.object({
    orderId: z.string().min(1),
    orderToken: z.string().min(8).max(200),
  }),
});

const orderIdSchema = z.object({
  params: z.object({ orderId: z.string().min(1) }),
});

module.exports = { createCheckoutSchema, orderIdSchema };
