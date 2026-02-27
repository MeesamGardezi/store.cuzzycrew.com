const { asyncHandler } = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/response');
const cartService = require('../services/cartService');

const getCart = asyncHandler(async (req, res) => {
  const { userId, sessionToken } = req.cartContext;
  const result = await cartService.getCart({ userId, sessionToken });
  return sendSuccess(res, { data: result, message: '' });
});

const addItem = asyncHandler(async (req, res) => {
  const { userId, sessionToken } = req.cartContext;
  const { variantId, quantity } = req.validated.body;
  const result = await cartService.addItem({ userId, sessionToken, variantId, quantity });
  return sendSuccess(res, { data: result, message: '' });
});

const updateItem = asyncHandler(async (req, res) => {
  const { userId, sessionToken } = req.cartContext;
  const { itemId } = req.validated.params;
  const { quantity } = req.validated.body;
  const result = await cartService.updateItem({ userId, sessionToken, itemId, quantity });
  return sendSuccess(res, { data: result, message: '' });
});

const deleteItem = asyncHandler(async (req, res) => {
  const { userId, sessionToken } = req.cartContext;
  const { itemId } = req.validated.params;
  const result = await cartService.deleteItem({ userId, sessionToken, itemId });
  return sendSuccess(res, { data: result, message: '' });
});

const applyCoupon = asyncHandler(async (req, res) => {
  const { userId, sessionToken } = req.cartContext;
  const { code } = req.validated.body;
  const result = await cartService.applyCoupon({ userId, sessionToken, code });
  return sendSuccess(res, { data: result, message: '' });
});

const removeCoupon = asyncHandler(async (req, res) => {
  const { userId, sessionToken } = req.cartContext;
  const result = await cartService.removeCoupon({ userId, sessionToken });
  return sendSuccess(res, { data: result, message: '' });
});

module.exports = { getCart, addItem, updateItem, deleteItem, applyCoupon, removeCoupon };
