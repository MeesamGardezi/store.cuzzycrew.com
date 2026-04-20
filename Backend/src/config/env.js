const dotenv = require('dotenv');
const { z } = require('zod');

dotenv.config();

let cachedConfig;

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(4000),

  CORS_ORIGIN: z.string().default('*'),

  JWT_ACCESS_SECRET: z.string().min(20),
  JWT_REFRESH_SECRET: z.string().min(20),

  PADDLE_API_KEY: z.string().min(10).optional(),
  PADDLE_WEBHOOK_SECRET: z.string().min(10).optional(),
  PADDLE_CHECKOUT_URL: z.string().url().optional(),
  PADDLE_RETURN_URL: z.string().url().optional(),

  FIREBASE_PROJECT_ID: z.string().optional(),
  FIREBASE_SERVICE_ACCOUNT_PATH: z.string().optional(),
  FIREBASE_SERVICE_ACCOUNT_JSON: z.string().optional(),
  FIREBASE_STORAGE_BUCKET: z.string().optional(),

  RATE_LIMIT_GLOBAL_MAX: z.coerce.number().int().positive().default(600),
}).passthrough();

function getConfig() {
  if (cachedConfig) return cachedConfig;

  const parsed = envSchema.safeParse(process.env);
  if (!parsed.success) {
    const err = new Error('Invalid environment configuration');
    err.details = parsed.error.flatten();
    throw err;
  }

  const env = parsed.data;

  cachedConfig = {
    env: env.NODE_ENV,
    port: env.PORT,
    corsOrigin: env.CORS_ORIGIN,
    jwt: {
      accessSecret: env.JWT_ACCESS_SECRET,
      refreshSecret: env.JWT_REFRESH_SECRET,
      accessTtlSeconds: 15 * 60,
      refreshTtlSeconds: 7 * 24 * 60 * 60,
    },
    paddle: {
      apiKey: env.PADDLE_API_KEY || null,
      webhookSecret: env.PADDLE_WEBHOOK_SECRET || null,
      checkoutUrl: env.PADDLE_CHECKOUT_URL || null,
      returnUrl: env.PADDLE_RETURN_URL || null,
    },
    firebase: {
      projectId: env.FIREBASE_PROJECT_ID,
      serviceAccountPath: env.FIREBASE_SERVICE_ACCOUNT_PATH,
      serviceAccountJson: env.FIREBASE_SERVICE_ACCOUNT_JSON,
      storageBucket: env.FIREBASE_STORAGE_BUCKET,
    },
    rateLimit: {
      global: { maxRequests: env.RATE_LIMIT_GLOBAL_MAX },
      login: { windowMs: 15 * 60 * 1000, maxAttempts: 5 },
    },
  };

  return cachedConfig;
}

module.exports = { getConfig };
