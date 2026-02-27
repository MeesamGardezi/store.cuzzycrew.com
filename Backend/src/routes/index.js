const express = require('express');

const { authRoutes } = require('./authRoutes');
const { productRoutes } = require('./productRoutes');
const { categoryRoutes } = require('./categoryRoutes');
const { cartRoutes } = require('./cartRoutes');
const { checkoutRoutes } = require('./checkoutRoutes');
const { orderRoutes } = require('./orderRoutes');
const { paymentRoutes } = require('./paymentRoutes');
const { adminRoutes } = require('./adminRoutes');

const apiRouter = express.Router();

apiRouter.use('/auth', authRoutes);
apiRouter.use('/products', productRoutes);
apiRouter.use('/categories', categoryRoutes);
apiRouter.use('/cart', cartRoutes);
apiRouter.use('/checkout', checkoutRoutes);
apiRouter.use('/orders', orderRoutes);
apiRouter.use('/payments', paymentRoutes);
apiRouter.use('/admin', adminRoutes);

module.exports = { apiRouter };
