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
    customReceivedMessage(req) {
      return `http_request_started ${req.method} ${req.url}`;
    },
    customSuccessMessage(req, res) {
      return `http_request_completed ${req.method} ${req.url} ${res.statusCode}`;
    },
    customErrorMessage(req, res, err) {
      return `http_request_failed ${req.method} ${req.url} ${res.statusCode || 500} ${err && err.message ? err.message : 'unknown_error'}`;
    },
    customLogLevel(req, res, err) {
      if (err || res.statusCode >= 500) return 'error';
      if (res.statusCode >= 400) return 'warn';
      return 'info';
    },
    customProps: (req) => ({ correlationId: req.correlationId }),
    serializers: {
      req(req) {
        return {
          method: req.method,
          url: req.url,
          correlationId: req.correlationId,
          query: req.query,
        };
      },
      res(res) {
        return {
          statusCode: res.statusCode,
        };
      },
    },
  });
}

module.exports = { logger, createHttpLogger };
