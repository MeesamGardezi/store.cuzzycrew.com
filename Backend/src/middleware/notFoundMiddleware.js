const { ApiError } = require('../utils/apiError');

function notFoundMiddleware(req, res, next) {
  next(
    new ApiError({
      status: 404,
      code: 'NOT_FOUND',
      message: 'Route not found',
      details: [{ path: req.originalUrl }],
    })
  );
}

module.exports = { notFoundMiddleware };
