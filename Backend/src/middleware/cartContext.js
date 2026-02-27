const { ApiError } = require('../utils/apiError');

function getSessionToken(req) {
  const token = req.header('x-session-token');
  if (typeof token === 'string' && token.trim()) return token.trim();
  return null;
}

function cartContext(req, res, next) {
  const sessionToken = getSessionToken(req);
  const userId = req.auth?.userId || null;

  if (!userId && !sessionToken) {
    return next(
      new ApiError({
        status: 400,
        code: 'SESSION_TOKEN_REQUIRED',
        message: 'Guest sessionToken is required',
        details: [],
      })
    );
  }

  req.cartContext = { userId, sessionToken };
  return next();
}

module.exports = { cartContext, getSessionToken };
