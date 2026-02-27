const jwt = require('jsonwebtoken');

function signAccessToken({ userId, role, correlationId }, config) {
  return jwt.sign(
    { sub: userId, role, typ: 'access', cid: correlationId },
    config.jwt.accessSecret,
    { expiresIn: config.jwt.accessTtlSeconds }
  );
}

function signRefreshToken({ userId, tokenId, correlationId }, config) {
  return jwt.sign(
    { sub: userId, jti: tokenId, typ: 'refresh', cid: correlationId },
    config.jwt.refreshSecret,
    { expiresIn: config.jwt.refreshTtlSeconds }
  );
}

function verifyAccessToken(token, config) {
  return jwt.verify(token, config.jwt.accessSecret);
}

function verifyRefreshToken(token, config) {
  return jwt.verify(token, config.jwt.refreshSecret);
}

module.exports = {
  signAccessToken,
  signRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
};
