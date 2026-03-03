const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const { getConfig } = require('./config/env');
const { initFirebase } = require('./config/firebase');
const { createHttpLogger } = require('./utils/logger');
const { correlationIdMiddleware } = require('./middleware/correlationIdMiddleware');
const { notFoundMiddleware } = require('./middleware/notFoundMiddleware');
const { errorMiddleware } = require('./middleware/errorMiddleware');

const { apiRouter } = require('./routes');

async function createServer() {
  const config = getConfig();

  initFirebase(config);

  const app = express();

  app.disable('x-powered-by');

  app.use(helmet());
  const allowAllOrigins = String(config.corsOrigin || '').trim() === '*';
  app.use(
    cors(
      allowAllOrigins
        ? { origin: '*', credentials: false }
        : { origin: config.corsOrigin, credentials: true }
    )
  );

  app.use(correlationIdMiddleware);
  app.use(createHttpLogger());

  app.use(
    rateLimit({
      windowMs: 15 * 60 * 1000,
      limit: config.rateLimit.global.maxRequests,
      standardHeaders: true,
      legacyHeaders: false,
    })
  );

  app.use('/api/payments/webhook', express.raw({ type: 'application/json' }));
  app.use('/api/webhook', express.raw({ type: 'application/json' }));
  app.use(express.json({ limit: '1mb' }));

  app.use('/api', apiRouter);

  app.use(notFoundMiddleware);
  app.use(errorMiddleware);

  return { app, config };
}

module.exports = { createServer };
