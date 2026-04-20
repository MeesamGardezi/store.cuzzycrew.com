const express = require('express');

const { validateRequest } = require('../middleware/validateRequest');
const { createCheckoutSchema, orderIdSchema } = require('../validators/paymentValidators');
const paymentController = require('../controllers/paymentController');

const paymentRoutes = express.Router();

paymentRoutes.post('/checkout', validateRequest(createCheckoutSchema), paymentController.createCheckout);
paymentRoutes.post('/webhook', paymentController.webhook);
paymentRoutes.get('/:orderId/status', validateRequest(orderIdSchema), paymentController.status);

module.exports = { paymentRoutes };
