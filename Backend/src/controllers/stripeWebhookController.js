const { asyncHandler } = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/response');

const stripeCheckoutWebhookService = require('../services/stripeCheckoutWebhookService');

const webhook = asyncHandler(async (req, res) => {
  const signature = req.header('stripe-signature');
  const rawBody = req.body;
  const result = await stripeCheckoutWebhookService.handleStripeWebhook({ rawBody, signature });
  return sendSuccess(res, { data: result, message: '' });
});

module.exports = { webhook };
