const express = require('express');
const { requireAuth } = require('../middleware/requireAuth');
const { requireAdmin } = require('../middleware/requireAdmin');

const { validateRequest } = require('../middleware/validateRequest');
const {
  createProductSchema,
  createVariantSchema,
  updateProductSchema,
  idParamSchema,
  updateVariantStockSchema,
  updateOrderStatusSchema,
  createCouponSchema,
} = require('../validators/adminValidators');
const adminController = require('../controllers/adminController');

const adminRoutes = express.Router();

adminRoutes.use(requireAuth, requireAdmin);
adminRoutes.post('/products', validateRequest(createProductSchema), adminController.createProduct);
adminRoutes.post('/variants', validateRequest(createVariantSchema), adminController.createVariant);
adminRoutes.patch('/products/:id', validateRequest(updateProductSchema), adminController.updateProduct);
adminRoutes.delete('/products/:id', validateRequest(idParamSchema), adminController.deleteProduct);

adminRoutes.patch('/variants/:id/stock', validateRequest(updateVariantStockSchema), adminController.updateVariantStock);

adminRoutes.get('/orders', adminController.listOrders);
adminRoutes.patch('/orders/:id/status', validateRequest(updateOrderStatusSchema), adminController.updateOrderStatus);

adminRoutes.post('/coupons', validateRequest(createCouponSchema), adminController.createCoupon);
adminRoutes.get('/dashboard', adminController.dashboard);

module.exports = { adminRoutes };
