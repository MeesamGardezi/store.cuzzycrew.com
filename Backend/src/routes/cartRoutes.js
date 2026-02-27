const express = require('express');

const { optionalAuth } = require('../middleware/optionalAuth');
const { cartContext } = require('../middleware/cartContext');
const { validateRequest } = require('../middleware/validateRequest');
const {
  addItemSchema,
  updateItemSchema,
  deleteItemSchema,
  applyCouponSchema,
} = require('../validators/cartValidators');
const cartController = require('../controllers/cartController');

const cartRoutes = express.Router();

cartRoutes.use(optionalAuth, cartContext);

cartRoutes.get('/', cartController.getCart);
cartRoutes.post('/items', validateRequest(addItemSchema), cartController.addItem);
cartRoutes.patch('/items/:itemId', validateRequest(updateItemSchema), cartController.updateItem);
cartRoutes.delete('/items/:itemId', validateRequest(deleteItemSchema), cartController.deleteItem);
cartRoutes.post('/apply-coupon', validateRequest(applyCouponSchema), cartController.applyCoupon);
cartRoutes.delete('/coupon', cartController.removeCoupon);

module.exports = { cartRoutes };
