const express = require('express');
const { requireAuth } = require('../middleware/requireAuth');
const { requireAdmin } = require('../middleware/requireAdmin');

const { validateRequest } = require('../middleware/validateRequest');
const {
  createProductSchema,
  createVariantSchema,
  createCategorySchema,
  updateCategorySchema,
  setWebsiteBannerSchema,
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
adminRoutes.post('/categories', validateRequest(createCategorySchema), adminController.createCategory);
adminRoutes.patch('/categories/:id', validateRequest(updateCategorySchema), adminController.updateCategory);
adminRoutes.delete('/categories/:id', validateRequest(idParamSchema), adminController.deleteCategory);
adminRoutes.put('/website-banner', validateRequest(setWebsiteBannerSchema), adminController.setWebsiteBanner);
adminRoutes.patch('/products/:id', validateRequest(updateProductSchema), adminController.updateProduct);
adminRoutes.delete('/products/:id', validateRequest(idParamSchema), adminController.deleteProduct);

adminRoutes.patch('/variants/:id/stock', validateRequest(updateVariantStockSchema), adminController.updateVariantStock);

adminRoutes.get('/orders', adminController.listOrders);
adminRoutes.patch('/orders/:id/status', validateRequest(updateOrderStatusSchema), adminController.updateOrderStatus);

adminRoutes.post('/coupons', validateRequest(createCouponSchema), adminController.createCoupon);
adminRoutes.get('/dashboard', adminController.dashboard);

module.exports = { adminRoutes };
