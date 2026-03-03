const express = require('express');
const { requireAuth } = require('../middleware/requireAuth');
const { optionalAuth } = require('../middleware/optionalAuth');

const { validateRequest } = require('../middleware/validateRequest');
const { createOrderSchema, orderIdSchema } = require('../validators/orderValidators');
const orderController = require('../controllers/orderController');

const orderRoutes = express.Router();

orderRoutes.post('/', optionalAuth, validateRequest(createOrderSchema), orderController.create);
orderRoutes.get('/', requireAuth, orderController.list);
orderRoutes.get('/:orderId', requireAuth, validateRequest(orderIdSchema), orderController.getById);
orderRoutes.post('/:orderId/cancel', requireAuth, validateRequest(orderIdSchema), orderController.cancel);

module.exports = { orderRoutes };
