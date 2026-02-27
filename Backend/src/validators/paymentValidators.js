const { z } = require('zod');

const createIntentSchema = z.object({
  body: z.object({
    orderId: z.string().min(1),
  }),
});

const orderIdSchema = z.object({
  params: z.object({ orderId: z.string().min(1) }),
});

module.exports = { createIntentSchema, orderIdSchema };
