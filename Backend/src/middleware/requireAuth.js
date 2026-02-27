const { getConfig } = require('../config/env');
const { ApiError } = require('../utils/apiError');
const { verifyAccessToken } = require('../utils/jwt');

function requireAuth(req, res, next) {
  const config = getConfig();

  const auth = req.header('authorization');
  const token = auth && auth.startsWith('Bearer ') ? auth.slice('Bearer '.length) : null;

  if (!token) {
    return next(
      new ApiError({
        status: 401,
        code: 'UNAUTHORIZED',
        message: 'Missing access token',
        details: [],
      })
    );
  }

  try {
    const payload = verifyAccessToken(token, config);

    if (payload.typ !== 'access') {
      throw new Error('Invalid token type');
    }

    req.auth = { userId: payload.sub, role: payload.role };
    return next();
  } catch {
    return next(
      new ApiError({
        status: 401,
        code: 'UNAUTHORIZED',
        message: 'Invalid or expired access token',
        details: [],
      })
    );
  }
}

module.exports = { requireAuth };
