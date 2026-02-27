const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

const { getConfig } = require('../config/env');
const { ApiError } = require('../utils/apiError');
const { signAccessToken, signRefreshToken, verifyRefreshToken } = require('../utils/jwt');
const userRepository = require('../repositories/userRepository');
const refreshTokenRepository = require('../repositories/refreshTokenRepository');
const cartService = require('./cartService');

const BCRYPT_COST = 12;

function nowIso() {
  return new Date().toISOString();
}

async function register({ email, password, firstName, lastName, correlationId }) {
  const config = getConfig();

  const emailLower = email.toLowerCase();
  const passwordHash = await bcrypt.hash(password, BCRYPT_COST);

  const userId = uuidv4();

  try {
    const user = await userRepository.createUserWithUniqueEmail({
      userId,
      email,
      emailLower,
      passwordHash,
      role: 'USER',
      firstName,
      lastName,
      nowIso: nowIso(),
    });

    const tokenId = uuidv4();
    const refreshExpiresAt = new Date(Date.now() + config.jwt.refreshTtlSeconds * 1000).toISOString();

    await refreshTokenRepository.create({
      tokenId,
      userId: user.id,
      expiresAtIso: refreshExpiresAt,
      createdAtIso: nowIso(),
    });

    const accessToken = signAccessToken({ userId: user.id, role: user.role, correlationId }, config);
    const refreshToken = signRefreshToken({ userId: user.id, tokenId, correlationId }, config);

    return {
      user: { id: user.id, email: user.email, role: user.role },
      tokens: { accessToken, refreshToken },
    };
  } catch (e) {
    if (e && e.code === 'EMAIL_TAKEN') {
      throw new ApiError({ status: 409, code: 'EMAIL_TAKEN', message: 'Email already in use', details: [] });
    }
    throw e;
  }
}

async function login({ email, password, sessionToken, correlationId }) {
  const config = getConfig();

  const user = await userRepository.getByEmail(email.toLowerCase());
  if (!user || user.deletedAt) {
    throw new ApiError({ status: 401, code: 'INVALID_CREDENTIALS', message: 'Invalid credentials', details: [] });
  }

  const ok = await bcrypt.compare(password, user.passwordHash);
  if (!ok) {
    throw new ApiError({ status: 401, code: 'INVALID_CREDENTIALS', message: 'Invalid credentials', details: [] });
  }

  await cartService.mergeGuestCartIntoUserCart({ userId: user.id, sessionToken });

  const tokenId = uuidv4();
  const refreshExpiresAt = new Date(Date.now() + config.jwt.refreshTtlSeconds * 1000).toISOString();

  await refreshTokenRepository.create({
    tokenId,
    userId: user.id,
    expiresAtIso: refreshExpiresAt,
    createdAtIso: nowIso(),
  });

  const accessToken = signAccessToken({ userId: user.id, role: user.role, correlationId }, config);
  const refreshToken = signRefreshToken({ userId: user.id, tokenId, correlationId }, config);

  return {
    user: { id: user.id, email: user.email, role: user.role },
    tokens: { accessToken, refreshToken },
  };
}

async function refresh({ refreshToken, correlationId }) {
  const config = getConfig();

  let payload;
  try {
    payload = verifyRefreshToken(refreshToken, config);
  } catch {
    throw new ApiError({ status: 401, code: 'UNAUTHORIZED', message: 'Invalid or expired refresh token', details: [] });
  }

  if (payload.typ !== 'refresh' || !payload.jti) {
    throw new ApiError({ status: 401, code: 'UNAUTHORIZED', message: 'Invalid refresh token', details: [] });
  }

  const tokenRecord = await refreshTokenRepository.getById(payload.jti);
  if (!tokenRecord || tokenRecord.revokedAt) {
    throw new ApiError({ status: 401, code: 'UNAUTHORIZED', message: 'Refresh token revoked', details: [] });
  }

  const user = await userRepository.getById(payload.sub);
  if (!user || user.deletedAt) {
    throw new ApiError({ status: 401, code: 'UNAUTHORIZED', message: 'User not found', details: [] });
  }

  const accessToken = signAccessToken({ userId: user.id, role: user.role, correlationId }, config);
  return { accessToken };
}

module.exports = { register, login, refresh };
