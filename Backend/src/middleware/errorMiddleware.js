const { logger } = require('../utils/logger');
const { ApiError } = require('../utils/apiError');

function errorMiddleware(err, req, res, next) {
  const correlationId = req.correlationId;

  const apiErr = err instanceof ApiError
    ? err
    : new ApiError({
      status: 500,
      code: 'INTERNAL_SERVER_ERROR',
      message: 'Server error',
      details: [],
    });

  const status = apiErr.status || 500;

  const logPayload = {
    correlationId,
    status,
    code: apiErr.code,
    message: apiErr.message,
    details: apiErr.details,
  };

  if (status >= 500) logger.error({ err, ...logPayload }, 'request_failed');
  else logger.warn({ ...logPayload }, 'request_error');

  res.status(status).json({
    success: false,
    error: {
      code: apiErr.code,
      message: apiErr.message,
      details: apiErr.details || [],
    },
  });
}

module.exports = { errorMiddleware };
