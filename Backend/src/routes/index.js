const express = require('express');

const { authRoutes } = require('./authRoutes');
const { orderRoutes } = require('./orderRoutes');
const { paymentRoutes } = require('./paymentRoutes');
const { adminRoutes } = require('./adminRoutes');
const { appRoutes } = require('./appRoutes');
const { checkoutSessionRoutes } = require('./checkoutSessionRoutes');
const { stripeWebhookRoutes } = require('./stripeWebhookRoutes');

const apiRouter = express.Router();

apiRouter.use('/auth', authRoutes);
apiRouter.use('/', appRoutes);
apiRouter.use('/', checkoutSessionRoutes);
apiRouter.use('/', stripeWebhookRoutes);
apiRouter.use('/orders', orderRoutes);
apiRouter.use('/payments', paymentRoutes);
apiRouter.use('/admin', adminRoutes);

module.exports = { apiRouter };
