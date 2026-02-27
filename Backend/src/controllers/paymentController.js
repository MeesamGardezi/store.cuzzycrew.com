const { asyncHandler } = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/response');
const paymentService = require('../services/paymentService');

const createIntent = asyncHandler(async (req, res) => {
  const { orderId } = req.validated.body;
  const result = await paymentService.createPaymentIntent({ userId: req.auth.userId, orderId });
  return sendSuccess(res, { data: result, message: '' });
});

const webhook = asyncHandler(async (req, res) => {
  const signature = req.header('stripe-signature');
  const rawBody = req.body;
  const result = await paymentService.handleWebhook({ rawBody, signature });
  return sendSuccess(res, { data: result, message: '' });
});

const status = asyncHandler(async (req, res) => {
  const { orderId } = req.validated.params;
  const result = await paymentService.getPaymentStatus({ userId: req.auth.userId, orderId });
  return sendSuccess(res, { data: result, message: '' });
});

module.exports = { createIntent, webhook, status };
