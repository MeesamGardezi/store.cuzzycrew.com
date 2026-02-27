const { asyncHandler } = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/response');
const orderService = require('../services/orderService');

const create = asyncHandler(async (req, res) => {
  const idempotencyKey = req.header('idempotency-key');
  const { shippingAddressId } = req.validated.body;

  const result = await orderService.createOrder({
    userId: req.auth.userId,
    idempotencyKey,
    shippingAddressId,
  });

  return sendSuccess(res, { data: result, message: '' });
});

const list = asyncHandler(async (req, res) => {
  const limit = Math.min(Math.max(Number(req.query.limit || 20), 1), 50);
  const cursor = req.query.cursor ? String(req.query.cursor) : null;

  const result = await orderService.listOrders({ userId: req.auth.userId, limit, cursor });
  return sendSuccess(res, { data: result, message: '' });
});

const getById = asyncHandler(async (req, res) => {
  const { orderId } = req.validated.params;
  const result = await orderService.getOrder({ userId: req.auth.userId, orderId });
  return sendSuccess(res, { data: result, message: '' });
});

const cancel = asyncHandler(async (req, res) => {
  const { orderId } = req.validated.params;
  const result = await orderService.cancelOrder({ userId: req.auth.userId, orderId });
  return sendSuccess(res, { data: result, message: '' });
});

module.exports = { create, list, getById, cancel };
