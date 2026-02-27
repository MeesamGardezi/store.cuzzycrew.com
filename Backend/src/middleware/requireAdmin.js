const { ApiError } = require('../utils/apiError');

function requireAdmin(req, res, next) {
  if (!req.auth?.userId) {
    return next(
      new ApiError({
        status: 401,
        code: 'UNAUTHORIZED',
        message: 'Unauthorized',
        details: [],
      })
    );
  }

  if (req.auth.role !== 'ADMIN') {
    return next(
      new ApiError({
        status: 403,
        code: 'FORBIDDEN',
        message: 'Admin access required',
        details: [],
      })
    );
  }

  return next();
}

module.exports = { requireAdmin };
