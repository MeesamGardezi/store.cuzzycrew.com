const { asyncHandler } = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/response');

const checkoutSessionService = require('../services/checkoutSessionService');

const createCheckoutSession = asyncHandler(async (req, res) => {
  const result = await checkoutSessionService.createCheckoutSession({
    payload: req.validated.body,
    correlationId: req.correlationId,
  });

  return sendSuccess(res, { data: result, message: '' });
});

module.exports = { createCheckoutSession };
