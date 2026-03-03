const { z } = require('zod');

const createCheckoutSessionSchema = z.object({
  body: z.object({
    items: z
      .array(
        z.object({
          productId: z.string().min(1),
          quantity: z.coerce.number().int().min(1).max(100),
          selectedSize: z.string().min(1).max(50),
          selectedColor: z.string().min(1).max(50),
        })
      )
      .min(1),
    currency: z.string().min(1).max(10).default('USD'),
    shippingAddress: z.object({
      fullName: z.string().min(1).max(200),
      phone: z.string().min(1).max(50),
      addressLine1: z.string().min(1).max(200),
      city: z.string().min(1).max(100),
      postalCode: z.string().min(1).max(30),
      country: z.string().min(1).max(2),
    }),
  }),
});

module.exports = { createCheckoutSessionSchema };
