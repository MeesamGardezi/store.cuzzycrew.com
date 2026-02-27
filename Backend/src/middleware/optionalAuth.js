const { getConfig } = require('../config/env');
const { verifyAccessToken } = require('../utils/jwt');

function optionalAuth(req, res, next) {
  const config = getConfig();

  const auth = req.header('authorization');
  const token = auth && auth.startsWith('Bearer ') ? auth.slice('Bearer '.length) : null;

  if (!token) return next();

  try {
    const payload = verifyAccessToken(token, config);
    if (payload.typ === 'access') {
      req.auth = { userId: payload.sub, role: payload.role };
    }
  } catch {
    return next();
  }

  return next();
}

module.exports = { optionalAuth };
