const { asyncHandler } = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/response');
const checkoutService = require('../services/checkoutService');

const quote = asyncHandler(async (req, res) => {
  const { userId, sessionToken } = req.cartContext;
  const result = await checkoutService.quote({ userId, sessionToken });
  return sendSuccess(res, { data: result, message: '' });
});

module.exports = { quote };
