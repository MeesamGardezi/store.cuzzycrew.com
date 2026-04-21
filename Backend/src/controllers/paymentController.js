const { asyncHandler } = require('../utils/asyncHandler');
const { ApiError } = require('../utils/apiError');
const { sendSuccess } = require('../utils/response');
const paymentService = require('../services/paymentService');

const createCheckout = asyncHandler(async (req, res) => {
  const { orderId, orderToken } = req.validated.body;
  const result = await paymentService.createCheckout({ orderId, orderToken });
  return sendSuccess(res, { data: result, message: '' });
});

const webhook = asyncHandler(async (req, res) => {
  const signature = req.header('paddle-signature');
  const rawBody = req.body;
  const result = await paymentService.handleWebhook({ rawBody, signature });
  return sendSuccess(res, { data: result, message: '' });
});

const status = asyncHandler(async (req, res) => {
  const { orderId } = req.validated.params;
  const orderToken = req.header('x-order-token') || null;
  if (!orderToken || String(orderToken).trim() === '') {
    throw new ApiError({ status: 403, code: 'FORBIDDEN', message: 'Order token required', details: [] });
  }
  const result = await paymentService.getPaymentStatus({ orderId, orderToken: String(orderToken).trim() });
  return sendSuccess(res, { data: result, message: '' });
});

module.exports = { createCheckout, webhook, status };
