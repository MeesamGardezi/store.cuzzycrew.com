const express = require('express');

const { validateRequest } = require('../middleware/validateRequest');
const { registerSchema, loginSchema, refreshSchema } = require('../validators/authValidators');
const authController = require('../controllers/authController');

const authRoutes = express.Router();

authRoutes.post('/register', validateRequest(registerSchema), authController.register);
authRoutes.post('/login', authController.loginRateLimiter(), validateRequest(loginSchema), authController.login);
authRoutes.post('/refresh', validateRequest(refreshSchema), authController.refresh);

module.exports = { authRoutes };
