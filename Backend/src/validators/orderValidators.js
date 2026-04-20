const { z } = require('zod');

const shippingAddressSchema = z.object({
  fullName: z.string().min(1).max(200),
  email: z.string().email().optional(),
  phone: z.string().min(1).max(50),
  street: z.string().min(1).max(200).optional(),
  addressLine1: z.string().min(1).max(200).optional(),
  city: z.string().min(1).max(100),
  state: z.string().min(1).max(100).optional(),
  zipCode: z.string().min(1).max(30).optional(),
  postalCode: z.string().min(1).max(30).optional(),
  country: z.string().min(1).max(2),
}).superRefine((value, ctx) => {
  if (!value.street && !value.addressLine1) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['street'],
      message: 'Street is required',
    });
  }

  if (!value.zipCode && !value.postalCode) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['zipCode'],
      message: 'Zip code is required',
    });
  }
});

const createOrderSchema = z.object({
  headers: z.object({
    'idempotency-key': z.string().min(8).max(200).optional(),
  }).passthrough(),
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
    shippingAddress: shippingAddressSchema,
  }).passthrough(),
});

const orderIdSchema = z.object({
  params: z.object({ orderId: z.string().min(1) }),
});

module.exports = { createOrderSchema, orderIdSchema };
