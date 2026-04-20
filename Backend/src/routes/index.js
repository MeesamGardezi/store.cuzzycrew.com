const express = require('express');
const { getConfig } = require('../config/env');

const { authRoutes } = require('./authRoutes');
const { orderRoutes } = require('./orderRoutes');
const { paymentRoutes } = require('./paymentRoutes');
const { adminRoutes } = require('./adminRoutes');
const { appRoutes } = require('./appRoutes');

const apiRouter = express.Router();

apiRouter.use('/auth', authRoutes);
apiRouter.use('/', appRoutes);
apiRouter.use('/orders', orderRoutes);
apiRouter.use('/payments', paymentRoutes);
apiRouter.use('/admin', adminRoutes);

if (getConfig().env !== 'production') {
  const { devRoutes } = require('./devRoutes');
  apiRouter.use('/dev', devRoutes);
}

module.exports = { apiRouter };
