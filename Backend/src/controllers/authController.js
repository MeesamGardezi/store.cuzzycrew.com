const rateLimit = require('express-rate-limit');

const { getConfig } = require('../config/env');
const { asyncHandler } = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/response');
const authService = require('../services/authService');

function loginRateLimiter() {
  const config = getConfig();
  return rateLimit({
    windowMs: config.rateLimit.login.windowMs,
    limit: config.rateLimit.login.maxAttempts,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
      success: false,
      error: {
        code: 'RATE_LIMITED',
        message: 'Too many login attempts',
        details: [],
      },
    },
  });
}

const register = asyncHandler(async (req, res) => {
  const { email, password, firstName, lastName } = req.validated.body;
  const result = await authService.register({
    email,
    password,
    firstName,
    lastName,
    correlationId: req.correlationId,
  });

  return sendSuccess(res, { data: result, message: 'Registered' });
});

const login = asyncHandler(async (req, res) => {
  const { email, password, sessionToken } = req.validated.body;
  const result = await authService.login({
    email,
    password,
    sessionToken,
    correlationId: req.correlationId,
  });

  return sendSuccess(res, { data: result, message: 'Logged in' });
});

const refresh = asyncHandler(async (req, res) => {
  const { refreshToken } = req.validated.body;
  const result = await authService.refresh({ refreshToken, correlationId: req.correlationId });
  return sendSuccess(res, { data: result, message: 'Refreshed' });
});

module.exports = { register, login, refresh, loginRateLimiter };
