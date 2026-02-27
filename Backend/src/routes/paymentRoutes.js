const express = require('express');

const { requireAuth } = require('../middleware/requireAuth');
const { validateRequest } = require('../middleware/validateRequest');
const { createIntentSchema, orderIdSchema } = require('../validators/paymentValidators');
const paymentController = require('../controllers/paymentController');

const paymentRoutes = express.Router();

paymentRoutes.post('/intent', requireAuth, validateRequest(createIntentSchema), paymentController.createIntent);
paymentRoutes.post('/webhook', paymentController.webhook);
paymentRoutes.get('/:orderId/status', requireAuth, validateRequest(orderIdSchema), paymentController.status);

module.exports = { paymentRoutes };
