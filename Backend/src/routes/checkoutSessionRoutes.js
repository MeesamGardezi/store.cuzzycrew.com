const express = require('express');

const { validateRequest } = require('../middleware/validateRequest');
const { createCheckoutSessionSchema } = require('../validators/checkoutSessionValidators');
const checkoutSessionController = require('../controllers/checkoutSessionController');

const checkoutSessionRoutes = express.Router();

checkoutSessionRoutes.post('/create-checkout-session', validateRequest(createCheckoutSessionSchema), checkoutSessionController.createCheckoutSession);

module.exports = { checkoutSessionRoutes };
