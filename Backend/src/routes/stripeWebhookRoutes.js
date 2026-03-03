const express = require('express');

const stripeWebhookController = require('../controllers/stripeWebhookController');

const stripeWebhookRoutes = express.Router();

stripeWebhookRoutes.post('/webhook', stripeWebhookController.webhook);

module.exports = { stripeWebhookRoutes };
