const { asyncHandler } = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/response');
const adminService = require('../services/adminService');

const createProduct = asyncHandler(async (req, res) => {
  const created = await adminService.createProduct({
    actorUserId: req.auth.userId,
    payload: req.validated.body,
    files: req.files || {},
    correlationId: req.correlationId,
  });
  return sendSuccess(res, { data: created, message: '' });
});

const updateProduct = asyncHandler(async (req, res) => {
  const { id } = req.validated.params;
  const updated = await adminService.updateProduct({
    actorUserId: req.auth.userId,
    productId: id,
    patch: req.validated.body,
    files: req.files || {},
    correlationId: req.correlationId,
  });
  return sendSuccess(res, { data: updated, message: '' });
});

const deleteProduct = asyncHandler(async (req, res) => {
  const { id } = req.validated.params;
  const deleted = await adminService.deleteProduct({
    actorUserId: req.auth.userId,
    productId: id,
    correlationId: req.correlationId,
  });
  return sendSuccess(res, { data: deleted, message: '' });
});

const updateVariantStock = asyncHandler(async (req, res) => {
  const { id } = req.validated.params;
  const { stock } = req.validated.body;
  const updated = await adminService.updateVariantStock({
    actorUserId: req.auth.userId,
    variantId: id,
    stock,
    correlationId: req.correlationId,
  });
  return sendSuccess(res, { data: updated, message: '' });
});

const listOrders = asyncHandler(async (req, res) => {
  const limit = Math.min(Math.max(Number(req.query.limit || 50), 1), 100);
  const cursor = req.query.cursor ? String(req.query.cursor) : null;
  const processed =
    req.query.processed === 'true' ? true : req.query.processed === 'false' ? false : null;
  const result = await adminService.listOrders({ limit, cursor, processed });
  return sendSuccess(res, { data: result, message: '' });
});

const updateOrderStatus = asyncHandler(async (req, res) => {
  const { id } = req.validated.params;
  const { status } = req.validated.body;
  const updated = await adminService.updateOrderStatus({
    actorUserId: req.auth.userId,
    orderId: id,
    status,
    correlationId: req.correlationId,
  });
  return sendSuccess(res, { data: updated, message: '' });
});

const toggleProcessedOrder = asyncHandler(async (req, res) => {
  const { id } = req.validated.params;
  const updated = await adminService.toggleProcessedOrder({
    actorUserId: req.auth.userId,
    orderId: id,
    correlationId: req.correlationId,
  });
  return sendSuccess(res, { data: updated, message: '' });
});

const createCoupon = asyncHandler(async (req, res) => {
  const created = await adminService.createCoupon({
    actorUserId: req.auth.userId,
    payload: req.validated.body,
    correlationId: req.correlationId,
  });
  return sendSuccess(res, { data: created, message: '' });
});

const createCategory = asyncHandler(async (req, res) => {
  const created = await adminService.createCategory({
    actorUserId: req.auth.userId,
    payload: req.validated.body,
    correlationId: req.correlationId,
  });
  return sendSuccess(res, { data: created, message: '' });
});

const updateCategory = asyncHandler(async (req, res) => {
  const { id } = req.validated.params;
  const updated = await adminService.updateCategory({
    actorUserId: req.auth.userId,
    categoryId: id,
    patch: req.validated.body,
    correlationId: req.correlationId,
  });
  return sendSuccess(res, { data: updated, message: '' });
});

const deleteCategory = asyncHandler(async (req, res) => {
  const { id } = req.validated.params;
  const deleted = await adminService.deleteCategory({
    actorUserId: req.auth.userId,
    categoryId: id,
    correlationId: req.correlationId,
  });
  return sendSuccess(res, { data: deleted, message: '' });
});

const setWebsiteBanner = asyncHandler(async (req, res) => {
  const updated = await adminService.setWebsiteBanner({
    actorUserId: req.auth.userId,
    images: req.validated.body.images,
    correlationId: req.correlationId,
  });
  return sendSuccess(res, { data: updated, message: '' });
});

const dashboard = asyncHandler(async (req, res) => {
  const result = await adminService.dashboard();
  return sendSuccess(res, { data: result, message: '' });
});

const createVariant = asyncHandler(async (req, res) => {
  const created = await adminService.createVariant({
    actorUserId: req.auth.userId,
    payload: req.validated.body,
    correlationId: req.correlationId,
  });
  return sendSuccess(res, { data: created, message: '' });
});

module.exports = {
  createProduct,
  updateProduct,
  deleteProduct,
  updateVariantStock,
  createVariant,
  createCategory,
  updateCategory,
  deleteCategory,
  setWebsiteBanner,
  listOrders,
  updateOrderStatus,
  toggleProcessedOrder,
  createCoupon,
  dashboard,
};
