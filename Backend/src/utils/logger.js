const pino = require('pino');
const pinoHttp = require('pino-http');

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  base: null,
  timestamp: () => `,"time":"${new Date().toISOString()}"`,
});

function createHttpLogger() {
  return pinoHttp({
    logger,
    customProps: (req) => ({ correlationId: req.correlationId }),
    serializers: {
      req(req) {
        return {
          method: req.method,
          url: req.url,
          correlationId: req.correlationId,
        };
      },
    },
  });
}

module.exports = { logger, createHttpLogger };
